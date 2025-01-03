#!/bin/bash

#

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
TITLE="Main Menu"
MENU="Choose an option:"

OPTIONS=(
    1 "Pomodoro Timer"
    2 "PC Info"
    3 "Exit"
)

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

# Clear the screen
clear

# Handle user choice
case $CHOICE in
    1)
        work_input=$(dialog  --clear \
                        --backtitle "StudyOS - Hamdi Awad, Omar Abdulaal, Omar Abdulrady" \
                        --title "Work Session Time" \
                        --inputbox "Please Enter Work Session Time In Minutes:" 8 40 \
                        --output-fd 1)
        break_input=$(dialog  --clear \
                        --backtitle "StudyOS - Hamdi Awad, Omar Abdulaal, Omar Abdulrady" \
                        --title "Break Session Time" \
                        --inputbox "Please Enter Break Session Time In Minutes:" 8 40 \
                        --output-fd 1)

        gcc -o pomodoroout pomodoro.c -lncurses
        clear
        ./pomodoroout $work_input $break_input
        ;;
    2)
        
        ;;
    3)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid option!"
        ;;
esac
