#!/bin/bash


show_info() {
    cat << INFO
 ▗▄▄▖▗▄▄▄▖▗▖ ▗▖▗▄▄▄▗▖  ▗▖▗▄▖  ▗▄▄▖      Made By: Hamdi Awad 
▐▌     █  ▐▌ ▐▌▐▌  █▝▚▞▘▐▌ ▐▌▐▌                  Omar Abdulaal
 ▝▀▚▖  █  ▐▌ ▐▌▐▌  █ ▐▌ ▐▌ ▐▌ ▝▀▚▖               Omar Abdalrady 
▗▄▄▞▘  █  ▝▚▄▞▘▐▙▄▄▀ ▐▌ ▝▚▄▞▘▗▄▄▞▘
                                
System Information:
=========================
Hostname: $(hostname)
Kernel: $(uname -r)
CPU: $(grep -m 1 'model name' /proc/cpuinfo | cut -d':' -f2 | xargs)
Memory Usage: $(free -h | grep Mem | awk '{print $3 "/" $2}')
Disk Usage: $(df -h --total | grep total | awk '{print $3 "/" $2}')
Operating System: $(lsb_release -d | cut -f2)
Uptime: $(uptime -p)
=========================
INFO
}


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

while true; do
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
            gnome-terminal -- ./pomodoroout $work_input $break_input
            
            ;;
        2)
            temp_file=$(mktemp)

            show_info > "$temp_file"
            dialog --textbox "$temp_file" 20 70
            rm -f "$temp_file"
            ;;
        3)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option!"
            ;;
    esac
done

