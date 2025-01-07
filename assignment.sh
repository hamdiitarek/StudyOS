#!/bin/bash

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
