#!/bin/bash

# Declare an array to save PIDs
declare -a pids

show_logo() {
    cat << "EOF"
▗▄▄▖▗▄▄▄▖▗▖ ▗▖▗▄▄▄▗▖  ▗▖▗▄▖  ▗▄▄▖      Made By: Hamdi Awad 
▐▌     █  ▐▌ ▐▌▐▌  █▝▚▞▘▐▌ ▐▌▐▌                  Omar Walid
 ▝▀▚▖  █  ▐▌ ▐▌▐▌  █ ▐▌ ▐▌ ▐▌ ▝▀▚▖               Omar Abdelrady 
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
    C_BINARY="./assignment_courses"
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
                OUTPUT=$($C_BINARY "1")
                dialog --msgbox "$OUTPUT" 20 80
                                COURSE_ID=$(dialog --inputbox "Enter course ID:" 10 40 2>&1 >/dev/tty)
                                if [[ "$COURSE_ID" =~ ^[1-9][0-9]*$ ]]; then
                                    $C_BINARY 3 $COURSE_ID
                                    dialog --msgbox "Course '$COURSE_ID' deleted successfully!" 10 40
                                else
                                    dialog --msgbox "Course ID is required to be a positive number." 10 40
                                fi
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
                                if [[ "$COURSE_ID" =~ ^[1-9][0-9]*$ ]]; then
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
                            
                            if [[ "$COURSE_ID" && "$DIFFICULTY" && "$TIME_REQUIRED" =~ ^[1-9][0-9]*$ && -n "$DUE_DATE" && -n "$ASSIGNMENT_NAME" ]]; then
                                $C_BINARY 4 3 "$COURSE_ID" "$ASSIGNMENT_NAME" "$DIFFICULTY" "$TIME_REQUIRED" "$DUE_DATE"
                                dialog --msgbox "Assignment '$ASSIGNMENT_NAME' added successfully!" 10 40
                            else
                                dialog --msgbox "All fields are required to be vaild to add an assignment." 10 40
                            fi
                            ;;
                        4) # Submit Assignment
                                COURSE_ID=$(dialog --inputbox "Enter course ID:" 10 40 2>&1 >/dev/tty)
                                ASSIGNMENT_ID=$(dialog --inputbox "Enter assignment ID:" 10 40 2>&1 >/dev/tty)
                                if [[ "$ASSIGNMENT_ID" && "$COURSE_ID" =~ ^[1-9][0-9]*$ ]]; then
                                    dialog --msgbox "Select the Text file from popup to submit." 10 40
                                    FILE_PATH=$(zenity --file-selection --title="Select Text File" --file-filter="*.txt" 2>/dev/null)
                                     $C_BINARY 4 4 "$COURSE_ID" "$ASSIGNMENT_ID" "$FILE_PATH"
                                    dialog --msgbox "Assignment '$ASSIGNMENT_ID' submitted successfully!" 10 40
                                else
                                    dialog --msgbox "Course ID and Assignment ID is required tobe valid to submit an assignment." 10 40
                                fi
                            clear
                            ;;
                        5) # Delete Assignment
                            
                                COURSE_ID=$(dialog --inputbox "Enter course ID:" 10 40 2>&1 >/dev/tty)
                                ASSIGNMENT_ID=$(dialog --inputbox "Enter assignment ID:" 10 40 2>&1 >/dev/tty)
                                if [[ "$ASSIGNMENT_ID" && "$COURSE_ID" =~ ^[1-9][0-9]*$ ]]; then
                                    $C_BINARY 4 5 "$COURSE_ID" "$ASSIGNMENT_ID"
                                    dialog --msgbox "Assignment '$ASSIGNMENT_ID' deleted successfully!" 10 40
                                else
                                    dialog --msgbox "Course ID and assignment ID are required to delete an assignment." 10 40
                                fi
                            clear
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

gpa_manager() {
    
    while true; do
        COURSES_COUNT=$(dialog --inputbox "Enter the number of subjects:" 10 30 2>&1 >/dev/tty)
        if [[ "$COURSES_COUNT" =~ ^[1-9][0-9]*$ ]]; then
            break
        else
            dialog --msgbox "Please enter a valid positive integer for the number of subjects." 10 30
        fi
    done


    if [ -z "$COURSES_COUNT" ]; then
        dialog --msgbox "Number of subjects cannot be empty" 10 30
        exit 1
    fi

    echo "" > subject_data.txt

    for (( i=1; i<=$COURSES_COUNT; i++ ))
    do
        credit_hours=$(dialog --inputbox "Enter credit hours for subject $i:" 10 30 2>&1 >/dev/tty)
        grade=$(dialog --menu "Choose grade for subject $i:" 15 30 10 \
            "4.0" A+ "4.0" A "3.7" A- "3.3" B- "3.0" B "2.7" B- \
            "2.3" C+ "2.0" C "1.7" C- "1.3" D "1.0" D- "0.0" F 2>&1 >/dev/tty)

        echo "$credit_hours $grade" >> subject_data.txt
        clear
    done

    ./gpa_out $COURSES_COUNT subject_data.txt

    rm -f subject_data.txt
}

USER_NAME=$(logname)

cd /home/$USER_NAME/Documents/StudyOS/applications

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=6
TITLE="Main Menu"
MENU="Choose an option:"

OPTIONS=(
    1 "Pomodoro Timer"
    2 "Course and Assignment Manager"
    3 "Music Player"
    4 "PC Info"
    5 "GPA Calculator"
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
            while true; do
                work_input=$(dialog  --clear \
                                --backtitle "StudyOS - Hamdi Awad, Omar Abdulaal, Omar Abdulrady" \
                                --title "Work Session Time" \
                                --inputbox "Please Enter Work Session Time In Minutes:" 8 40 \
                                --output-fd 1)
                if [[ "$work_input" =~ ^[0-9]+$ ]]; then
                    break
                else
                    dialog --msgbox "Please enter a valid number for work session time." 10 40
                fi
            done

            while true; do
                break_input=$(dialog  --clear \
                                --backtitle "StudyOS - Hamdi Awad, Omar Abdulaal, Omar Abdulrady" \
                                --title "Break Session Time" \
                                --inputbox "Please Enter Break Session Time In Minutes:" 8 40 \
                                --output-fd 1)
                if [[ "$break_input" =~ ^[0-9]+$ ]]; then
                    break
                else
                    dialog --msgbox "Please enter a valid number for break session time." 10 40
                fi
            done

            clear
            gnome-terminal -- ./pomodoro $work_input $break_input &
            pids+=($!)
            ;;
        2)
            assignment_manager
            clear
            ;;
        3)
            gnome-terminal -- ./sound_player.sh &
            pids+=($!)
            ;;
        4) 
            temp_file=$(mktemp)
            show_info > "$temp_file"
            dialog --textbox "$temp_file" 20 70
            rm -f "$temp_file"
            ;;
        5)
            gpa_manager
            clear
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
