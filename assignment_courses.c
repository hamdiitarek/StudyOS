#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>

#define MAX_COURSES 10
#define MAX_ASSIGNMENTS 20
#define MAX_NAME_LENGTH 150
#define MAX_LINES 1000
#define MAX_LINE_LENGTH 256

typedef struct {
    char name[MAX_NAME_LENGTH];
    int difficulty;
    int time_required;
    int is_complete;
    char due_date[MAX_NAME_LENGTH];
} Assignment;

typedef struct {
    char name[MAX_NAME_LENGTH];
    Assignment assignments[MAX_ASSIGNMENTS];
    int assignment_count;
    int course_id;
} Course;

typedef struct {
    Course courses[MAX_COURSES];
    int course_count;
    pthread_mutex_t mutex;
} CourseManager;

CourseManager *manager;
int shmid;

void initializeSharedMemory(key_t key) {
    shmid = shmget(key, sizeof(CourseManager), IPC_CREAT | 0666);
    if (shmid == -1) {
        perror("Error creating shared memory");
        return;
    }

    manager = (CourseManager *) shmat(shmid, NULL, 0);
    if (manager == (CourseManager *) -1) {
        perror("Error attaching shared memory");
        return;
    }

    manager->course_count = 0;
    pthread_mutex_init(&manager->mutex, NULL);
}

void unique_id () {
    Course* course;
    for (int x = 0; x < manager->course_count; x++)
    {
        course = &manager->courses[x];
        if (course->course_id != x+1)
        {
            course->course_id = x+1;
        }
    }
}

void add_course(const char* name, const char* filename) {
    pthread_mutex_lock(&manager->mutex);

    if (manager->course_count >= MAX_COURSES) {
        pthread_mutex_unlock(&manager->mutex);
        printf("Error: Maximum course limit reached.\n");
        return;
    }

    Course* course = &manager->courses[manager->course_count];
    strncpy(course->name, name, MAX_NAME_LENGTH - 1);
    course->assignment_count = 0;
    course->course_id = manager->course_count + 1;
    manager->course_count++;

    FILE* file = fopen(filename, "a");
    if (!file) {
        perror("Error opening file");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    fprintf(file, "%d|%s|0\n", course->course_id, course->name); // No assignments yet
    fclose(file);

    pthread_mutex_unlock(&manager->mutex);
}

void add_assignment(int course_id, const char* name, int difficulty, int time, const char* due_date, const char* filename) {
    pthread_mutex_lock(&manager->mutex);

    if (course_id < 1 || course_id > manager->course_count) {
        printf("Error: Invalid course ID.\n");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    Course* course = &manager->courses[course_id - 1];
    if (course->assignment_count >= MAX_ASSIGNMENTS) {
        printf("Error: Maximum assignment limit reached.\n");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    Assignment* assignment = &course->assignments[course->assignment_count];
    strncpy(assignment->name, name, MAX_NAME_LENGTH - 1);
    assignment->difficulty = difficulty;
    assignment->time_required = time;
    assignment->is_complete = 0;
    strncpy(assignment->due_date, due_date, MAX_NAME_LENGTH - 1);
    course->assignment_count++;

    FILE* file = fopen(filename, "r+");
    if (!file) {
        perror("Error opening file");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    char lines[MAX_LINES][MAX_LINE_LENGTH];
    int line_count = 0;

    while (fgets(lines[line_count], MAX_LINE_LENGTH, file)) {
        line_count++;
    }
    fclose(file);

    file = fopen(filename, "w");
    if (!file) {
        perror("Error reopening file");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    for (int i = 0; i < line_count; i++) {
        if (i == course_id - 1) {
            fprintf(file, "%d|%s|%d", course->course_id, course->name, course->assignment_count);
            for (int j = 0; j < course->assignment_count; j++) {
                Assignment* a = &course->assignments[j];
                fprintf(file, "|%d,%s,%d,%d,%d,%s", j + 1, a->name, a->difficulty, a->time_required, a->is_complete, a->due_date);
            }
            fprintf(file, "\n");
        } else {
            fputs(lines[i], file);
        }
    }

    fclose(file);
    pthread_mutex_unlock(&manager->mutex);
}

void delete_course(int course_id, const char* filename) {
    pthread_mutex_lock(&manager->mutex);

    if (course_id < 1 || course_id > manager->course_count) {
        printf("Error: Invalid course ID.\n");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    for (int i = course_id - 1; i < manager->course_count - 1; i++) {
        manager->courses[i] = manager->courses[i + 1];
    }
    manager->course_count--;

    FILE* file = fopen(filename, "w");
    if (!file) {
        perror("Error reopening file");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    unique_id();

    for (int i = 0; i < manager->course_count; i++) {
        Course* course = &manager->courses[i];
        fprintf(file, "%d|%s|%d", course->course_id, course->name, course->assignment_count);
        if (course->assignment_count > 0)
        {
            for (int j = 0; j < course->assignment_count; j++) {
                Assignment* a = &course->assignments[j];
                fprintf(file, "|%d,%s,%d,%d,%d,%s", j + 1, a->name, a->difficulty, a->time_required, a->is_complete, a->due_date);
            }
        }
        else
        {
            fprintf(file, "\n");
        }
    }

    fclose(file);
    pthread_mutex_unlock(&manager->mutex);
}

void delete_assignment(int course_id, int assignment_id, const char* filename) {
    pthread_mutex_lock(&manager->mutex);

    if (course_id < 1 || course_id > manager->course_count) {
        printf("Error: Invalid course ID.\n");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    Course* course = &manager->courses[course_id - 1];
    if (assignment_id < 1 || assignment_id > course->assignment_count) {
        printf("Error: Invalid assignment ID.\n");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    for (int i = assignment_id - 1; i < course->assignment_count - 1; i++) {
        course->assignments[i] = course->assignments[i + 1];
    }
    course->assignment_count--;

    FILE* file = fopen(filename, "r+");
    if (!file) {
        perror("Error opening file");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    char lines[MAX_LINES][MAX_LINE_LENGTH];
    int line_count = 0;

    while (fgets(lines[line_count], MAX_LINE_LENGTH, file)) {
        line_count++;
    }
    fclose(file);

    file = fopen(filename, "w");
    if (!file) {
        perror("Error reopening file");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    for (int i = 0; i < line_count; i++) {
        if (i == course_id - 1) {
            fprintf(file, "%d|%s|%d", course->course_id, course->name, course->assignment_count);
            for (int j = 0; j < course->assignment_count; j++) {
                Assignment* a = &course->assignments[j];
                fprintf(file, "|%d,%s,%d,%d,%d,%s", j + 1, a->name, a->difficulty, a->time_required, a->is_complete, a->due_date);
            }
            fprintf(file, "\n");
        } else {
            fputs(lines[i], file);
        }
    }

    fclose(file);
    pthread_mutex_unlock(&manager->mutex);
}

void submit_assignment(int course_id, int assignment_id, char* file_path, char* filename, char* submissions_dir) {
    pthread_mutex_lock(&manager->mutex);

    if (course_id < 1 || course_id > manager->course_count) {
        printf("Error: Invalid course ID.\n");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    Course* course = &manager->courses[course_id - 1];
    if (assignment_id < 1 || assignment_id > course->assignment_count) {
        printf("Error: Invalid assignment ID.\n");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    Assignment* assignment = &course->assignments[assignment_id - 1];

    // Ensure the submissions directory and course-specific folder exist
    char course_folder[MAX_LINE_LENGTH];
    snprintf(course_folder, sizeof(course_folder), "%s/%s", submissions_dir, course->name);
    char mkdir_command[MAX_LINE_LENGTH + 20];
    snprintf(mkdir_command, sizeof(mkdir_command), "mkdir -p \"%s\"", course_folder);
    system(mkdir_command);

    // Check if the source file exists
    if (access(file_path, F_OK) != 0) {
        printf("Warning: File '%s' not found. Creating a placeholder file.\n", file_path);

        // Create a placeholder file
        FILE* placeholder = fopen(file_path, "w");
        if (!placeholder) {
            perror("Error creating placeholder file");
            pthread_mutex_unlock(&manager->mutex);
            return;
        }
        fprintf(placeholder, "Placeholder file for assignment submission.\n");
        fclose(placeholder);
    }

    // Construct the destination file path inside the course folder
    char destination_path[MAX_LINE_LENGTH + MAX_NAME_LENGTH + 5];
    snprintf(destination_path, sizeof(destination_path), "%s/%s.txt", course_folder, assignment->name);

    // Execute the copy command
    char command[MAX_LINE_LENGTH + MAX_LINE_LENGTH + MAX_NAME_LENGTH + 10];
    snprintf(command, sizeof(command), "cp \"%s\" \"%s\"", file_path, destination_path);

    int result = system(command);
    if (result != 0) {
        printf("Error: Failed to copy file. Please check permissions.\n");
    } else {
        printf("Assignment submitted successfully: %s\n", destination_path);

        // Mark the assignment as complete
        assignment->is_complete = 1;

        // Update the courses.log file
        FILE* file = fopen(filename, "w");
        if (!file) {
            perror("Error updating courses.log");
            pthread_mutex_unlock(&manager->mutex);
            return;
        }

        for (int i = 0; i < manager->course_count; i++) {
            Course* c = &manager->courses[i];
            fprintf(file, "%d|%s|%d", c->course_id, c->name, c->assignment_count);
            for (int j = 0; j < c->assignment_count; j++) {
                Assignment* a = &c->assignments[j];
                fprintf(file, "|%d,%s,%d,%d,%d,%s", j + 1, a->name, a->difficulty, a->time_required,
                        a->is_complete, a->due_date);
            }
            fprintf(file, "\n");
        }

        fclose(file);
    }

    pthread_mutex_unlock(&manager->mutex);
}


void view_assignments(int course_id) {
    pthread_mutex_lock(&manager->mutex);

    if (course_id < 1 || course_id > manager->course_count) {
        printf("Error: Invalid course ID.\n");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    Course* course = &manager->courses[course_id - 1];
    printf("Assignments for Course %s:\n", course->name);
    for (int i = 0; i < course->assignment_count; i++) {
        Assignment* assignment = &course->assignments[i];
        printf("%d: %s, Difficulty: %d, Time: %d, Due: %s, Complete: %s\n",
               i + 1, assignment->name, assignment->difficulty, assignment->time_required,
               assignment->due_date, assignment->is_complete ? "Yes" : "No");
    }

    pthread_mutex_unlock(&manager->mutex);
}

void load_courses(const char* filename) {
    pthread_mutex_lock(&manager->mutex);

    FILE* file = fopen(filename, "r");
    if (!file) {
        perror("Error opening file");
        pthread_mutex_unlock(&manager->mutex);
        return;
    }

    manager->course_count = 0;
    char line[MAX_LINE_LENGTH];
    
    while (fgets(line, sizeof(line), file)) {
        Course* course = &manager->courses[manager->course_count];
        char* token = strtok(line, "|");
        
        // Parse course_id
        course->course_id = atoi(token);

        // Parse course name
        token = strtok(NULL, "|");
        if (token) {
            strncpy(course->name, token, MAX_NAME_LENGTH - 1);
            course->name[MAX_NAME_LENGTH - 1] = '\0'; // Ensure null-termination
        }

        // Parse number of assignments
        token = strtok(NULL, "|");
        course->assignment_count = atoi(token);

        // Parse assignments
        for (int i = 0; i < course->assignment_count; i++) {
            Assignment* assignment = &course->assignments[i];
            
            // Read assignment details
            token = strtok(NULL, "|");
            if (token) {
                int assignment_index;
                int parsed = sscanf(token, "%d,%[^,],%d,%d,%d,%s", 
                                     &assignment_index, assignment->name, 
                                     &assignment->difficulty, &assignment->time_required, 
                                     &assignment->is_complete, assignment->due_date);

                if (parsed != 6) {
                    fprintf(stderr, "Error parsing assignment %d\n", i);
                    break; // Handle parsing error gracefully
                }
            }
        }

        manager->course_count++;
    }

    fclose(file);
    pthread_mutex_unlock(&manager->mutex);
}

void view_all_courses() {
    pthread_mutex_lock(&manager->mutex);

    printf("\nList of Courses :\n");
    for (int i = 0; i < manager->course_count; i++) {
        Course* course = &manager->courses[i];
        printf("\nid %d) %s\n",course->course_id, course->name);
    }

    pthread_mutex_unlock(&manager->mutex);
}

void view_all_assignments() {
    pthread_mutex_lock(&manager->mutex);

    for (int i = 0; i < manager->course_count; i++) {
        Course* course = &manager->courses[i];
        printf("\nAssignments for Course -> %s:\n", course->name);
        for (int j = 0; j < course->assignment_count; j++) {
            Assignment* assignment = &course->assignments[j];
            printf("%d: %s, Difficulty: %d, Time: %d, Due: %s, Complete: %s\n",
                   j + 1, assignment->name, assignment->difficulty, assignment->time_required,
                   assignment->due_date, assignment->is_complete ? "Yes" : "No");
        }
    }

    pthread_mutex_unlock(&manager->mutex);
}

char* get_username() {
    char* username = getenv("USER");
    if (username == NULL) {
        exit(1);
    }
    return username;
}

void cleanupSharedMemory() {
    if (shmdt(manager) == -1) {
        perror("shmdt failed");
    }

    if (shmctl(shmid, IPC_RMID, NULL) == -1) {
        perror("shmctl failed");
    }
}


int main(int argc, char* argv[]) {
    
    key_t key = IPC_PRIVATE;
    initializeSharedMemory(key);
    if (manager == NULL) {
        return 1;
    }

    char *username = get_username();

    char filename[MAX_LINE_LENGTH];
    char base_dir[MAX_LINE_LENGTH];
    char submissions_dir[MAX_LINE_LENGTH];

    snprintf(filename, sizeof(filename), "/home/%s/Documents/StudyOS/courses.log", username);
    snprintf(base_dir, sizeof(base_dir), "/home/%s/Documents/StudyOS", username);
    snprintf(submissions_dir, sizeof(submissions_dir), "/home/%s/Documents/StudyOS/submissions", username);

    mkdir(base_dir, 0777);
    mkdir(submissions_dir, 0777);

    FILE* log_file = fopen(filename, "a");
    if (!log_file) {
        perror("Error creating courses.log file");
        return 1;
    }
    fclose(log_file);

    load_courses(filename);

    int case_id = atoi(argv[1]);
    int option = 0;

    switch (case_id)
    {
        case 1:
            if (argc < 1) {
                printf("Error: Case ID required.\n");
                return 1;
            }
            view_all_courses();
            break;

        case 2:
            if (argc < 2) {
                printf("Error: Name required.\n");
                return 1;
            }
            add_course(argv[2],filename);
            break;

        case 3:
            if (argc < 2) {
                printf("Error: Course ID required.\n");
                return 1;
            }
            delete_course(atoi(argv[2]), filename);
            break;
        
        case 4:
        option = atoi(argv[2]);
            switch (option) 
            {
                case 1:
                    if (argc < 2) {
                        printf("Error: case ID required.\n");
                        return 1;
                    }
                    view_all_assignments();
                    break;
                case 2:
                    if (argc < 3) {
                        printf("Error: Course ID required.\n");
                        return 1;
                    }
                    view_assignments(atoi(argv[3]));
                    break;
                case 3:
                    if (argc < 8) {
                        printf("Error: Course ID, name, difficulty, time, and due date required.\n");
                        return 1;
                    }
                    add_assignment(atoi(argv[3]), argv[4], atoi(argv[5]), atoi(argv[6]), argv[7], filename);
                    break;
                case 4:
                    if (argc < 6) {
                        printf("Error: Course ID, assignment ID, and file path required.\n");
                        return 1;
                    }
                    submit_assignment(atoi(argv[3]), atoi(argv[4]), argv[5], filename, submissions_dir);
                    break;
                case 5:
                    if (argc < 5) {
                        printf("Error: Course ID and assignment ID required.\n");
                        return 1;
                    }
                    delete_assignment(atoi(argv[3]), atoi(argv[4]), filename);
                    break;
                default:
                    printf("Error: Invalid option.\n");
                    return 1;
            }
            break;

        default:
            printf("Invalid id\n");
            break;
    }

    cleanupSharedMemory();

    return 0;
}