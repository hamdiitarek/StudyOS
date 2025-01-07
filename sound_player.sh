#!/bin/bash

while true; do
    choice=$(dialog --clear --title "Sound Player" \
        --menu "Choose a sound to play:" 15 50 5 \
        1 "Rain" \
        2 "Campfire" \
        3 "Waves" \
        4 "Stop Sound" \
        5 "Exit" 3>&1 1>&2 2>&3)

    clear

    # Ensure the audio processor is compiled first
    if [ ! -f "./audio_processor" ]; then
        gcc -pthread -o audio_processor audio_processor.c
        if [ $? -ne 0 ]; then
            echo "Error: Compilation failed."
            exit 1
        fi
    fi

    case $choice in
        1)
            if [ ! -z "$sound_pid" ]; then
                kill $sound_pid
                sound_pid=""
            fi
            sound="rain.wav"
            ./audio_processor "$sound" &
            sound_pid=$!
            dialog --msgbox "Playing Rain sound" 6 40
            ;;
        2)
            if [ ! -z "$sound_pid" ]; then
                kill $sound_pid
                sound_pid=""
            fi
            sound="campfire.wav"
            ./audio_processor "$sound" &
            sound_pid=$!
            dialog --msgbox "Playing Campfire sound" 6 40
            ;;
        3)
            if [ ! -z "$sound_pid" ]; then
                kill $sound_pid
                sound_pid=""
            fi
            sound="waves.wav"
            ./audio_processor "$sound" &
            sound_pid=$!
            dialog --msgbox "Playing Waves sound" 6 40
            ;;
        4)
            if [ ! -z "$sound_pid" ]; then
                kill $sound_pid
                sound_pid=""
                dialog --msgbox "Sound stopped." 6 40
            else
                dialog --msgbox "No sound is currently playing." 6 40
            fi
            ;;
        5)
            if [ ! -z "$sound_pid" ]; then
                kill $sound_pid
            fi
            dialog --msgbox "Exiting." 6 40
            clear
            exit 0
            ;;
        *)
            dialog --msgbox "Invalid choice. Please try again." 6 40
            ;;
    esac
done
