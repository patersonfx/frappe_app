# Important Ubuntu Commands

A comprehensive reference guide for essential Ubuntu/Linux commands.

## System Information

```bash
# Display system information
uname -a                    # All system info
uname -r                    # Kernel version
lsb_release -a             # Ubuntu version details
hostnamectl                # System hostname and OS info

# Hardware information
lscpu                      # CPU information
free -h                    # Memory usage (human-readable)
df -h                      # Disk space usage
lsblk                      # List block devices
sudo dmidecode             # Detailed hardware info

# System monitoring
top                        # Real-time process monitoring
htop                       # Interactive process viewer (better than top)
uptime                     # System uptime and load average
who                        # Show logged-in users
w                          # Show who is logged in and what they're doing
```

## File and Directory Operations

```bash
# Navigation
pwd                        # Print working directory
cd /path/to/directory      # Change directory
cd ~                       # Go to home directory
cd -                       # Go to previous directory
cd ..                      # Go up one directory

# Listing files
ls                         # List files
ls -la                     # List all files with details
ls -lh                     # List with human-readable sizes
ls -ltr                    # List sorted by time (oldest first)
tree                       # Display directory tree structure

# Creating files and directories
touch filename             # Create empty file
mkdir dirname              # Create directory
mkdir -p path/to/dir       # Create nested directories

# Copying and moving
cp source dest             # Copy file
cp -r source dest          # Copy directory recursively
mv source dest             # Move or rename file/directory
rsync -avz source dest     # Sync files (better for large transfers)

# Deleting
rm filename                # Remove file
rm -r dirname              # Remove directory recursively
rm -rf dirname             # Force remove directory (use carefully!)
rmdir dirname              # Remove empty directory

# File permissions
chmod 755 file             # Change file permissions
chmod +x script.sh         # Make file executable
chown user:group file      # Change file ownership
sudo chown -R user:group dir  # Change ownership recursively
```

## File Viewing and Editing

```bash
# View files
cat file                   # Display entire file
less file                  # View file with pagination
more file                  # View file page by page
head -n 20 file           # View first 20 lines
tail -n 20 file           # View last 20 lines
tail -f file              # Follow file updates in real-time

# Searching in files
grep "pattern" file        # Search for pattern in file
grep -r "pattern" dir      # Search recursively in directory
grep -i "pattern" file     # Case-insensitive search
grep -n "pattern" file     # Show line numbers
grep -v "pattern" file     # Invert match (show non-matching lines)

# File comparison
diff file1 file2           # Compare two files
diff -u file1 file2        # Unified diff format

# Text editors
nano file                  # Simple text editor
vim file                   # Advanced text editor
code file                  # VS Code (if installed)
```

## Process Management

```bash
# View processes
ps aux                     # List all processes
ps aux | grep process_name # Find specific process
pgrep process_name         # Get PID of process
pidof process_name         # Get PID by name

# Process control
kill PID                   # Terminate process
kill -9 PID                # Force kill process
killall process_name       # Kill all processes by name
pkill process_name         # Kill processes by pattern

# Background processes
command &                  # Run command in background
jobs                       # List background jobs
fg %1                      # Bring job to foreground
bg %1                      # Resume job in background
nohup command &            # Run command immune to hangups

# System resource usage
top                        # Dynamic process viewer
htop                       # Interactive process viewer
ps aux --sort=-%mem | head # Top memory consumers
ps aux --sort=-%cpu | head # Top CPU consumers
```

## Network Commands

```bash
# Network information
ifconfig                   # Network interface info (legacy)
ip addr show               # Network interface info (modern)
ip route show              # Show routing table
hostname -I                # Show IP addresses

# Network testing
ping google.com            # Test connectivity
ping -c 4 google.com       # Ping 4 times only
traceroute google.com      # Trace route to host
mtr google.com             # Combined ping and traceroute

# Port and connection info
netstat -tuln              # Show listening ports
ss -tuln                   # Socket statistics (modern alternative)
sudo lsof -i :8000         # Show what's using port 8000
sudo netstat -tulpn | grep :8000  # Find process on port

# DNS lookup
nslookup domain.com        # DNS lookup
dig domain.com             # Detailed DNS info
host domain.com            # Simple DNS lookup

# Download files
wget URL                   # Download file
curl -O URL                # Download file
curl -L URL                # Follow redirects
```

## Package Management (APT)

```bash
# Update package lists
sudo apt update            # Update package lists

# Upgrade packages
sudo apt upgrade           # Upgrade installed packages
sudo apt full-upgrade      # Upgrade with dependency handling
sudo apt dist-upgrade      # Upgrade distribution

# Install and remove
sudo apt install package   # Install package
sudo apt remove package    # Remove package
sudo apt purge package     # Remove package with config files
sudo apt autoremove        # Remove unused dependencies

# Search packages
apt search package         # Search for package
apt show package           # Show package details
apt list --installed       # List installed packages

# Clean up
sudo apt clean             # Clear package cache
sudo apt autoclean         # Clear old package cache
```

## Service Management (systemctl)

```bash
# Service status
sudo systemctl status service_name     # Check service status
sudo systemctl is-active service_name  # Check if active
sudo systemctl is-enabled service_name # Check if enabled

# Service control
sudo systemctl start service_name      # Start service
sudo systemctl stop service_name       # Stop service
sudo systemctl restart service_name    # Restart service
sudo systemctl reload service_name     # Reload configuration

# Enable/disable services
sudo systemctl enable service_name     # Enable on boot
sudo systemctl disable service_name    # Disable on boot

# View logs
sudo journalctl -u service_name        # View service logs
sudo journalctl -u service_name -f     # Follow service logs
sudo journalctl -u service_name --since today  # Today's logs
```

## User and Permission Management

```bash
# User operations
whoami                     # Show current user
id                         # Show user and group IDs
sudo adduser username      # Add new user
sudo deluser username      # Delete user
sudo passwd username       # Change user password
su - username              # Switch to user

# Group operations
groups                     # Show current user groups
sudo addgroup groupname    # Create group
sudo usermod -aG group user # Add user to group
sudo delgroup groupname    # Delete group

# Sudo operations
sudo command               # Run command as root
sudo -i                    # Switch to root shell
sudo -u user command       # Run command as specific user
sudo visudo                # Edit sudoers file
```

## Disk and File System

```bash
# Disk usage
df -h                      # Disk space usage
df -i                      # Inode usage
du -sh *                   # Size of each item in current directory
du -sh directory           # Size of specific directory
du -h --max-depth=1        # Size of subdirectories (1 level)

# Find large files
find / -type f -size +100M 2>/dev/null  # Files larger than 100MB
du -ah / | sort -rh | head -20          # Top 20 largest items

# Mount operations
mount                      # Show mounted filesystems
sudo mount /dev/sdb1 /mnt  # Mount device
sudo umount /mnt           # Unmount
lsblk                      # List block devices
```

## Search and Find

```bash
# Find files
find /path -name "filename"              # Find by name
find /path -name "*.py"                  # Find by pattern
find /path -type f -mtime -7             # Modified in last 7 days
find /path -type f -size +10M            # Files larger than 10MB
find /path -name "*.log" -delete         # Find and delete

# Locate (faster, uses database)
sudo updatedb              # Update locate database
locate filename            # Find file by name

# Which and whereis
which command              # Show command path
whereis command            # Show command binary, source, manual
```

## Compression and Archives

```bash
# Tar archives
tar -czf archive.tar.gz directory/    # Create compressed archive
tar -xzf archive.tar.gz               # Extract compressed archive
tar -tzf archive.tar.gz               # List contents
tar -xzf archive.tar.gz -C /path      # Extract to specific path

# Zip archives
zip -r archive.zip directory/         # Create zip archive
unzip archive.zip                     # Extract zip archive
unzip -l archive.zip                  # List zip contents

# Other compression
gzip file                  # Compress file
gunzip file.gz             # Decompress file
bzip2 file                 # Compress with bzip2
bunzip2 file.bz2           # Decompress bzip2
```

## SSH and Remote Operations

```bash
# SSH connection
ssh user@hostname          # Connect to remote host
ssh -p port user@host      # Connect to specific port
ssh -i keyfile user@host   # Connect with key file

# SCP (Secure Copy)
scp file user@host:/path   # Copy file to remote
scp user@host:/path/file . # Copy file from remote
scp -r dir user@host:/path # Copy directory recursively

# SSH keys
ssh-keygen                 # Generate SSH key pair
ssh-copy-id user@host      # Copy public key to remote host

# SFTP
sftp user@host             # Start SFTP session
```

## Environment Variables

```bash
# View variables
env                        # Show all environment variables
echo $PATH                 # Show specific variable
printenv                   # Print environment

# Set variables
export VAR="value"         # Set environment variable
export PATH=$PATH:/new/path # Add to PATH

# Persistent variables
nano ~/.bashrc             # Edit bash configuration
nano ~/.profile            # Edit profile
source ~/.bashrc           # Reload configuration
```

## Shell Scripting Basics

```bash
# Script execution
bash script.sh             # Run bash script
./script.sh                # Run executable script
sh script.sh               # Run with sh

# Shebang (first line of script)
#!/bin/bash                # Use bash interpreter

# Variables
VAR="value"                # Set variable
echo $VAR                  # Use variable

# Conditionals
if [ condition ]; then
    command
fi

# Loops
for i in {1..5}; do
    echo $i
done
```

## System Logs

```bash
# View logs
sudo tail -f /var/log/syslog           # Follow system log
sudo tail -f /var/log/auth.log         # Follow authentication log
sudo less /var/log/syslog              # View system log
sudo journalctl                        # View systemd logs
sudo journalctl -f                     # Follow systemd logs
sudo journalctl --since "1 hour ago"   # Recent logs
sudo journalctl -p err                 # Error messages only
```

## Frappe/ERPNext Specific Commands

```bash
# Bench commands
bench start                # Start Frappe server
bench --site site_name migrate         # Run migrations
bench --site site_name console         # Open Python console
bench --site site_name mariadb         # Open MariaDB console
bench --site site_name backup          # Create backup
bench --site site_name clear-cache     # Clear cache
bench --site site_name clear-website-cache  # Clear website cache

# Bench management
bench update               # Update bench and apps
bench restart              # Restart processes
bench build                # Build assets
bench build --apps app_name  # Build specific app
bench migrate-to version   # Migrate bench version

# Supervisor (production)
sudo supervisorctl status              # Check all processes
sudo supervisorctl restart all         # Restart all processes
sudo supervisorctl restart frappe-bench-web:  # Restart web workers
sudo supervisorctl tail frappe-bench-web:frappe-bench-frappe-web  # View logs

# Nginx
sudo nginx -t              # Test nginx configuration
sudo systemctl reload nginx  # Reload nginx
sudo tail -f /var/log/nginx/error.log  # View nginx errors
```

## Database Operations (MariaDB/MySQL)

```bash
# MySQL/MariaDB access
mysql -u root -p           # Login to MySQL
sudo mysql                 # Login as root (socket auth)

# Database operations (in MySQL shell)
SHOW DATABASES;            # List databases
USE database_name;         # Select database
SHOW TABLES;               # List tables
DESCRIBE table_name;       # Show table structure
SELECT * FROM table LIMIT 10;  # Query table

# Backup and restore
mysqldump -u root -p db_name > backup.sql    # Backup database
mysql -u root -p db_name < backup.sql        # Restore database
mysqldump -u root -p --all-databases > all.sql  # Backup all databases
```

## Performance Monitoring

```bash
# System performance
vmstat 1                   # Virtual memory statistics
iostat                     # CPU and I/O statistics
iotop                      # I/O monitoring by process
sar                        # System activity report

# Network monitoring
iftop                      # Network bandwidth monitoring
nethogs                    # Network traffic by process
tcpdump -i eth0            # Capture network packets
```

## Cron Jobs

```bash
# Cron management
crontab -e                 # Edit user crontab
crontab -l                 # List crontab entries
sudo crontab -e            # Edit root crontab

# Cron format
# * * * * * command
# ┬ ┬ ┬ ┬ ┬
# │ │ │ │ └─── day of week (0-7, 0 and 7 are Sunday)
# │ │ │ └───── month (1-12)
# │ │ └─────── day of month (1-31)
# │ └───────── hour (0-23)
# └─────────── minute (0-59)

# Examples
0 2 * * * /path/to/backup.sh           # Daily at 2 AM
*/15 * * * * /path/to/check.sh         # Every 15 minutes
0 0 * * 0 /path/to/weekly.sh           # Weekly on Sunday
```

## Useful Shortcuts

```bash
# Terminal shortcuts
Ctrl + C                   # Kill current process
Ctrl + Z                   # Suspend current process
Ctrl + D                   # Exit current shell
Ctrl + L                   # Clear screen
Ctrl + R                   # Search command history
Ctrl + A                   # Move to beginning of line
Ctrl + E                   # Move to end of line
Ctrl + U                   # Clear line before cursor
Ctrl + K                   # Clear line after cursor

# History
history                    # Show command history
!n                         # Execute command number n
!!                         # Execute last command
!string                    # Execute last command starting with string
```

## System Maintenance

```bash
# Update system
sudo apt update && sudo apt upgrade -y     # Update and upgrade
sudo apt autoremove -y                     # Remove unused packages
sudo apt clean                             # Clean package cache

# Check disk errors
sudo fsck /dev/sda1        # Check filesystem
sudo badblocks /dev/sda1   # Check for bad blocks

# System reboot and shutdown
sudo reboot                # Reboot system
sudo shutdown -r now       # Reboot now
sudo shutdown -h now       # Shutdown now
sudo shutdown -h +10       # Shutdown in 10 minutes
```

## Troubleshooting

```bash
# Check system logs
dmesg                      # Kernel ring buffer
dmesg | grep -i error      # Kernel errors
journalctl -xe             # Recent systemd logs with explanations

# Check failed services
systemctl --failed         # List failed services
systemctl status service_name  # Check specific service

# Network troubleshooting
sudo netstat -tuln         # Check listening ports
sudo lsof -i :port         # Check what's using a port
ip route get 8.8.8.8       # Check routing

# Process troubleshooting
ps aux | grep process      # Find process
strace -p PID              # Trace system calls
lsof -p PID                # List files opened by process
```

## Tips and Best Practices

1. **Always use `sudo` carefully** - It grants root privileges
2. **Use `man command`** - Read manual pages for detailed information
3. **Use tab completion** - Press Tab to autocomplete commands and paths
4. **Backup before major changes** - Especially configuration files
5. **Test commands in non-production** - Verify before running on live systems
6. **Use `-h` or `--help`** - Most commands have help flags
7. **Pipe commands together** - `command1 | command2` for powerful combinations
8. **Redirect output** - Use `>` to save output to files
9. **Use screen or tmux** - For persistent terminal sessions
10. **Keep system updated** - Regular updates improve security

---

**Note**: Commands marked with `sudo` require administrator privileges. Always be cautious when running commands with elevated permissions.
