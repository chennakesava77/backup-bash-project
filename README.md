# Automated Backup System (Bash Script)

## Overview
This project provides a **fully automated backup system** written in **Bash**.  
It creates timestamped, compressed `.tar.gz` backups of your files, verifies integrity with SHA256 checksums, rotates old backups using a 7-4-3 policy (daily-weekly-monthly), and can restore files when needed.

---

## Features

### Core Features
- âœ… Compressed backups (`.tar.gz`) with timestamps  
- âœ… Exclude patterns (`.git`, `node_modules`, `.cache`, user-configurable)  
- âœ… SHA256 checksum verification  
- âœ… Backup rotation: 7 daily, 4 weekly, 3 monthly  
- âœ… Configurable via `backup.config`  
- âœ… Logging of all operations  
- âœ… Dry-run mode for testing  
- âœ… Lock file mechanism to prevent concurrent runs  

### Bonus Features
- í¾ Restore backups easily  
- í¾ List all available backups  
- í¾ Disk space check before backup  
- í¾ Simulated email notifications  
- í¾ Incremental backups (only changed files)  

---

## Installation

### Prerequisites
Ensure the following tools are installed:
```bash
tar --version
sha256sum --version
bash --version  # 4.0 or higher
