#!/bin/bash

todo_list=()
size=0
count=0
choice=0

while IFS="|" read -r id desc status; do
    desc=$(echo "$desc" | xargs)
    status=$(echo "$status" | xargs)
    todo_list+=("$id" "$desc" "$status")
    size=$((size+3))
done < todo_list.log

temp_file="todo_list_temp.log"

while [ $choice != 5 ]
do

choice=$(dialog --menu "Choose from the following:" 15 50 5 \
    1 "Show existing To do list" \
    2 "Delete the list" \
    3 "Update the list" \
    4 "Remove a point from the list" \
    5 "Exit ToDo list" \
    3>&1 1>&2 2>&3)

case $choice in
    1)
        dialog --msgbox "Show the todo list and check things off" 6 50
        args=()
        for ((i=0; i<${#todo_list[@]}; i+=3)); do
            args+=("${todo_list[$i]}" "${todo_list[$((i+1))]}" "${todo_list[$((i+2))]}")
        done
        count=$(( ${#args[@]} / 3 ))

        while true; do
            selection=$(dialog --checklist "To-Do List" 15 50 $count "${args[@]}" 3>&1 1>&2 2>&3)

            if [ $? -ne 0 ]; then
                break
            fi

            IFS=' ' read -r -a selected_items <<< "$selection"

            > "$temp_file"

            for ((i=0; i<${#todo_list[@]}; i+=3)); do
                item_id="${todo_list[$i]}"
                task="${todo_list[$((i+1))]}"
                status="${todo_list[$((i+2))]}"

                if [[ " ${selected_items[@]} " =~ " $item_id " ]]; then
                    todo_list[$((i+2))]="on"
                    args[$((i+2))]="on"
                else
                    todo_list[$((i+2))]="off"
                    args[$((i+2))]="off"
                fi

                echo "${todo_list[$i]}|${todo_list[$((i+1))]}|${todo_list[$((i+2))]}" >> "$temp_file"
            done

            mv "$temp_file" todo_list.log

            dialog --msgbox "Your final selections: $selection" 6 50
        done
        ;;
    2)
        dialog --msgbox "Erase the list" 6 50
        > todo_list.log
        unset args
        unset todo_list
        size=0
        ;;
    3)
        dialog --msgbox "Update the list selected" 6 50

        while true; do

            point=$(dialog --clear \
            --backtitle "Dialog Tutorials" \
            --title "Save User Input" \
            --inputbox "Please type the point you want to add to the list:" 10 50 \
            --output-fd 1)

            if [ -z "$point" ]; then
                break
            fi

            todo_list+=("$((todo_list[$((size-3))]+1))" "$point" "off")

            > "$temp_file"

            for ((i=0; i<${#todo_list[@]}; i+=3)); do
                echo "${todo_list[$i]}|${todo_list[$((i+1))]}|${todo_list[$((i+2))]}" >> "$temp_file"
            done

            mv "$temp_file" todo_list.log

            if [ $? -ne 0 ]; then
                dialog --msgbox "Error saving the todo list." 6 50
                break
            fi
            size=$((size+3))
        done
        ;;
    4)
        dialog --msgbox "Remove a point from the list selected" 6 50
        max=${#todo_list[@]}
        while true; do
            new_list=()
            args=()

            for ((i=0; i<$max; i+=3)); do
                # if [ $todo_list[$i] == NULL ]
                # then
                #     continue
                # fi
                args+=("${todo_list[$i]}" "${todo_list[$((i+1))]}")
            done

            count=$(( ${#todo_list[@]} / 2 ))

            point=$(dialog --clear \
                --backtitle "Dialog Tutorials" \
                --title "Save User Input" \
                --menu "Please choose the id of the point you want to delete:" 15 80 $count \
                "${args[@]}" \
                --output-fd 1)


            if [ -z "$point" ]; then
                break
            fi

            > "$temp_file"

            for ((i=0; i<${#todo_list[@]}; i+=3)); do
                item_id="${todo_list[$i]}"
                if [ "$point" != "$item_id" ] && [ "$item_id" != NULL ]; then
                    echo "${todo_list[$i]}|${todo_list[$((i+1))]}|${todo_list[$((i+2))]}" >> "$temp_file"
                fi
            done

            for ((i=0; i<${#todo_list[@]}; i+=3)); do
                item_id="${todo_list[$i]}"
                if [ "$point" != "$item_id" ]; then
                    new_list+=("${todo_list[$i]}" "${todo_list[$((i+1))]}" "${todo_list[$((i+2))]}")
                fi
            done

            unset todo_list

            todo_list=("${new_list[@]}")

            mv "$temp_file" todo_list.log

            size=$((size-3))

            if [ $? -ne 0 ]; then
                dialog --msgbox "Error saving the todo list." 6 50
                break
            fi
        done
        ;;
    *)
        dialog --msgbox "Invalid choice" 6 50
        break
        ;;
esac

done