# StudyOS

<div align="center">

![StudyOS Logo](https://img.shields.io/badge/StudyOS-Educational%20OS-blue?style=for-the-badge&logo=linux)
![Language](https://img.shields.io/badge/Language-C%20%7C%20Bash-orange?style=for-the-badge)


*A lightweight, educational operating system built for productivity and learning*

</div>

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Components](#components)
- [Screenshots](#screenshots)

## Overview

**StudyOS** is a lightweight, educational operating system designed to demonstrate fundamental OS concepts while providing practical productivity tools for students. Built using a combination of Bash scripting and C programming, StudyOS showcases:

- **Process Management**: Inter-process communication and threading
- **Memory Management**: Shared memory implementation
- **System Programming**: Low-level C programming with system calls
- **User Interface**: Terminal-based applications with ncurses
- **Audio Processing**: Sound management and playback systems

Perfect for computer science students learning operating systems concepts and anyone looking for a minimalist productivity environment.

## Features

### **Ambient Sound Player**
- Three carefully selected ambient sounds: Rain, Campfire, and Ocean Waves
- Loop functionality for continuous playback
- Process management for audio control
- Interactive dialog-based interface

### **Pomodoro Timer**
- Visual ncurses-based interface
- Customizable work and break intervals
- Session tracking and notifications
- Keyboard controls for easy navigation

### **GPA Calculator**
- Accurate Grade Point Average calculations
- Parallel computation using child processes
- Shared memory for efficient data handling
- Support for multiple grading systems

### **Course & Assignment Manager**
- Complete academic workflow management
- Course creation and tracking
- Assignment submission system
- Persistent data storage with log files
- Multi-threaded operations for performance

---

## Installation

### Quick Install

1. **Clone the repository**
   ```bash
   git clone https://github.com/hamdiitarek/StudyOS.git
   cd StudyOS
   ```

2. **Run the installation script**
   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```

3. **Start StudyOS**
   ```bash
   StudyOS
   ```

### Manual Installation

If you prefer to install dependencies manually:

1. **Install dependencies** (Ubuntu/Debian):
   ```bash
   sudo apt update
   sudo apt install gcc libncurses5-dev dialog alsa-utils make
   ```

2. **Install dependencies** (CentOS/RHEL):
   ```bash
   sudo yum install gcc ncurses-devel dialog alsa-utils make
   ```

3. **Compile the C programs**
   ```bash
   gcc -o pomodoro pomodoro.c -lncurses
   gcc -o gpa_calculator gpa_calculator.c
   gcc -o audio_processor audio_processor.c -lpthread
   gcc -o assignment_courses assignment_courses.c -lpthread
   ```

4. **Make scripts executable**
   ```bash
   chmod +x *.sh
   ```

### Verification

After installation, verify StudyOS is working:
```bash
StudyOS --version
```

## Usage

### Starting StudyOS

Launch StudyOS from your terminal:
```bash
StudyOS
```

```
▗▄▄▖▗▄▄▄▖▗▖ ▗▖▗▄▄▄▗▖  ▗▖▗▄▖  ▗▄▄▖
▐▌     █  ▐▌ ▐▌▐▌  █▝▚▞▘▐▌ ▐▌▐▌
 ▝▀▚▖  █  ▐▌ ▐▌▐▌  █ ▐▌ ▐▌ ▐▌ ▝▀▚▖
▗▄▄▞▘  █  ▝▚▄▞▘▐▙▄▄▀ ▐▌ ▝▚▄▞▘▗▄▄▞▘

1) Sound Player
2) Pomodoro Timer
3) GPA Calculator
4) Course Manager
5) System Information
6) Exit
```

### Feature Quick Guide

| Feature | Command | Description |
|---------|---------|-------------|
| Sound Player | Select option 1 | Play ambient sounds for focus |
| Pomodoro Timer | Select option 2 | Time management tool |
| GPA Calculator | Select option 3 | Calculate academic performance |
| Course Manager | Select option 4 | Manage courses and assignments |
| System Info | Select option 5 | Display system information |

### Keyboard Shortcuts

- **Pomodoro Timer**: Press `q` to quit current session
- **Sound Player**: Use dialog navigation (Tab, Enter, Esc)
- **Main Menu**: Use number keys to select options

---

## Components

### Shell Scripts

#### `install.sh`
- **Purpose**: Automated installation and setup
- **Features**:
  - Dependency management and installation
  - Binary compilation with error handling
  - Directory structure creation
  - Permission configuration
  - System compatibility checks

#### `main2.sh`
- **Purpose**: Main system entry point and menu controller
- **Features**:
  - ASCII art logo display
  - Interactive menu system
  - Process management for background tasks
  - System information display
  - Graceful exit handling

#### `sound_player.sh`
- **Purpose**: Ambient sound management system
- **Features**:
  - Three ambient sound options (Rain, Campfire, Waves)
  - Loop playback functionality
  - Dialog-based user interface
  - Process control and cleanup
  - Audio format support (.wav files)

#### `todo.sh`
- **Purpose**: Simple task management utility
- **Features**:
  - Task creation and deletion
  - Persistent storage
  - Command-line interface

### C Programs

#### `pomodoro.c`
- **Purpose**: Productivity timer application
- **Technical Details**:
  - Built with `ncurses` library for terminal UI
  - Real-time countdown display
  - Session management
  - User input handling
  - Visual progress indicators

#### `gpa_calculator.c`
- **Purpose**: Academic performance calculator
- **Technical Details**:
  - Shared memory implementation using `shm_open()`
  - Multi-process architecture with `fork()`
  - Inter-process communication
  - Grade validation and error handling
  - Multiple GPA scales support

#### `audio_processor.c`
- **Purpose**: Audio playback engine
- **Technical Details**:
  - POSIX threading (`pthread`) for concurrent playback
  - Process synchronization
  - Audio stream management
  - Error handling and recovery
  - Memory management for audio buffers

#### `assignment_courses.c`
- **Purpose**: Academic workflow management
- **Technical Details**:
  - Shared memory for data persistence
  - Multi-threading for concurrent operations
  - File I/O for log management
  - Data structures for course/assignment tracking
  - Thread synchronization with mutexes

### File Structure

```
StudyOS/
├── sounds/              # Audio files directory
│   ├── rain.wav            # Rain ambient sound
│   ├── campfire.wav        # Campfire ambient sound
│   └── waves.wav           # Ocean waves ambient sound
├── install.sh           # Installation script
├── main2.sh             # Main system launcher
├── sound_player.sh      # Sound management
├── todo.sh              # Task management
├── pomodoro.c           # Pomodoro timer source
├── gpa_calculator.c     # GPA calculator source
├── audio_processor.c    # Audio engine source
├── assignment_courses.c # Course manager source
└── README.md            # This documentation
```

---

## Screenshots

### Main Interface
*StudyOS welcome screen with system information and main menu*

![StudyOS Main Interface](https://github.com/user-attachments/assets/cd5f07af-01b3-45c9-a68d-b117eccef706)

### Sound Player
*Ambient sound selection dialog with three calming options*

![Sound Player Interface](https://github.com/user-attachments/assets/fdb80e83-0682-4468-a556-03a9f4bf6597)

### Course Management
*Course creation and management interface*

![Course Management](https://github.com/user-attachments/assets/751b57c2-fdf5-4e35-aab3-1f4a4ef3137f)

*Course listing and details view*

![Course Details](https://github.com/user-attachments/assets/dd6b6e2c-4221-41be-8735-b86c6b8191a4)

### Assignment Management
*Assignment creation and tracking system*

![Assignment Management](https://github.com/user-attachments/assets/dafbb653-ff5d-450b-952c-2be1433ad85b)

*Assignment details and submission interface*

![Assignment Details](https://github.com/user-attachments/assets/7837f1a1-46c7-4fc1-a8b8-3eb7ebb89f5f)

### GPA Calculator
*Grade input interface for GPA calculation*

![GPA Calculator Input](https://github.com/user-attachments/assets/94831919-2e4f-4daa-98a5-75afb186617f)

*GPA calculation results and analysis*

![GPA Results](https://github.com/user-attachments/assets/83385036-59ed-4434-9665-b43c3f101c7b)

### Pomodoro Timer
*Visual timer interface with countdown display*

![Pomodoro Timer](https://github.com/user-attachments/assets/8e16ccac-0308-46b6-8d31-6d941298ba79)

---

This was a collaborative project for an Operating Systems course done by:
- Hamdi Awad
- Omar Walid
- Omar Abdelrady
  
![image](https://github.com/user-attachments/assets/115ee2a8-75e8-48df-a6b7-073ab7555fe5)



