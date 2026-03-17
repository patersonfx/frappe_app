# VS Code Remote Development Through Iraje PAM

## Overview

This document outlines the problem, solution, and step-by-step process for connecting VS Code to a remote Ubuntu server accessed through Iraje Privileged Access Management (PAM) at B&K Securities.

---

## The Problem

### Access Chain

The development server (`192.168.91.89`) is only accessible through a multi-hop access chain controlled by Iraje PAM:

```
Local PC (Browser)
    ↓ Windows App (Azure Virtual Desktop)
Techsupport-MS (Windows VM - 192.168.91.102)
    ↓ Edge Browser
Iraje PAM Portal (https://iraje.360.one)
    ↓ Access Control Directory (ACD)
SuperPuTTY → SSH → Ubuntu 22.04.5 LTS (LinuxL3@192.168.91.89)
```

### Key Constraints

- **No direct SSH access** from local PC to the Ubuntu server
- **Iraje manages SSH credentials** — passwords are auto-injected through SuperPuTTY; the user never sees the actual password
- **Ubuntu server has no outbound internet access** (SSL connections are blocked by firewall)
- **Home directory for LinuxL3 doesn't exist** (`/home/LinuxL3` — "No such file or directory")
- **SuperPuTTY terminal only** — limited to a basic terminal session, not ideal for development

### Why Standard VS Code Remote-SSH Doesn't Work

- Cannot SSH directly from local PC to `192.168.91.89`
- SSH tunnel (`ssh -L`) not possible since there's no direct CLI access to Iraje gateway
- Iraje controls and rotates passwords automatically

---

## The Solution: VS Code Remote Tunnels

VS Code Remote Tunnels creates a secure connection between your local VS Code and the remote server through Microsoft's tunnel relay service. This bypasses the need for direct SSH access.

### Prerequisites

- Outbound HTTPS access from the Ubuntu server to VS Code tunnel domains
- A GitHub account for tunnel authentication
- The `./code` CLI binary on the Ubuntu server

---

## Step-by-Step Setup

### Step 1: Request Firewall Whitelist

The Ubuntu server initially had no outbound internet access. The following domains need to be whitelisted on the firewall/proxy for the server `192.168.91.89`:

- `code.visualstudio.com`
- `update.code.visualstudio.com`
- `vscode.download.prss.microsoft.com`
- `global.rel.tunnels.api.visualstudio.com`
- `*.rel.tunnels.api.visualstudio.com`

Send a request to the IT helpdesk with the server IP and the above domains. Mention the specific errors: "SSL connection reset" and "Could not resolve host" on port 443.

### Step 2: Fix Home Directory (If Missing)

If `/home/LinuxL3` doesn't exist, the `curl` command will fail with "Permission denied" when trying to write files. Either create the directory or use `/tmp`:

```bash
# Option A: Create home directory (requires sudo)
sudo mkdir -p /home/LinuxL3
sudo chown LinuxL3:LinuxL3 /home/LinuxL3

# Option B: Use /tmp as a workaround
cd /tmp
```

### Step 3: Download VS Code CLI

Connect to the Ubuntu server through the normal Iraje flow, then run:

```bash
cd /tmp
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' -o vscode_cli.tar.gz
```

### Step 4: Extract and Start the Tunnel

```bash
tar -xf vscode_cli.tar.gz
./code tunnel
```

The CLI will prompt you to:

1. Open a GitHub device activation URL
2. Enter a code displayed in the terminal
3. Name the tunnel machine (e.g., `linuxl3` or `ubuntu-dev`)

### Step 5: Authenticate with GitHub

- Open the URL shown in the terminal in any browser
- Enter the device code
- Authorize the VS Code tunnel
- You should see "Congratulations, you're all set!" on GitHub

### Step 6: Connect from Your Local VS Code or Browser

**Option A — Browser (easiest):**

Navigate to `https://vscode.dev/tunnel/<tunnel-name>` (e.g., `https://vscode.dev/tunnel/linuxl3`)

**Option B — VS Code Desktop App:**

1. Install the **"Remote - Tunnels"** extension
2. Press `Ctrl+Shift+P` → "Remote-Tunnels: Connect to Tunnel"
3. Sign in with the same GitHub account
4. Select your tunnel from the list

### Step 7: Open the Frappe Bench Folder

Once connected, the terminal may default to `/tmp` or `/home/LinuxL3`. To open the correct workspace:

1. **File → Open Folder**
2. Enter: `/home/frappe/frappe-bench`
3. Click OK

### Step 8: Activate Virtual Environment

In the VS Code terminal:

```bash
source /home/frappe/frappe-bench/env/bin/activate
```

### Step 9: Navigate to Your App

Always use full paths since `~` resolves to `/home/LinuxL3`:

```bash
cd /home/frappe/frappe-bench/apps/compliance
```

---

## Keeping the Tunnel Alive

### Problem

If the Iraje/SuperPuTTY session disconnects, the `./code tunnel` process dies.

### Solution: Run as Background Process

```bash
cd /tmp
nohup ./code tunnel > /tmp/vscode-tunnel.log 2>&1 &
```

This keeps the tunnel running even after the SSH session ends.

### Solution: Run as systemd Service (Recommended)

```bash
sudo tee /etc/systemd/system/code-tunnel.service << EOF
[Unit]
Description=VS Code Tunnel
After=network.target

[Service]
User=LinuxL3
ExecStart=/tmp/code tunnel
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable code-tunnel
sudo systemctl start code-tunnel
```

This auto-starts on boot and restarts on crash.

---

## Managing the Tunnel

### Disconnect the Tunnel

```bash
# If running in foreground
Ctrl+C

# If running with nohup (background)
pkill -f "code tunnel"

# If running as systemd service
sudo systemctl stop code-tunnel
```

### Check Tunnel Status

```bash
# Background process
ps aux | grep "code tunnel"

# Systemd service
sudo systemctl status code-tunnel
```

### View Tunnel Logs

```bash
cat /tmp/vscode-tunnel.log
```

---

## Server Details

| Property        | Value                          |
|-----------------|--------------------------------|
| Server IP       | 192.168.91.89                  |
| Username        | LinuxL3                        |
| OS              | Ubuntu 22.04.5 LTS             |
| Kernel          | Linux 5.15.0-170-generic x86_64|
| Frappe User     | frappe (UID 1005)              |
| Frappe Home     | /home/frappe                   |
| Bench Path      | /home/frappe/frappe-bench      |
| Virtual Env     | /home/frappe/frappe-bench/env  |
| Jump Server     | Techsupport-MS (192.168.91.102)|
| Iraje Portal    | https://iraje.360.one          |

## Installed Frappe Apps

| App                 | Description                     |
|---------------------|---------------------------------|
| frappe              | Frappe Framework                |
| erpnext             | ERPNext                         |
| hrms                | HR Management System            |
| payments            | Payments Module                 |
| bksec               | B&K Securities Custom App       |
| compliance          | Compliance Management           |
| dealslip            | Deal Slip Management            |
| email_interceptor   | Email Interceptor               |

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| `Could not chdir to home directory /home/LinuxL3` | Home dir doesn't exist | Use `cd /tmp` or create dir with `sudo mkdir -p /home/LinuxL3` |
| `Failed to create file: Permission denied` | Writing to root `/` | `cd /tmp` first, then download |
| `SSL connection reset by peer` | Firewall blocking outbound HTTPS | Request IT to whitelist VS Code domains |
| `Could not resolve host` | DNS not resolving external domains | Same as above — firewall/DNS whitelist needed |
| `sudo` password not working in VS Code terminal | Iraje manages credentials | Use SuperPuTTY for `sudo` commands |
| `cd ~/frappe-bench` fails | `~` resolves to `/home/LinuxL3` | Use full path: `cd /home/frappe/frappe-bench` |
| Tunnel disconnects after session ends | Process tied to SSH session | Use `nohup` or systemd service |

---

## Notes

- **VS Code Tunnel has no idle timeout** — it stays connected as long as the process runs
- **One tunnel per GitHub account per machine** — you can't run multiple tunnels on the same machine with the same account
- **`sudo` commands** should be run in the SuperPuTTY session (where Iraje injects credentials), not in VS Code terminal
- **File permissions** — you're logged in as `LinuxL3`, not `frappe`. You can browse files but may hit permission issues when editing. For bench commands, switch user in SuperPuTTY: `sudo su - frappe`

---

*Document Created: March 10, 2026*
*Author: Sant Agarwal*
*Organization: Batlivala & Karani Securities India Pvt. Ltd.*
