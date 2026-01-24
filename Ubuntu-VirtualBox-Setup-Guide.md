# Ubuntu VirtualBox Setup Guide for Frappe/ERPNext Development

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Pre-Installation Setup](#pre-installation-setup)
3. [VM Creation](#vm-creation)
4. [Ubuntu Installation](#ubuntu-installation)
5. [Network Configuration](#network-configuration)
6. [SSH Setup](#ssh-setup)
7. [VS Code Remote SSH Setup](#vs-code-remote-ssh-setup)
8. [Post-Installation](#post-installation)
9. [Frappe Installation](#frappe-installation)
10. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Host Machine Specifications
- **OS**: Windows 11 Pro
- **CPU**: Intel Core i5-13500 (14 cores, 20 threads)
- **RAM**: 24 GB
- **Storage**: 100+ GB free space
- **Network**: Ethernet connection

### Recommended VM Allocation
- **RAM**: 8-12 GB (leaving 12+ GB for Windows)
- **CPU**: 6-8 cores (leaving 6+ cores for Windows)
- **Storage**: 100 GB (Fixed size for better performance)
- **Network**: NAT with port forwarding

---

## Pre-Installation Setup

### 1. Disable Windows Hyper-V Features

VirtualBox performs better without Hyper-V conflicts.

**Option A: Via Control Panel**
1. Open **Control Panel** → **Programs** → **Turn Windows features on or off**
2. Uncheck the following:
   - ☐ Hyper-V
   - ☐ Virtual Machine Platform
   - ☐ Windows Hypervisor Platform
   - ☐ Windows Subsystem for Linux (if not needed)
3. Click **OK** and restart your computer

**Option B: Via PowerShell (Administrator)**
```powershell
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
Disable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform
bcdedit /set hypervisorlaunchtype off
```

**Restart your computer after disabling Hyper-V!**

### 2. Verify Hyper-V is Disabled

```cmd
bcdedit /enum | findstr hypervisorlaunchtype
```

Should show: `hypervisorlaunchtype    Off` or return nothing.

### 3. Check System Configuration

```cmd
systeminfo
```

Or get specific details:

```cmd
REM CPU Information
wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors

REM RAM Information
wmic computersystem get TotalPhysicalMemory

REM Disk Space
wmic logicaldisk where drivetype=3 get deviceid,freespace,size
```

### 4. Download Ubuntu Server ISO

Download **Ubuntu 24.04.3 LTS Server**:
- URL: https://ubuntu.com/download/server
- File: `ubuntu-24.04.3-live-server-amd64.iso`
- Save to: `C:\Users\ADMIN\Downloads\`

---

## VM Creation

### Complete VM Setup Commands

Open **Command Prompt as Administrator** and run:

```cmd
cd "C:\Program Files\Oracle\VirtualBox"

REM Create VM
VBoxManage createvm --name "UbuntuFx" --ostype Ubuntu_64 --register --basefolder "C:\Users\ADMIN\VirtualBox VMs"

REM Memory: 8GB (adjust based on your needs)
VBoxManage modifyvm "UbuntuFx" --memory 8192

REM CPU: 6 cores (adjust based on your needs)
VBoxManage modifyvm "UbuntuFx" --cpus 6

REM CPU execution cap (100% = full speed)
VBoxManage modifyvm "UbuntuFx" --cpuexecutioncap 100

REM BIOS firmware (more reliable than EFI for VirtualBox)
VBoxManage modifyvm "UbuntuFx" --firmware bios

REM Enable PAE/NX
VBoxManage modifyvm "UbuntuFx" --pae on

REM I/O APIC (required for multi-core)
VBoxManage modifyvm "UbuntuFx" --ioapic on

REM Video memory: 128MB
VBoxManage modifyvm "UbuntuFx" --vram 128

REM Graphics controller (VMSVGA is best for Linux)
VBoxManage modifyvm "UbuntuFx" --graphicscontroller vmsvga

REM Nested virtualization (for Docker)
VBoxManage modifyvm "UbuntuFx" --nested-hw-virt on

REM Hardware clock in UTC
VBoxManage modifyvm "UbuntuFx" --rtcuseutc on

REM Disable audio (not needed for server)
VBoxManage modifyvm "UbuntuFx" --audio none

REM USB 3.0 controller
VBoxManage modifyvm "UbuntuFx" --usbxhci on

REM Clipboard & drag-drop
VBoxManage modifyvm "UbuntuFx" --clipboard bidirectional
VBoxManage modifyvm "UbuntuFx" --draganddrop bidirectional

REM Boot order
VBoxManage modifyvm "UbuntuFx" --boot1 dvd --boot2 disk --boot3 none --boot4 none

REM Paravirtualization (KVM for Linux)
VBoxManage modifyvm "UbuntuFx" --paravirtprovider kvm

REM Disable remote display
VBoxManage modifyvm "UbuntuFx" --vrde off

REM Create FIXED 100GB disk (better performance)
VBoxManage createmedium disk --filename "C:\Users\ADMIN\VirtualBox VMs\UbuntuFx\UbuntuFx.vdi" --size 102400 --format VDI --variant Fixed

REM Create SATA controller
VBoxManage storagectl "UbuntuFx" --name "SATA" --add sata --controller IntelAhci --portcount 2 --bootable on

REM Attach disk with SSD optimization
VBoxManage storageattach "UbuntuFx" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "C:\Users\ADMIN\VirtualBox VMs\UbuntuFx\UbuntuFx.vdi" --nonrotational on --discard on

REM Create IDE controller for DVD
VBoxManage storagectl "UbuntuFx" --name "IDE" --add ide

REM Attach Ubuntu ISO
VBoxManage storageattach "UbuntuFx" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "C:\Users\ADMIN\Downloads\ubuntu-24.04.3-live-server-amd64.iso"

REM Network: NAT (with port forwarding for SSH access)
VBoxManage modifyvm "UbuntuFx" --nic1 nat
```

### Start the VM

```cmd
VBoxManage startvm "UbuntuFx"
```

---

## Ubuntu Installation

### Installation Steps

1. **Boot Menu**
   - Press **Enter** on "Try or Install Ubuntu Server"

2. **Language Selection**
   - Select **English** → Continue

3. **Keyboard Configuration**
   - Layout: **English (US)** → Done

4. **Installation Type**
   - Select **Ubuntu Server** → Done

5. **Network Configuration**
   - Should auto-configure (leave as default)
   - Note: Will show `10.0.2.15` (NAT address)
   - → Done

6. **Proxy Configuration**
   - Leave blank → Done

7. **Ubuntu Archive Mirror**
   - Leave default → Done

8. **Storage Configuration**
   - Select **Use an entire disk** (default)
   - ✅ **Set up this disk as an LVM group** (recommended)
   - → Done → Continue (confirm)

9. **Profile Setup**
   - Your name: `Frappe Developer` (or your preference)
   - Server name: `ubuntufx`
   - Username: `patersonfx` (or your preference)
   - Password: (your secure password)
   - → Done

10. **SSH Setup**
    - ✅ **Install OpenSSH server** (IMPORTANT!)
    - Don't import SSH identity
    - → Done

11. **Featured Server Snaps**
    - **Don't select anything**
    - → Done

12. **Installation Progress**
    - Wait 5-10 minutes for installation to complete

13. **Reboot**
    - Select **Reboot Now**
    - Press Enter when prompted

### Post-Installation - Remove ISO

After reboot, remove the ISO:

**In Windows Command Prompt:**
```cmd
cd "C:\Program Files\Oracle\VirtualBox"
VBoxManage storageattach "UbuntuFx" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium none
```

---

## Network Configuration

### NAT with Port Forwarding (Recommended)

Port forwarding allows you to access services in the VM from Windows.

**Power off the VM first:**
```cmd
cd "C:\Program Files\Oracle\VirtualBox"
VBoxManage controlvm "UbuntuFx" poweroff
```

Wait 10 seconds, then add port forwarding rules:

```cmd
REM SSH access (Windows port 2222 → VM port 22)
VBoxManage modifyvm "UbuntuFx" --natpf1 "ssh,tcp,,2222,,22"

REM Frappe development server (Windows port 8000 → VM port 8000)
VBoxManage modifyvm "UbuntuFx" --natpf1 "frappe,tcp,,8000,,8000"

REM Frappe SSL (Windows port 8443 → VM port 443)
VBoxManage modifyvm "UbuntuFx" --natpf1 "frappe-ssl,tcp,,8443,,443"

REM MariaDB (optional - Windows port 3307 → VM port 3306)
VBoxManage modifyvm "UbuntuFx" --natpf1 "mariadb,tcp,,3307,,3306"
```

**Verify port forwarding:**
```cmd
VBoxManage showvminfo "UbuntuFx" | findstr "NIC 1 Rule"
```

Expected output:
```
NIC 1 Rule(0):   name = ssh, protocol = tcp, host ip = , host port = 2222, guest ip = , guest port = 22
NIC 1 Rule(1):   name = frappe, protocol = tcp, host ip = , host port = 8000, guest ip = , guest port = 8000
NIC 1 Rule(2):   name = frappe-ssl, protocol = tcp, host ip = , host port = 8443, guest ip = , guest port = 443
```

**Start the VM:**
```cmd
VBoxManage startvm "UbuntuFx"
```

### Accessing Services from Windows

With port forwarding configured:
- **SSH**: `ssh -p 2222 patersonfx@127.0.0.1`
- **Frappe**: `http://localhost:8000`
- **Frappe SSL**: `https://localhost:8443`
- **MariaDB**: `mysql -h 127.0.0.1 -P 3307 -u root -p`

---

## SSH Setup

### Verify SSH is Running in VM

Log into the VM console and check:

```bash
sudo systemctl status ssh
```

If not running:
```bash
sudo systemctl start ssh
sudo systemctl enable ssh
```

Verify SSH is listening:
```bash
sudo ss -tlnp | grep :22
```

Should show: `LISTEN 0  0.0.0.0:22  0.0.0.0:*`

### Test SSH from Windows

**Basic connection:**
```cmd
ssh -p 2222 patersonfx@127.0.0.1
```

You'll be asked:
1. To accept the host key (type `yes`)
2. For your password

### Setup SSH Key Authentication (Recommended)

Avoid password prompts every time:

**On Windows Command Prompt:**

```cmd
REM Generate SSH key pair (if you don't have one)
ssh-keygen -t rsa -b 4096 -f C:\Users\ADMIN\.ssh\id_rsa
```

Press **Enter** for all prompts (default location, no passphrase).

**Copy public key to VM:**
```cmd
type C:\Users\ADMIN\.ssh\id_rsa.pub | ssh -p 2222 patersonfx@127.0.0.1 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

Enter your password when prompted.

**Test passwordless login:**
```cmd
ssh -p 2222 patersonfx@127.0.0.1
```

Should connect without asking for password!

---

## VS Code Remote SSH Setup

### Create SSH Config File

**Create/Edit:** `C:\Users\ADMIN\.ssh\config`

```cmd
notepad C:\Users\ADMIN\.ssh\config
```

**Add this configuration:**
```
Host ubuntufx
    HostName 127.0.0.1
    User patersonfx
    Port 2222
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    IdentityFile C:\Users\ADMIN\.ssh\id_rsa
```

Save and close.

### Connect from VS Code

1. Open **VS Code**
2. Press **F1** or **Ctrl+Shift+P**
3. Type: **Remote-SSH: Connect to Host**
4. Select **ubuntufx** from the list
5. Click **Connect** in the new window
6. Wait for VS Code to install the remote server (first time only)

You're now connected! You can:
- Open folders in the VM
- Edit files directly
- Use the integrated terminal
- Install extensions in the VM

### Troubleshooting VS Code Connection

**If connection fails:**

1. **Verify SSH works from command line:**
   ```cmd
   ssh ubuntufx
   ```

2. **Check VM is running:**
   ```cmd
   VBoxManage list runningvms
   ```

3. **Check port forwarding:**
   ```cmd
   VBoxManage showvminfo "UbuntuFx" | findstr "NIC 1 Rule"
   ```

4. **Restart VS Code** completely

5. **Clear VS Code SSH cache:**
   - Close VS Code
   - Delete: `C:\Users\ADMIN\.vscode\extensions\ms-vscode-remote.remote-ssh-*\`
   - Restart VS Code

---

## Post-Installation

### Update Ubuntu

```bash
sudo apt update
sudo apt upgrade -y
```

### Install Essential Tools

```bash
sudo apt install -y curl wget git vim nano htop net-tools build-essential
```

### Install VirtualBox Guest Additions

Guest Additions improve performance and enable features like clipboard sharing.

```bash
# Install prerequisites
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
```

**In VirtualBox menu:** Devices → Insert Guest Additions CD Image

```bash
# Mount and install
sudo mkdir -p /mnt/cdrom
sudo mount /dev/cdrom /mnt/cdrom
sudo /mnt/cdrom/VBoxLinuxAdditions.run
```

**Reboot:**
```bash
sudo reboot
```

### Check VM Information

```bash
# Check IP address
hostname -I

# Check username
whoami

# Check disk space
df -h

# Check memory
free -h

# Check CPU
lscpu
```

---

## Frappe Installation

### Install Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python dependencies
sudo apt install -y python3-dev python3-pip python3-venv python3-setuptools

# Install Redis
sudo apt install -y redis-server

# Install MariaDB
sudo apt install -y mariadb-server mariadb-client

# Install other dependencies
sudo apt install -y libmysqlclient-dev xvfb libfontconfig wkhtmltopdf
```

### Configure MariaDB

```bash
sudo mysql_secure_installation
```

Settings:
- Switch to unix_socket authentication: **N**
- Change root password: **Y** (set a strong password)
- Remove anonymous users: **Y**
- Disallow root login remotely: **Y**
- Remove test database: **Y**
- Reload privilege tables: **Y**

**Edit MariaDB config:**
```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Add under `[mysqld]`:
```ini
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
```

**Restart MariaDB:**
```bash
sudo systemctl restart mariadb
sudo systemctl enable mariadb
```

### Install Node.js and npm

```bash
# Install Node.js 18.x (recommended for Frappe)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version
npm --version
```

### Install Yarn

```bash
sudo npm install -g yarn
```

### Install Frappe Bench

```bash
# Install bench
sudo pip3 install frappe-bench

# Verify installation
bench --version
```

### Initialize Frappe Bench

```bash
# Create a new bench (as regular user, not root)
cd ~
bench init frappe-bench --frappe-branch version-15

# Change to bench directory
cd frappe-bench

# Create a new site
bench new-site mysite.local

# Install ERPNext (optional)
bench get-app erpnext --branch version-15
bench --site mysite.local install-app erpnext

# Start development server
bench start
```

### Access Frappe from Windows Browser

Open in Windows browser:
- **http://localhost:8000**

Default credentials:
- Username: `Administrator`
- Password: (the one you set during site creation)

### Production Setup (Optional)

```bash
# Install production dependencies
sudo apt install -y supervisor nginx

# Setup production
sudo bench setup production frappe

# Enable scheduler
bench --site mysite.local scheduler enable
```

---

## Troubleshooting

### SSH Connection Issues

**Problem:** `Connection refused` when trying to SSH

**Solutions:**

1. **Verify VM is running:**
   ```cmd
   VBoxManage list runningvms
   ```

2. **Check SSH service in VM:**
   ```bash
   sudo systemctl status ssh
   sudo systemctl start ssh
   ```

3. **Verify port forwarding:**
   ```cmd
   VBoxManage showvminfo "UbuntuFx" | findstr "NIC 1 Rule"
   ```

4. **Test if port is listening on Windows:**
   ```cmd
   netstat -an | findstr :2222
   ```

5. **Recreate port forwarding:**
   ```cmd
   VBoxManage controlvm "UbuntuFx" poweroff
   VBoxManage modifyvm "UbuntuFx" --natpf1 delete "ssh"
   VBoxManage modifyvm "UbuntuFx" --natpf1 "ssh,tcp,,2222,,22"
   VBoxManage startvm "UbuntuFx"
   ```

### VM Boot Issues

**Problem:** Kernel panic or "out of memory" errors

**Solutions:**

1. **Use BIOS firmware instead of EFI:**
   ```cmd
   VBoxManage modifyvm "UbuntuFx" --firmware bios
   ```

2. **Reduce memory allocation:**
   ```cmd
   VBoxManage modifyvm "UbuntuFx" --memory 6144
   ```

3. **Disable 3D acceleration:**
   ```cmd
   VBoxManage modifyvm "UbuntuFx" --accelerate3d off
   ```

### Network Issues

**Problem:** No internet in VM

**Solutions:**

1. **Verify NAT is configured:**
   ```cmd
   VBoxManage showvminfo "UbuntuFx" | findstr "NIC 1"
   ```

2. **Check network in VM:**
   ```bash
   ip addr show
   ping 8.8.8.8
   ```

3. **Restart network:**
   ```bash
   sudo systemctl restart systemd-networkd
   ```

### VS Code Remote SSH Issues

**Problem:** VS Code can't connect

**Solutions:**

1. **Test SSH from command line first:**
   ```cmd
   ssh ubuntufx
   ```

2. **Check SSH config file syntax:**
   ```cmd
   type C:\Users\ADMIN\.ssh\config
   ```

3. **Restart VS Code completely**

4. **Clear VS Code remote cache:**
   ```cmd
   rmdir /s /q "%USERPROFILE%\.vscode\extensions\ms-vscode-remote.remote-ssh-*"
   ```

5. **Check VS Code logs:**
   - View → Output → Remote-SSH

### Performance Issues

**Problem:** VM is slow

**Solutions:**

1. **Increase CPU cores:**
   ```cmd
   VBoxManage modifyvm "UbuntuFx" --cpus 8
   ```

2. **Increase RAM:**
   ```cmd
   VBoxManage modifyvm "UbuntuFx" --memory 12288
   ```

3. **Use fixed-size disk** (better than dynamic)

4. **Install Guest Additions** (see Post-Installation section)

5. **Disable unnecessary services in VM:**
   ```bash
   sudo systemctl disable snapd
   ```

---

## Useful Commands Reference

### VirtualBox Management

```cmd
REM List all VMs
VBoxManage list vms

REM List running VMs
VBoxManage list runningvms

REM Start VM
VBoxManage startvm "UbuntuFx"

REM Start VM headless (no window)
VBoxManage startvm "UbuntuFx" --type headless

REM Power off VM
VBoxManage controlvm "UbuntuFx" poweroff

REM Save VM state (suspend)
VBoxManage controlvm "UbuntuFx" savestate

REM Reset VM
VBoxManage controlvm "UbuntuFx" reset

REM Show VM info
VBoxManage showvminfo "UbuntuFx"

REM Modify VM settings (when powered off)
VBoxManage modifyvm "UbuntuFx" --memory 10240
VBoxManage modifyvm "UbuntuFx" --cpus 8

REM Take snapshot
VBoxManage snapshot "UbuntuFx" take "snapshot-name"

REM Restore snapshot
VBoxManage snapshot "UbuntuFx" restore "snapshot-name"

REM Delete VM
VBoxManage unregistervm "UbuntuFx" --delete
```

### SSH Commands

```cmd
REM Connect to VM
ssh ubuntufx

REM Connect with specific port
ssh -p 2222 patersonfx@127.0.0.1

REM Copy file to VM
scp -P 2222 file.txt patersonfx@127.0.0.1:~/

REM Copy file from VM
scp -P 2222 patersonfx@127.0.0.1:~/file.txt .

REM Copy directory to VM
scp -P 2222 -r folder/ patersonfx@127.0.0.1:~/
```

### Frappe Bench Commands

```bash
# Start development server
bench start

# Create new site
bench new-site sitename.local

# Add site to hosts
bench --site sitename.local add-to-hosts

# Install app
bench get-app appname
bench --site sitename.local install-app appname

# Update bench
bench update

# Migrate site
bench --site sitename.local migrate

# Backup site
bench --site sitename.local backup

# Restore site
bench --site sitename.local restore /path/to/backup.sql.gz

# Enable/disable maintenance mode
bench --site sitename.local set-maintenance-mode on
bench --site sitename.local set-maintenance-mode off

# Clear cache
bench --site sitename.local clear-cache

# Console
bench --site sitename.local console

# Rebuild
bench build

# Restart bench
bench restart
```

---

## Additional Resources

### Documentation
- **Frappe Framework**: https://frappeframework.com/docs
- **ERPNext**: https://docs.erpnext.com
- **VirtualBox Manual**: https://www.virtualbox.org/manual/
- **Ubuntu Server Guide**: https://ubuntu.com/server/docs

### Community
- **Frappe Forum**: https://discuss.frappe.io
- **ERPNext Forum**: https://discuss.erpnext.com

### Tools
- **VirtualBox**: https://www.virtualbox.org
- **VS Code**: https://code.visualstudio.com
- **Remote-SSH Extension**: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh

---

## VM Configuration Summary

| Component | Configuration |
|-----------|---------------|
| **VM Name** | UbuntuFx |
| **OS** | Ubuntu 24.04.3 LTS Server |
| **Firmware** | BIOS |
| **RAM** | 8 GB |
| **CPU** | 6 cores |
| **Storage** | 100 GB (Fixed) |
| **Network** | NAT with port forwarding |
| **SSH Port** | 2222 (host) → 22 (guest) |
| **Frappe Port** | 8000 (host) → 8000 (guest) |
| **Username** | patersonfx |

---

## Notes

- Always power off VM before changing hardware settings
- Take snapshots before major changes
- Regular backups are essential
- Keep Ubuntu and Frappe updated
- Monitor disk space usage regularly
- NAT networking is simpler for development than Bridged

---

**Document Version:** 1.0  
**Last Updated:** January 24, 2026  
**Author:** Sant Bharat Agarwal  
**Purpose:** Complete guide for setting up Ubuntu VM in VirtualBox for Frappe/ERPNext development
