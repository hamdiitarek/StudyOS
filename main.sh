#!/bin/bash

# Declare an array to save PIDs
declare -a pids

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


course_manager() {
    C_SOURCE="course.c"
    C_BINARY="./course_out"
    HEIGHT=15
    WIDTH=40
    CHOICE_HEIGHT=6
    TITLE="Course Management System"
    MENU="Choose an option:"

    rubbish="rubbish"
    choice=0

    OPTIONS=(
        1 "Show existing Courses"
        2 "Delete all Courses"
        3 "Add Course"
        4 "Delete Course"
        5 "Check Assignments"
    )

    if [ ! -f "$C_BINARY" ]; then
        echo "Compiling $C_SOURCE..."
        gcc -pthread -o "$C_BINARY" "$C_SOURCE"
        if [ $? -ne 0 ]; then
            echo "Error: Compilation failed."
            exit 1
        fi
        echo "Compilation successful."
    fi

    LOG_FILE="courses.log"
    if [ ! -f "$LOG_FILE" ]; then
        echo "Creating courses.log file..."
        touch "$LOG_FILE"
        if [ $? -ne 0 ]; then
            echo "Error: Could not create courses.log file."
            exit 1
        fi
        echo "courses.log file created successfully."
    fi

    while true
    do

        choice=$(dialog --clear \
                    --title "$TITLE" \
                    --menu "$MENU" \
                    $HEIGHT $WIDTH $CHOICE_HEIGHT \
                    "${OPTIONS[@]}" \
                    2>&1 >/dev/tty)
        clear

        case $choice in
            1)
                dialog --msgbox "Show the existing Courses" 6 50
                $C_BINARY 1 $rubbish
                ;;
            2)
                dialog --msgbox "Deleting all the Courses" 6 50
                $C_BINARY 2 $rubbish
                ;;
            3)
                dialog --msgbox "Adding a Course" 6 50
                subject=$(dialog --title "Subject Input" --inputbox "Enter the subject name:" 10 50 3>&1 1>&2 2>&3)
                $C_BINARY 3 "$subject"
                ;;
            4)
                dialog --msgbox "Deleting a Course" 6 50
                dialog --title "Log File" --textbox "courses.log" 15 50
                course_id=$(dialog --title "Input ID" --inputbox "Enter an integer ID:" 15 50 3>&1 1>&2 2>&3)
                $C_BINARY 4 $course_id
                ;;
            *)
                dialog --msgbox "Exit" 6 50
                clear
                exit 0
                ;;
        esac

    done
}


assignment_manager() {
    # Variables
    C_SOURCE="assignment_manager.c"
    C_BINARY="./assignment_manager"
    HEIGHT=15
    WIDTH=40
    CHOICE_HEIGHT=6
    TITLE="Assignment Management System"
    MENU="Choose an option:"

    # Dialog menu options
    OPTIONS=(
        1 "View All Assignments"
        2 "View Course Assignments"
        3 "Add Assignment"
        4 "Submit Assignment"
        5 "Delete Assignment"
        6 "Exit"
    )

    # Check if the C binary exists; compile if needed
    if [ ! -f "$C_BINARY" ]; then
        echo "Compiling $C_SOURCE..."
        gcc -pthread -o "$C_BINARY" "$C_SOURCE"
        if [ $? -ne 0 ]; then
            echo "Error: Compilation failed."
            exit 1
        fi
        echo "Compilation successful."
    fi

    # Check if the courses.log file exists; create if needed
    LOG_FILE="courses.log"
    if [ ! -f "$LOG_FILE" ]; then
        echo "Creating courses.log file..."
        touch "$LOG_FILE"
        if [ $? -ne 0 ]; then
            echo "Error: Could not create courses.log file."
            exit 1
        fi
        echo "courses.log file created successfully."
    fi

    # Main menu loop
    while true; do
        CHOICE=$(dialog --clear \
                    --title "$TITLE" \
                    --menu "$MENU" \
                    $HEIGHT $WIDTH $CHOICE_HEIGHT \
                    "${OPTIONS[@]}" \
                    2>&1 >/dev/tty)

        clear

        case $CHOICE in
            1) # View All Assignments
                OUTPUT=$(./assignment_manager)
                dialog --msgbox "$OUTPUT" 20 80
                ;;
            2) # View Course Assignments
                COURSE_ID=$(dialog --inputbox "Enter course ID:" 10 40 2>&1 >/dev/tty)
                clear

                if [[ -n "$COURSE_ID" ]]; then
                    OUTPUT=$($C_BINARY "2" "$COURSE_ID")
                    dialog --msgbox "$OUTPUT" 20 80
                else
                    dialog --msgbox "Course ID is required to view assignments." 10 40
                fi
                
                ;;
            3) # Add Assignment
                COURSE_ID=$(dialog --inputbox "Enter course ID:" 10 40 2>&1 >/dev/tty)
                ASSIGNMENT_NAME=$(dialog --inputbox "Enter assignment name:" 10 40 2>&1 >/dev/tty)
                DIFFICULTY=$(dialog --inputbox "Enter difficulty level (1-10):" 10 40 2>&1 >/dev/tty)
                TIME_REQUIRED=$(dialog --inputbox "Enter estimated time (hours):" 10 40 2>&1 >/dev/tty)
                DUE_DATE=$(dialog --calendar 'Enter Due Date'  5 50 1 1 2025 2>&1 >/dev/tty)
                clear
                
                if [[ -n "$COURSE_ID" && -n "$ASSIGNMENT_NAME" && -n "$DIFFICULTY" && -n "$TIME_REQUIRED" && -n "$DUE_DATE" ]]; then
                    $C_BINARY 3 "$COURSE_ID" "$ASSIGNMENT_NAME" "$DIFFICULTY" "$TIME_REQUIRED" "$DUE_DATE"
                    dialog --msgbox "Assignment '$ASSIGNMENT_NAME' added successfully!" 10 40
                else
                    dialog --msgbox "All fields are required to add an assignment." 10 40
                fi
                ;;
            4) # Submit Assignment
                COURSE_ID=$(dialog --inputbox "Enter course ID:" 10 40 2>&1 >/dev/tty)
                ASSIGNMENT_ID=$(dialog --inputbox "Enter assignment ID:" 10 40 2>&1 >/dev/tty)
                dialog --msgbox "Select the Text file from popup to submit." 10 40
                FILE_PATH=$(zenity --file-selection --title="Select PDF File" --file-filter="*.txt" 2>/dev/null)
                clear

                if [[ -n "$COURSE_ID" && -n "$ASSIGNMENT_ID" && -n "$FILE_PATH" ]]; then
                    $C_BINARY 4 "$COURSE_ID" "$ASSIGNMENT_ID" "$FILE_PATH"
                    dialog --msgbox "Assignment '$ASSIGNMENT_ID' submitted successfully!" 10 40
                else
                    dialog --msgbox "Course ID, assignment ID, and file path are required to submit an assignment." 10 40
                fi
                ;;
            5) # Delete Assignment
                COURSE_ID=$(dialog --inputbox "Enter course ID:" 10 40 2>&1 >/dev/tty)
                ASSIGNMENT_ID=$(dialog --inputbox "Enter assignment ID:" 10 40 2>&1 >/dev/tty)
                clear

                if [[ -n "$COURSE_ID" && -n "$ASSIGNMENT_ID" ]]; then
                    $C_BINARY 5 "$COURSE_ID" "$ASSIGNMENT_ID"
                    dialog --msgbox "Assignment '$ASSIGNMENT_ID' deleted successfully!" 10 40
                else
                    dialog --msgbox "Course ID and assignment ID are required to delete an assignment." 10 40
                fi
                ;;
            6) # Exit
                dialog --msgbox "Goodbye!" 10 40
                clear
                exit 0
                ;;
            *) # Invalid choice
                exit 0
                ;;
        esac
    done
}


HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=6
TITLE="Main Menu"
MENU="Choose an option:"

OPTIONS=(
    1 "Pomodoro Timer"
    2 "Course Manager"
    3 "Assignment Manager"
    4 "Music Player"
    5 "PC Info"
    6 "Exit"
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
            setsid gnome-terminal -- ./pomodoroout $work_input $break_input &
            pids+=($!)
            ;;
        2)
            course_manager
            ;;
        3)
            assignment_manager
            ;;
        4)
            setsid gnome-terminal -- ./sound_player.sh &
            pids+=($!)
            ;;
        5) 
            temp_file=$(mktemp)
            show_info > "$temp_file"
            dialog --textbox "$temp_file" 20 70
            rm -f "$temp_file"
            ;;
        6)
            dialog --msgbox "Goodbye!" 10 40
            kill -9 "${pids[@]}"
            clear
            exit 0
            ;;
        *)
            echo "Invalid option!"
            ;;
    esac
done
