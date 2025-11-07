# Automated Backup System (Bash Script)
# project Summery:

Objective: Create a Bash script to automate file backups, ensure integrity, manage storage, and allow restoration.

Key Features: Compressed .tar.gz backups, SHA256 checksums, smart rotation (7 daily, 4 weekly, 3 monthly), incremental backups, dry-run mode, logging, and restore functionality.

Outcome: Fully tested script that automates backups, prevents data loss, saves disk space, and allows easy restoration of files.

Challenges: Handling backup rotation, preventing data loss, implementing incremental backups, resolving merge conflicts in Git.

Tools Used: Bash, tar, sha256sum, Git, GitHub.

## Overview
This project provides a **fully automated backup system** written in **Bash**.  
It creates timestamped, compressed `.tar.gz` backups of your files, verifies integrity with SHA256 checksums, rotates old backups using a 7-4-3 policy (daily-weekly-monthly), and can restore files when needed.

---

## Features

### Core Features
- ✅ Compressed backups (`.tar.gz`) with timestamps  
- ✅ Exclude patterns (`.git`, `node_modules`, `.cache`, user-configurable)  
- ✅ SHA256 checksum verification  
- ✅ Backup rotation: 7 daily, 4 weekly, 3 monthly  
- ✅ Configurable via `backup.config`  
- ✅ Logging of all operations  
- ✅ Dry-run mode for testing  
- ✅ Lock file mechanism to prevent concurrent runs  

### Bonus Features
- Restore backups easily  
- List all available backups  
-  Disk space check before backup  
-  Simulated email notifications  
-  Incremental backups (only changed files)  

---

## Installation

### Prerequisites
Ensure the following tools are installed:
```bash
tar --version
sha256sum --version
bash --version  # 4.0 or higher





#This script automates backing up important files on your computer.  
It:

- Creates compressed `.tar.gz` backups of folders.
- Automatically removes old backups to save space.
- Verifies backup integrity using SHA256 checksums.
- Can restore files if something is lost.

**Why it is useful:**  
Manually backing up is slow and easy to forget. This script ensures your data is safe, saves disk space, and lets you restore files easily.

---

## B. How to Use It

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/backup-bash-project.git
cd backup-bash-project

# Make the script executable
chmod +x backup.sh

# Edit config to suit your needs
nano backup.config

#Basic commands
# Create a full backup
./backup.sh /path/to/folder

# Dry run (simulate backup)
./backup.sh --dry-run /path/to/folder

# List available backups
./backup.sh --list

# Restore a backup
./backup.sh --restore backup-YYYY-MM-DD-HHMM.tar.gz --to /path/to/restore

# Incremental backup (only changed files)
./backup.sh --incremental /path/to/folder

#Folder structure:-
backup-bash-project/
├── backup.sh
├── backup.config
├── README.md
├── Backups/                 # Stored backup files
│   ├── backup-2025-11-06-2000.tar.gz
│   ├── backup-2025-11-06-2000.tar.gz.sha256
│   └── ...
├── backup.log               # Operation logs
├── email.txt                # Simulated notifications
└── backup.snar              # Incremental snapshot

Design Decisions:-

Why Bash: Works on any Linux/Windows system with Git Bash, no dependencies.

Why SHA256: Secure and widely accepted checksum method.

Why Rotation & Lockfile: Prevents disk overuse and simultaneous backups.

Challenges & Solutions:

Rotation logic: solved using date-based sorting and marking backups to keep.

Preventing data loss: dry-run mode and logging before deletion.

Incremental backups: used tar --listed-incremental and snapshot file.

 Design Decisions

Why Bash: It works on Linux and Windows (with Git Bash) without installing anything extra.

Why SHA256: It’s a secure and reliable way to check that backups are not corrupted.

Why Rotation & Lockfile: Rotation automatically deletes old backups to save space, and the lockfile prevents two backups from running at the same time.

Challenges & Solutions:

Rotation logic: Figured out which backups to keep by checking their dates.

Preventing data loss: Used dry-run mode and logs to make sure nothing is deleted by mistake.

Incremental backups: Only saves files that changed since the last backup using a snapshot file.

Testing

Created a test folder with sample files, including .git and node_modules.

Ran all commands: dry-run, full backup, incremental backup, and restore.

Verified backups with checksums and by extracting them.

Simulated multiple backup dates to test rotation.

Example Output:

$ ./backup.sh ~/test
Backup created: Backups/backup-2025-11-06-2000.tar.gz
Checksum verified: OK
Old backups deleted: backup-2025-10-30-1200.tar.gz

Known Limitations

Only works on your computer; no remote backups yet.

Backups are not encrypted.

Email notifications are just written to a file, not really sent.

Compression level cannot be changed (default gzip is used).

Backup deletion depends on filenames, not actual creation dates.

Examples

Creating a backup:

./backup.sh ~/test


Multiple backups over several days:
Use touch -t to change file timestamps and run backups repeatedly.

Automatic deletion of old backups:
Backups older than 7 daily, 4 weekly, and 3 monthly are automatically removed.

Restoring a backup:

./backup.sh --restore Backups/backup-2025-11-06-2000.tar.gz --to ~/restored


Dry run mode (test without creating backups):

./backup.sh --dry-run ~/test


Error handling:
Trying to backup a folder that doesn’t exist will show an error and log it without crashing the script.

##Position/Title: Developer & Automation Engineer

Responsibilities:

Script Development: Designed and implemented a fully automated backup system using Bash scripting.

Configuration Management: Created a flexible backup.config file for user-defined settings.

Backup Automation: Implemented features such as timestamped backups, checksum verification, rotation (7-4-3 daily-weekly-monthly policy), incremental backups, and dry-run mode.

Error Handling & Logging: Ensured robust error handling, logging, and lockfile mechanism to prevent concurrent runs.

Testing & Validation: Conducted extensive testing, including dry runs, incremental backups, restores, and rotation policy validation.

Documentation: Prepared comprehensive README and user instructions with examples for installation, usage, and troubleshooting.

Design Decisions: Chose Bash for portability, SHA256 for secure verification, and implemented rotation and incremental logic to prevent data loss.

#Final Summery:-

Developed and implemented a fully automated Bash backup system, including features like timestamped and incremental backups, checksum verification, and rotation policy. Ensured reliability with robust error handling, logging, and dry-run testing, and documented usage for easy adoption.


