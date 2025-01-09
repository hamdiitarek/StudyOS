#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>

#define SOUND_DIR "./sounds/" 

volatile int keep_playing = 1; 
pid_t playback_pid = -1;       

void handle_stop_signal(int signum) {
    keep_playing = 0;
    if (playback_pid > 0) {
        kill(playback_pid, SIGKILL); 
    }
}
void handle_INT_signal(int signum) { 
    char msg[] = "CTRL + C pressed, Not Stopping";
    char command[128];

    system("clear");

    snprintf(command, sizeof(command), "dialog --msgbox \"%s\" 6 40", msg);

    system(command);

}

void *play_sound(void *arg) {
    char *sound_file = (char *)arg;

    while (keep_playing) {

        playback_pid = fork();
        if (playback_pid == 0) {
            //basically to get rid of the messages of the "aplay"
            freopen("/dev/null", "w", stdout);
            freopen("/dev/null", "w", stderr);
            execlp("aplay", "aplay", sound_file, (char *)NULL);
            perror("execlp failed"); // if execlp fails
            exit(EXIT_FAILURE);
        } else if (playback_pid < 0) {
            perror("fork failed");
            break;
        }

        // Parent process: Wait for playback to finish or be interrupted
        int status;
        waitpid(playback_pid, &status, 0);
        playback_pid = -1;

        // If playback was stopped, exit the loop
        if (!keep_playing) {
            break;
        }
    }
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <sound_file>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    char sound_path[512];
    snprintf(sound_path, sizeof(sound_path), "%s%s", SOUND_DIR, argv[1]);

    signal(SIGTERM, handle_stop_signal);
    signal(SIGINT, handle_INT_signal);

    pthread_t thread_id;

    if (pthread_create(&thread_id, NULL, play_sound, (void *)sound_path) != 0) {
        perror("pthread_create");
        exit(EXIT_FAILURE);
    }

    pthread_join(thread_id, NULL);


    return 0;
}