#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/wait.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/shm.h>

typedef struct {
    float total_credits;
    float weighted_grade_sum;
} GPAData;

pthread_mutex_t gpa_mutex;

void handle_subject(int credit_hours, float grade_points, GPAData *shared_data) {
    pthread_mutex_lock(&gpa_mutex);
    shared_data->total_credits += credit_hours;
    shared_data->weighted_grade_sum += (credit_hours * grade_points);
    pthread_mutex_unlock(&gpa_mutex);
}

int main(int argc, char *argv[]) {
    int subject_count = atoi(argv[1]);

    FILE *file = fopen(argv[2], "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    int shm_id = shmget(IPC_PRIVATE, sizeof(GPAData), IPC_CREAT | 0666);
    if (shm_id < 0) {
        perror("Error creating shared memory");
        return 1;
    }

    GPAData *shared_data = (GPAData *)shmat(shm_id, NULL, 0);
    if (shared_data == (GPAData *)-1) {
        perror("Error attaching shared memory");
        return 1;
    }

    shared_data->total_credits = 0;
    shared_data->weighted_grade_sum = 0;

    pthread_mutex_init(&gpa_mutex, NULL);

    pid_t pgid = getpid();

    for (int i = 0; i < subject_count; i++) {
        int credit_hours;
        float grade_points;

        fscanf(file, "%d %f", &credit_hours, &grade_points);

        pid_t pid = fork();

        if (pid == -1) {
            perror("Fork failed");
            exit(EXIT_FAILURE);
        } else if (pid == 0) {
            setpgid(0, pgid);
            handle_subject(credit_hours, grade_points, shared_data);

            exit(EXIT_SUCCESS);
        }
    }

    int status;
    pid_t wpid;

    while ((wpid = wait(&status)) > 0) {}

    float gpa = shared_data->weighted_grade_sum / shared_data->total_credits;

    char cmd[100];
    snprintf(cmd, sizeof(cmd), "dialog --msgbox \"Final GPA: %.2f\" 10 30", gpa);
    system(cmd);

    shmdt(shared_data);
    shmctl(shm_id, IPC_RMID, NULL);

    pthread_mutex_destroy(&gpa_mutex);
    fclose(file);

    return 0;
}