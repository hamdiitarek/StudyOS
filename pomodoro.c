#include <ncurses.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>


void display_timer(int minutes, int seconds, const char *message) {
    clear();
    mvprintw(5, 10, "%s", message);
    mvprintw(7, 10, "Time: %02d:%02d", minutes, seconds);
    mvprintw(10, 10, "Press 'q' to quit.");
    refresh();
}

void pomodoro_timer(int WORK_DURATION, int BREAK_DURATION) {
    int remaining_time = WORK_DURATION;
    int is_work_session = 1;  // 1 for work to start with it

    // Initialize ncurses
    initscr();
    noecho();
    curs_set(FALSE);
    timeout(1000);  // 1-second timeout for non-blocking input

    while (1) {
        
        int minutes = remaining_time / 60;
        int seconds = remaining_time % 60;

        
        if (is_work_session) {
            display_timer(minutes, seconds, "Work Session");
        } else {
            display_timer(minutes, seconds, "Break Session");
        }

        
        remaining_time--;

        int ch = getch();
        if (ch == 'q' || ch == 'Q') {
            break;
        }

        if (remaining_time < 0) {
            if (is_work_session) {
                remaining_time = BREAK_DURATION;  // Switch to break
                is_work_session = 0;
            } else {
                remaining_time = WORK_DURATION;  // Switch to work
                is_work_session = 1;
            }
        }
    }

    // End ncurses mode
    endwin();
}

int main(int argc, char *argv[]) {

    int WORK_DURATION = atoi(argv[1])*60;  
    int BREAK_DURATION = atoi(argv[2])*60; 
    printf("Pomodoro Timer: Press 'q' to quit.\n");
    pomodoro_timer(WORK_DURATION, BREAK_DURATION);
    return 0;
}
