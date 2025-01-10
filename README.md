# StudyOS

## Overview

**StudyOS** is a lightweight, customized operating system designed for educational purposes. It combines the power of Bash scripting and C programming to deliver essential OS features and creative tools for productivity.

---

## Features

- **Sound Player**: Plays ambient sounds like rain, campfire, and waves.
- **Pomodoro Timer**: A Pomodoro timer to enhance focus and productivity by splitting study time into chunks with breaks.
- **GPA Calculator**: Calculates Grade Point Averages based on user input.
- **Assignment and Course Manager**: Handles courses, assignments, and submissions with shared memory and threading for efficiency.

---

## Installation and Execution Instructions

### Installation

1. Clone the repository or download the source code.
2. Run the installation script to set up the necessary environment and compile binaries:
   ```bash
   sudo ./install.sh
   ```

### Running StudyOS

Start the system by typing (after installation):
```bash
StudyOS
```
Follow the on-screen menu to navigate features.

---

## Components

### Bash Scripts

- **`install.sh`**:
  - Installs necessary dependencies.
  - Sets up directory structures and compiles binaries.

- **`main2.sh`**:
  - Entry point for StudyOS.
  - Displays the main menu and manages feature selection.
  - Calls other scripts and shell files for operations.

- **`sound_player.sh`**:
  - Plays ambient sounds in a loop.
  - Three sounds to choose from: Rain - Campfire - Waves
  - Uses `dialog` for user interaction and manages sound processes.


### C Programs

- **`pomodoro.c`**:
  - Implements a Pomodoro Timer with a visual interface using `ncurses`.
  - Notifies the user when sessions end.
  - Quit session by pressing `q`

- **`gpa_calculator.c`**:
  - Calculates GPA using shared memory for data storage.
  - Spawns child processes for parallel computation.

- **`audio_processor.c`**:
  - Handles audio playback for the Sound Player.
  - Manages playback using threading and process control.

- **`assignment_courses.c`**:
  - Manages courses, assignments, and submissions.
  - Uses shared memory.
  - Updates log files to persist data.

---

## Usage Examples

### Starting StudyOS

![image](https://github.com/user-attachments/assets/cd5f07af-01b3-45c9-a68d-b117eccef706)



### Using the Sound Player

![image](https://github.com/user-attachments/assets/fdb80e83-0682-4468-a556-03a9f4bf6597)



### Managing Courses

![image](https://github.com/user-attachments/assets/751b57c2-fdf5-4e35-aab3-1f4a4ef3137f)

![image](https://github.com/user-attachments/assets/dd6b6e2c-4221-41be-8735-b86c6b8191a4)



### Managing Assignments

![image](https://github.com/user-attachments/assets/dafbb653-ff5d-450b-952c-2be1433ad85b)

![image](https://github.com/user-attachments/assets/7837f1a1-46c7-4fc1-a8b8-3eb7ebb89f5f)



### GPA Calculation

![image](https://github.com/user-attachments/assets/94831919-2e4f-4daa-98a5-75afb186617f)

![image](https://github.com/user-attachments/assets/83385036-59ed-4434-9665-b43c3f101c7b)



### Pomodoro Timer

![image](https://github.com/user-attachments/assets/8e16ccac-0308-46b6-8d31-6d941298ba79)

---

This was a collaborative project for an Operating Systems course done by:
- Hamdi Awad
- Omar Abdelrady
- Omar Walid
  
![image](https://github.com/user-attachments/assets/25527e15-dfe2-4d16-941e-343c5a675f16)


