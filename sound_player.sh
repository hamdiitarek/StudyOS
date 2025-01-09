#!/bin/bash

# to ignore the SIGINT and do nothing when the signal is recieved
trap '' SIGINT

while true; do
    choice=$(dialog --clear --title "Sound Player" \
        --menu "Choose a sound to play:" 15 50 5 \
        1 "Rain" \
        2 "Campfire" \
        3 "Waves" \
        4 "Stop Sound" \
        5 "Exit" 3>&1 1>&2 2>&3)

    clear
    gcc -pthread -o audio_processor audio_processor.c
    
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
    esac
done
