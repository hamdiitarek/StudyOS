#!/bin/bash

# Declare an array to save PIDs
declare -a pids

show_logo() {
    cat << "EOF"
▗▄▄▖▗▄▄▄▖▗▖ ▗▖▗▄▄▄▗▖  ▗▖▗▄▖  ▗▄▄▖      Made By: Hamdi Awad 
▐▌     █  ▐▌ ▐▌▐▌  █▝▚▞▘▐▌ ▐▌▐▌                  Omar Abdulaal
 ▝▀▚▖  █  ▐▌ ▐▌▐▌  █ ▐▌ ▐▌ ▐▌ ▝▀▚▖               Omar Abdalrady 
▗▄▄▞▘  █  ▝▚▄▞▘▐▙▄▄▀ ▐▌ ▝▚▄▞▘▗▄▄▞▘                               
EOF
}  

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


assignment_manager() {
    # Course Assignment
    C_SOURCE="assignment_courses.c"
    C_BINARY="./assignmnet_courses_out"
    HEIGHT=15
    WIDTH=40
    CHOICE_HEIGHT=4
    TITLE="Course Management System"
    MENU="Choose an option:"

    # Variables Assignment
    CHOICE_HEIGHT2=5
    TITLE2="Assignment Management System"

    # Dialog Course menu options
    OPTIONS2=(
        1 "Show existing Courses"
        2 "Add Course"
        3 "Delete Course"
        4 "Check Assignments"
    )

    # Dialog Assignment menu options
    OPTIONS3=(
        1 "View All Assignments"
        2 "View Course Assignments"
        3 "Add Assignment"
        4 "Submit Assignment"
        5 "Delete Assignment"
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

    # Courses loop
    while true; 
    do
        choice=$(dialog --clear \
                    --title "$TITLE" \
                    --ok-label "Proceed" \
                    --cancel-label "Back to StudyOS" \
                    --menu "$MENU" \
                    $HEIGHT $WIDTH $CHOICE_HEIGHT \
                    "${OPTIONS2[@]}" \
                    2>&1 >/dev/tty)
        clear

        case $choice in
            1)
                # View All Courses
                OUTPUT=$($C_BINARY "1")
                dialog --msgbox "$OUTPUT" 20 80
                # dialog --msgbox "Show the existing Courses" 6 50
                # $C_BINARY 1 $rubbish
                ;;
            2)
                dialog --msgbox "Adding a Course" 6 50
                clear
                COURSE_NAME=$(dialog --inputbox "Enter course name:" 10 40 2>&1 >/dev/tty)
                clear
                if [[ -n "$COURSE_NAME" ]]; then
                    $C_BINARY 2 "$COURSE_NAME"
                    dialog --msgbox "Course '$COURSE_NAME' added successfully!" 10 40
                else
                    dialog --msgbox "All fields are required to add an assignment." 10 40
                fi
                ;;
            3)
                dialog --msgbox "Deleting a Course" 6 50
                clear
                dialog --title "Log File" --textbox "courses.log" 15 50
                COURSE_ID=$(dialog --inputbox "Enter course ID:" 10 40 2>&1 >/dev/tty)
                $C_BINARY 3 $COURSE_ID
                ;;
            4)
                exit_loop=true
                while $exit_loop 
                do

                    CHOICE=$(dialog --clear \
                        --title "$TITLE2" \
                        --ok-label "Proceed" \
                        --cancel-label "Back to Courses" \
                        --menu "$MENU" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT2 \
                        "${OPTIONS3[@]}" \
                        2>&1 >/dev/tty)

                    clear
                    
                    if [ $? -eq 1 ]; then
                        echo "Returning to Courses Menu..."
                        # You can call another function or menu here instead of breaking
                        exit_loop=false
                    fi

                    case $CHOICE in
                        1) # View All Assignments
                            OUTPUT=$($C_BINARY "4" "1")
                            dialog --msgbox "$OUTPUT" 20 80
                            ;;
                        2) # View Course Assignments
                            COURSE_ID=$(dialog --inputbox "Enter course ID:" 10 40 2>&1 >/dev/tty)
                            clear

                            if [[ -n "$COURSE_ID" ]]; then
                                OUTPUT=$($C_BINARY "4" "2" "$COURSE_ID")
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
                                $C_BINARY 4 3 "$COURSE_ID" "$ASSIGNMENT_NAME" "$DIFFICULTY" "$TIME_REQUIRED" "$DUE_DATE"
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
                                $C_BINARY 4 4 "$COURSE_ID" "$ASSIGNMENT_ID" "$FILE_PATH"
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
                                $C_BINARY 4 5 "$COURSE_ID" "$ASSIGNMENT_ID"
                                dialog --msgbox "Assignment '$ASSIGNMENT_ID' deleted successfully!" 10 40
                            else
                                dialog --msgbox "Course ID and assignment ID are required to delete an assignment." 10 40
                            fi
                            ;;
                        *) # Invalid choice
                            break
                            ;;
                    esac
                done
                
                ;;
            *)
                clear
                return
                ;;
        esac
    done
}


HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=5
TITLE="Main Menu"
MENU="Choose an option:"

OPTIONS=(
    1 "Pomodoro Timer"
    2 "Course and Assignment Manager"
    3 "Music Player"
    4 "PC Info"
)

while true; do
    CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --ok-label "Proceed" \
                --cancel-label "Exit StudyOS" \
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

            gcc -o pomodoroout pomodoro.c -lncurses -pthread
            clear
            setsid gnome-terminal -- ./pomodoroout $work_input $break_input &
            pids+=($!)
            ;;
        2)
            assignment_manager
            clear
            ;;
        3)
            setsid gnome-terminal -- ./sound_player.sh &
            pids+=($!)
            ;;
        4) 
            temp_file=$(mktemp)
            show_info > "$temp_file"
            dialog --textbox "$temp_file" 20 70
            rm -f "$temp_file"
            ;;
        
        *)
            temp_logo=$(mktemp)
            show_logo > "$temp_logo"
            dialog --textbox "$temp_logo" 10 70
            rm -f "$temp_file"
            kill -9 "${pids[@]}"
            clear
            exit 0
            ;;
    esac
done
