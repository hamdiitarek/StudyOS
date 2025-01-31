#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' 

# Request sudo permissions
if [ "$EUID" -ne 0 ]; then
echo -e "${RED}Please run as root to be able to install StudyOS."
  exit
fi

# Get the username of the current user
USER_NAME=$(logname)

# Ensure the target directory exists
mkdir -p /home/$USER_NAME/Documents/StudyOS/
sudo chown $USER_NAME:$USER_NAME /home/$USER_NAME/Documents/StudyOS/

TARGET_DIR="/home/$USER_NAME/Documents/StudyOS/applications"
if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR does not exist. Creating it..."
    mkdir -p "$TARGET_DIR"
fi


# Install dependencies
echo -e "${GREEN}Installing dependencies..."
apt -y install libncurses5-dev libncursesw5-dev
apt -y install zenity
apt -y install dialog
apt -y install libnotify-bin
apt -y install alsa-utils

# Copy file to /usr/local/bin
cp ./main2.sh /usr/local/bin/StudyOS
chmod +x /usr/local/bin/StudyOS

# Copy the files to the target directory
cp ./sound_player.sh $TARGET_DIR/sound_player.sh
chmod +x $TARGET_DIR/sound_player.sh
cp ./assignment_courses.c $TARGET_DIR/assignment_courses.c
cp ./audio_processor.c $TARGET_DIR/audio_processor.c
cp ./gpa_calculator.c $TARGET_DIR/gpa_calculator.c
cp ./pomodoro.c $TARGET_DIR/pomodoro.c
cp -r ./sounds $TARGET_DIR/sounds


# Change to the target directory for compilation
cd "$TARGET_DIR"

# Define source and binary file variables
C_courses_SOURCE="assignment_courses.c"  
C_courses_BINARY="assignment_courses" 
C_gpa_SOURCE="gpa_calculator.c"
C_gpa_BINARY="gpa_out"
C_audio_SOURCE="audio_processor.c"  
C_audio_BINARY="audio_processor"
C_pomodoro_SOURCE="pomodoro.c"
C_pomodoro_BINARY="pomodoro"

# Function to compile C files
compile_if_needed() {
    SOURCE_FILE=$1
    BINARY_FILE=$2
    
    if [ ! -f "$BINARY_FILE" ]; then
        echo "Compiling $SOURCE_FILE..."
        gcc -pthread -o "$BINARY_FILE" "$SOURCE_FILE"
        if [ $? -ne 0 ]; then
            echo "Error: Compilation of $SOURCE_FILE failed."
            exit 1
        fi
        echo "Compilation of $SOURCE_FILE successful."
    else
        echo "$BINARY_FILE already exists. Skipping compilation."
    fi
}

# Compile the C files
compile_if_needed "$C_courses_SOURCE" "$C_courses_BINARY"
compile_if_needed "$C_gpa_SOURCE" "$C_gpa_BINARY"
compile_if_needed "$C_audio_SOURCE" "$C_audio_BINARY"

gcc -o pomodoro pomodoro.c -lncurses -pthread

sudo chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/Documents/StudyOS/applications/

echo -e "Installation completed successfully. ${NC}\nYou can now run StudyOS by typing 'StudyOS' in the terminal."
