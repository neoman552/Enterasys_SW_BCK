README: Enterasys/Extreme  Automatic Backup Tool

This project provides a lightweight AutoIt-based Graphical User Interface (GUI) to automate the backup of configuration files for Enterasys network switches. It leverages Plink (PuTTY Link) to establish SSH connections and execute remote commands for config generation and TFTP transfer.
Features

    Device Management: Easily add and manage a list of switches via an integrated switch.lst file.

    Real-Time Logging: A terminal-like interface showing live output from the switch during the backup process.

    Automated Workflow:

        Connects via SSH using Plink.

        Generates a configuration file on the switch (e.g., SW-NAME-20260506).

        Transfers the file to a specified TFTP server.

    Integrated TFTP Launcher: Quick-launch button for tftpd64.exe to prepare the environment.

Prerequisites

    Plink.exe: Must be located in the same directory as the script/executable.

    Tftpd64.exe: Required for receiving the configuration files.

    SSH Key Exchange: Before the first run, you must manually connect to each switch via CMD once to accept and cache the SSH host key.

        Command: plink.exe -ssh -l [username] [IP_Address].

Installation & Setup

    Clone or download the project files into a dedicated folder (e.g., C:\NetworkTools\SwitchBackup\).

    Ensure plink.exe and tftpd64.exe are in that folder.

    Run the application.

    Use the AJOUTER SWITCH button to populate your device list.

Usage

    Enter Credentials: Provide your SSH Login and Password in the GUI.

    TFTP IP: Enter the IP address of the machine running the TFTP server.

    Select Switch: Click on a switch from the list on the left.

    Run: Click LANCER BACKUP.

        The log window will display the switch banner and the progress of the show config and copy commands.

Technical Details

    Language: AutoIt v3.

    Connectivity Protocol: SSH-2 (via Plink).

    Security: Uses the -batch flag to prevent script hanging on interactive prompts and -t for terminal emulation.

    Timeout Handling: Implements 5-second Sleep intervals between heavy I/O operations to accommodate the slower processing speeds of older A2-Series hardware.

Troubleshooting

    App won't launch: Check the Task Manager for "ghost" plink.exe or AutoIt3.exe processes and end them.

    Empty Logs: Ensure you have manually accepted the SSH host key in CMD for that specific switch IP.

    TFTP Timeout: Verify that Windows Firewall is not blocking port 69 and that tftpd64.exe is pointing to the correct directory.
