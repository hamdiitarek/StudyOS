#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>

#define MAX_COURSES 10
#define MAX_ASSIGNMENTS 20
#define MAX_NAME_LENGTH 150
#define MAX_LINES 1000
#define MAX_LINE_LENGTH 256

typedef struct {
    char name[MAX_NAME_LENGTH];
    int difficulty;  // 1-10
    int time_required;  // in hours
    int is_complete;
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

CourseManager manager;
pthread_t scheduler_thread;

void init_course_manager() {
    manager.course_count = 0;
    pthread_mutex_init(&manager.mutex, NULL);
}

void unique_id (int *ids) {
    Course* course;
    for (int x = 0; x < manager.course_count; x++)
    {
        course = &manager.courses[x];
        if (ids[x] != x+1)
        {
            course->course_id = x+1;
            ids[x] = x+1;
        }
    }
}

void add_course(const char* name, const char* filename) {
    pthread_mutex_lock(&manager.mutex);
    
    if (manager.course_count >= MAX_COURSES) {
        pthread_mutex_unlock(&manager.mutex);
        printf("Error: Maximum course limit reached.\n");
        return;
    }

    Course* course = &manager.courses[manager.course_count];
    strncpy(course->name, name, MAX_NAME_LENGTH - 1);
    course->assignment_count = 0;
    course->course_id = manager.course_count + 1;
    manager.course_count++;

    FILE* file = fopen(filename, "a");
    if (!file) {
        perror("Error opening file");
        pthread_mutex_unlock(&manager.mutex);
        return;
    }

    fprintf(file, "%d|%s\n", course->course_id, course->name); // No assignments yet
    fclose(file);

    pthread_mutex_unlock(&manager.mutex);
}

void read_file(const char *filename, int *line_count, int *ids, char lines[][MAX_NAME_LENGTH])
{
    FILE *file;
    file = fopen(filename, "r");
    if (!file) {
        perror("Error opening file");
        return;
    }

    if (fgetc(file) == EOF) {
        fclose(file);
        return;
    }

    rewind(file);
    *line_count = 0;

    while (fscanf(file, "%d|%50[^\n]", &ids[*line_count], lines[*line_count]) == 2) {
        (*line_count)++;
    }

    fclose(file);
}

void delete_course(int id, char *filename, int *ids, char lines[][MAX_NAME_LENGTH], int *line_count)
{
    FILE *file;

    read_file(filename, line_count, ids, lines);

    int index_to_delete = -1;
    for (int x = 0; x < manager.course_count; x++) {
        if (ids[x] == id) {
            index_to_delete = x;
            break;
        }
    }

    for (int i = index_to_delete; i < manager.course_count - 1; i++) {
        ids[i] = ids[i + 1];
        strcpy(lines[i], lines[i + 1]);
    }
    manager.course_count = manager.course_count - 1;
   
    unique_id(ids);

    file = fopen(filename, "w");
    if (file == NULL) {
        perror("Error opening file");
        return;
    }

    for (int i = 0; i < manager.course_count; i++) {
        fprintf(file, "%d|%s\n", ids[i], lines[i]);
    }

    fclose(file);
}

int main(int argc, char * argv[]) 
{
    FILE *file;
    char *cmd[] = {
        "bash", "-c",
        "for line in $(cat courses.log); do echo $line; done | dialog --textbox /dev/stdin 20 60",
        NULL
    };
    int course_id = 0;
    int line_count = 0;
    char course_name[MAX_NAME_LENGTH] ;
    int ids[MAX_LINES];
    char lines[MAX_LINES][MAX_NAME_LENGTH];
    Course* course ;

    int case_id = atoi(argv[1]);

    read_file("courses.log", &line_count, ids, lines);
    file = fopen("courses.log", "w");
    fclose(file);

    for (int x = 0; x < line_count; x++)
    {
        add_course(lines[x], "courses.log");
    }


    switch (case_id)
    {
        case 1:
            system("dialog --title Courses --textbox courses.log 15 40");
            break;

        case 2:
            file = fopen("courses.log", "w");
            fclose(file);
            break;
        
        case 3:
            char *name = argv[2];
            strncpy(course_name, name, sizeof(course_name) - 1);
            add_course(course_name, "courses.log");
            break;
        
        case 4:
            int id = atoi(argv[2]);
            if (id > ids[manager.course_count - 1])
            {
                system("dialog --title 'Error' --msgbox 'EKteb yla id felrange balash araf' 10 40");
                break;
            }
            course = &manager.courses[id - 1];
            delete_course(course->course_id,"courses.log", ids, lines, &line_count);
            break;

        default:
            printf("Invalid id\n");
            break;
    }

    return 0;
}