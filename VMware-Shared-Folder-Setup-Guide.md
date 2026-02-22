# Configure Shared Folder Between Windows Host and Ubuntu VM (VMware Workstation)

## Prerequisites

- VMware Workstation installed on Windows host
- Ubuntu VM running with VMware Tools / open-vm-tools installed
- Files/folder on Windows host you want to share

---

## Step 1: Create a Shared Folder on Windows Host

1. Create a folder on your Windows machine (e.g., `D:\VM Shared` or `C:\Users\YourName\VM Shared`).
2. Place the files you want to share inside this folder.

---

## Step 2: Configure Shared Folder in VMware Workstation

1. Open **VMware Workstation** on Windows.
2. Select your Ubuntu VM (do **not** start it yet, or shut it down).
3. Go to **VM > Settings** (or click "Edit virtual machine settings").
4. Navigate to the **Options** tab.
5. Click **Shared Folders** in the left panel.
6. Under "Folder sharing", select **Always Enabled**.
7. (Optional) Check **Map as a network drive in Windows guests** if needed.
8. Click **Add...** to open the Add Shared Folder Wizard:
   - **Host path**: Browse and select your Windows folder (e.g., `D:\VM Shared`).
   - **Name**: Give it a name (e.g., `VM Shared`). This name will appear inside the VM.
   - **Attributes**: Check **Enable this share** (check **Read-only** if you don't want the VM to modify files).
9. Click **Finish**, then **OK**.

---

## Step 3: Install open-vm-tools in Ubuntu VM

Start your Ubuntu VM and open a terminal:

```bash
sudo apt update
sudo apt install open-vm-tools open-vm-tools-desktop -y
```

> **Note:** If you installed VMware Tools from the VMware ISO, you can skip this step. However, `open-vm-tools` is the recommended approach for Linux guests.

---

## Step 4: Create the Mount Point

```bash
sudo mkdir -p /mnt/hgfs
```

---

## Step 5: Mount the Shared Folder

### Option A: Temporary Mount (lost after reboot)

```bash
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
```

To mount a specific shared folder only:

```bash
sudo vmhgfs-fuse .host:/VM\ Shared /mnt/hgfs -o allow_other
```

### Option B: Persistent Mount via /etc/fstab (survives reboot)

1. Open `/etc/fstab`:

   ```bash
   sudo nano /etc/fstab
   ```

2. Add the following line at the end of the file:

   ```
   vmhgfs-fuse /mnt/hgfs fuse defaults,allow_other 0 0
   ```

   > **Important:** Ensure this line appears only **once** in fstab to avoid duplicate mounts.

3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

4. Reload systemd and mount:

   ```bash
   sudo systemctl daemon-reload
   sudo mount -a
   ```

---

## Step 6: Verify the Shared Folder

```bash
# List available shared folders from VMware
vmware-hgfsclient

# Check if mounted
mount | grep hgfs

# Browse the shared folder
ls -la /mnt/hgfs/

# If your share is named "VM Shared"
ls -la "/mnt/hgfs/VM Shared/"
```

---

## Troubleshooting

### Shared folder is empty or not visible

```bash
# Unmount and remount
sudo umount /mnt/hgfs
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
```

### Permission denied

```bash
# Mount with specific user permissions
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other,uid=$(id -u),gid=$(id -g)
```

### vmhgfs-fuse command not found

```bash
sudo apt install open-vm-tools open-vm-tools-desktop -y
```

### Duplicate mount entries

Check and fix `/etc/fstab` to ensure only one `vmhgfs-fuse` line exists:

```bash
grep hgfs /etc/fstab
```

If duplicates exist, remove extra lines and then:

```bash
sudo umount -a -t fuse.vmhgfs-fuse
sudo systemctl daemon-reload
sudo mount -a
```

### Shared folder not showing after VM resume/suspend

```bash
sudo umount /mnt/hgfs
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
```

---

## Quick Reference

| Task                        | Command                                                    |
| --------------------------- | ---------------------------------------------------------- |
| List shared folders         | `vmware-hgfsclient`                                       |
| Mount all shared folders    | `sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other`       |
| Check mount status          | `mount \| grep hgfs`                                      |
| Browse shared folder        | `ls "/mnt/hgfs/VM Shared/"`                                |
| Unmount                     | `sudo umount /mnt/hgfs`                                   |

---

*Guide created on: 22 February 2026*