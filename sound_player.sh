#!/bin/bash

while true; do
    echo "Choose a sound to play:"
    echo "1) Rain"
    echo "2) Campfire"
    echo "3) Waves"
    echo "4) Stop Sound"
    echo "5) Exit"
    read -p "Enter your choice (1/2/3/4/5): " choice

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
            echo -e "\n\nPlaying Rain sound\n----------------\n"
            ;;
        2)
            if [ ! -z "$sound_pid" ]; then
                kill $sound_pid
                sound_pid=""
                fi
            sound="campfire.wav"
            ./audio_processor "$sound" &
            sound_pid=$!
            echo -e "\n\nPlaying Campfire sound\n----------------\n"
            ;;
        3)
            if [ ! -z "$sound_pid" ]; then
                kill $sound_pid
                sound_pid=""
                fi
            sound="waves.wav"
            ./audio_processor "$sound" &
            sound_pid=$!
            echo -e "\n\nPlaying Waves sound\n----------------\n"
            ;;
        4)
            if [ ! -z "$sound_pid" ]; then
                kill $sound_pid
                sound_pid=""
                echo -e "\n\nSound stopped.\n----------------\n"
            else
                echo -e "\n\nNo sound is currently playing.\n----------------\n"
            fi
            ;;
        5)
            if [ ! -z "$sound_pid" ]; then
                kill $sound_pid
            fi
            echo "Exiting."
            exit 0
            ;;
        *)
            echo -e "\n\nInvalid choice. Please try again.\n\n"
            ;;
    esac
done
