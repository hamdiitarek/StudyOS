#include <ncurses.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

// Global variables
int remaining_time;
int is_work_session = 1;  // 1 for work session, 0 for break session
int should_exit = 0;
int WORK_DURATION, BREAK_DURATION;

pthread_mutex_t lock;

void display_timer(int minutes, int seconds, const char *message) {
    clear();
    mvprintw(5, 10, "%s", message);
    mvprintw(7, 10, "Time: %02d:%02d", minutes, seconds);
    mvprintw(10, 10, "Press 'q' to quit.");
    refresh();
}

void *timer_thread(void *arg) {
    while (!should_exit) {
        pthread_mutex_lock(&lock);
        if (remaining_time >= 0) {
            beep();
            int minutes = remaining_time / 60;
            int seconds = remaining_time % 60;

            if (is_work_session) {
                display_timer(minutes, seconds, "Work Session");
            } else {
                display_timer(minutes, seconds, "Break Session");
            }

            remaining_time--;
        } else {
            if (is_work_session) {
                remaining_time = BREAK_DURATION;
                is_work_session = 0;
            } else {
                remaining_time = WORK_DURATION;
                is_work_session = 1;
            }
        }
        pthread_mutex_unlock(&lock);
        sleep(1);
    }
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <work_duration_minutes> <break_duration_minutes>\n", argv[0]);
        return 1;
    }

    WORK_DURATION = atoi(argv[1]) * 60;  
    BREAK_DURATION = atoi(argv[2]) * 60;
    remaining_time = WORK_DURATION;

    // Initialize ncurses
    initscr();
    noecho();
    curs_set(FALSE);
    timeout(100);  // 100ms timeout for non-blocking input

    pthread_mutex_init(&lock, NULL);

    // Create the timer thread
    pthread_t timer_tid;
    pthread_create(&timer_tid, NULL, timer_thread, NULL);

    while (!should_exit) {
        int ch = getch();
        if (ch == 'q' || ch == 'Q') {
            pthread_mutex_lock(&lock);
            should_exit = 1;
            pthread_mutex_unlock(&lock);
            break;
        }
    }

    // Wait thread to finish
    pthread_join(timer_tid, NULL);

    // Cleanup ncurses and mutex
    endwin();
    pthread_mutex_destroy(&lock);

    return 0;
}
