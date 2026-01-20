# Ubuntu 24.04 Static IP Configuration in VirtualBox

A comprehensive guide for configuring static IP addresses in Ubuntu 24.04 LTS running on VirtualBox, covering both NAT and Bridged network configurations.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Understanding Network Modes](#understanding-network-modes)
- [DHCP vs Static IP](#dhcp-vs-static-ip)
- [NAT Configuration](#nat-configuration)
- [Bridged Adapter Configuration](#bridged-adapter-configuration)
- [Troubleshooting](#troubleshooting)
- [Verification Commands](#verification-commands)
- [Common Issues and Solutions](#common-issues-and-solutions)

---

## Prerequisites

- VirtualBox installed on Windows/Linux/macOS host
- Ubuntu 24.04 LTS VM created and running
- Basic understanding of networking concepts
- Sudo/root access to Ubuntu VM

---

## Understanding Network Modes

### VirtualBox Network Modes Comparison

| Feature | NAT | Bridged Adapter | Host-Only |
|---------|-----|-----------------|-----------|
| **VM to Internet** | ✅ Yes | ✅ Yes | ❌ No |
| **Host to VM** | ⚠️ Via Port Forwarding | ✅ Direct | ✅ Direct |
| **VM to VM** | ❌ No | ✅ Yes | ✅ Yes |
| **Other Devices to VM** | ❌ No | ✅ Yes | ❌ No |
| **IP Range** | 10.0.2.0/24 (Default) | Host Network Range | 192.168.56.0/24 (Default) |
| **Use Case** | Development, Testing | Production, Servers | Isolated Testing |

### When to Use Each Mode

**NAT (Network Address Translation)**
- ✅ Simple internet access for VM
- ✅ VM doesn't need to be accessible from network
- ✅ Development environments
- ✅ Quick testing setups
- ❌ Cannot directly access VM from host (needs port forwarding)
- ❌ VMs cannot communicate with each other

**Bridged Adapter**
- ✅ VM appears as separate device on network
- ✅ Full network access (two-way communication)
- ✅ Production servers (ERPNext, web servers)
- ✅ Multiple VMs need to communicate
- ⚠️ Requires available IP addresses on network
- ⚠️ Subject to network policies/firewall rules

---

## DHCP vs Static IP

### What is DHCP?

**DHCP (Dynamic Host Configuration Protocol)** automatically assigns IP addresses and network configuration to devices.

**How DHCP Works:**
1. Device connects to network
2. DHCP server assigns available IP address
3. Provides gateway, DNS, and network settings
4. IP lease expires and renews periodically

**Advantages:**
- ✅ Automatic configuration
- ✅ No manual setup required
- ✅ Prevents IP conflicts
- ✅ Easy for mobile/temporary devices

**Disadvantages:**
- ❌ IP address can change
- ❌ Harder to maintain consistent access
- ❌ Not suitable for servers

### What is Static IP?

**Static IP** is a manually configured, permanent IP address that doesn't change.

**Advantages:**
- ✅ IP address never changes
- ✅ Reliable for servers and services
- ✅ Easier to configure firewall rules
- ✅ Consistent remote access

**Disadvantages:**
- ⚠️ Manual configuration required
- ⚠️ Must manually avoid IP conflicts
- ⚠️ Needs network planning

### When to Use Static IP

Use Static IP when:
- Running a server (web, database, ERPNext)
- Need consistent remote access
- Configuring port forwarding (NAT mode)
- Running production services
- Multiple services depend on fixed IP

---

## NAT Configuration

### Overview

NAT mode allows the VM to access the internet through the host's network connection. The VM gets a private IP in the `10.0.2.0/24` range by default.

### VirtualBox NAT Network Details

- **Default Network**: `10.0.2.0/24`
- **VM IP Range**: `10.0.2.15` to `10.0.2.254`
- **Gateway**: Always `10.0.2.2`
- **DNS**: Forwarded through host

### Step 1: Configure Ubuntu Static IP for NAT

#### Check Current Network Interface

```bash
ip addr show
```

Look for your interface name (usually `enp0s3`, `eth0`, or similar).

#### Check if Netplan Directory Exists

```bash
ls /etc/netplan/
```

If it doesn't exist, create it:

```bash
sudo mkdir -p /etc/netplan
```

#### Create Netplan Configuration

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

#### Add Configuration for NAT

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:  # Replace with your interface name
      dhcp4: no
      addresses:
        - 10.0.2.15/24  # Your static IP
      routes:
        - to: default
          via: 10.0.2.2  # NAT gateway
      nameservers:
        addresses:
          - 8.8.8.8      # Google DNS
          - 8.8.4.4      # Google DNS backup
```

**Important Notes:**
- Replace `enp0s3` with your actual interface name
- You can choose any IP from `10.0.2.15` to `10.0.2.254`
- Gateway is always `10.0.2.2` for VirtualBox NAT

#### Set Proper Permissions

```bash
sudo chmod 600 /etc/netplan/01-netcfg.yaml
```

#### Test Configuration (Safe Method)

```bash
sudo netplan try
```

This applies configuration for 120 seconds. Press `Enter` to accept, or wait for automatic revert if there's an issue.

#### Apply Configuration Permanently

```bash
sudo netplan apply
```

#### Verify Configuration

```bash
# Check IP address
ip addr show enp0s3

# Expected output: inet 10.0.2.15/24

# Check routing
ip route show

# Expected output: default via 10.0.2.2 dev enp0s3

# Test internet connectivity
ping -c 4 8.8.8.8

# Test DNS resolution
ping -c 4 google.com
```

### Step 2: Configure Port Forwarding (NAT Mode)

Since NAT mode isolates the VM, you need port forwarding to access services from the host.

#### Via VirtualBox GUI

1. Select your VM → **Settings**
2. **Network** → **Adapter 1** (ensure it's set to NAT)
3. Click **Advanced** → **Port Forwarding**
4. Add forwarding rules:

**Common Port Forwarding Rules:**

| Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
|------|----------|---------|-----------|----------|------------|
| SSH | TCP | 127.0.0.1 | 2222 | 10.0.2.15 | 22 |
| HTTP | TCP | 127.0.0.1 | 8080 | 10.0.2.15 | 80 |
| HTTPS | TCP | 127.0.0.1 | 8443 | 10.0.2.15 | 443 |
| ERPNext | TCP | 127.0.0.1 | 8000 | 10.0.2.15 | 8000 |
| MariaDB | TCP | 127.0.0.1 | 3306 | 10.0.2.15 | 3306 |

#### Via VBoxManage Command Line

Open **Command Prompt** (Windows) or **Terminal** (Linux/macOS) on host:

```cmd
# SSH Port Forwarding
VBoxManage modifyvm "Ubuntu-VM-Name" --natpf1 "SSH,tcp,127.0.0.1,2222,10.0.2.15,22"

# HTTP Port Forwarding
VBoxManage modifyvm "Ubuntu-VM-Name" --natpf1 "HTTP,tcp,127.0.0.1,8080,10.0.2.15,80"

# ERPNext Development Server
VBoxManage modifyvm "Ubuntu-VM-Name" --natpf1 "ERPNext,tcp,127.0.0.1,8000,10.0.2.15,8000"

# HTTPS Port Forwarding
VBoxManage modifyvm "Ubuntu-VM-Name" --natpf1 "HTTPS,tcp,127.0.0.1,8443,10.0.2.15,443"
```

**Note:** Replace `Ubuntu-VM-Name` with your actual VM name.

#### Remove Port Forwarding Rule

```cmd
VBoxManage modifyvm "Ubuntu-VM-Name" --natpf1 delete "SSH"
```

### Step 3: Access VM from Host

After configuring port forwarding:

```bash
# SSH from host
ssh -p 2222 username@localhost

# Access ERPNext
http://localhost:8000

# Access web server
http://localhost:8080
```

---

## Bridged Adapter Configuration

### Overview

Bridged mode makes your VM appear as a separate physical device on your network. The VM gets an IP from your network's DHCP server or uses a static IP in your network range.

### Use Case Example

**Scenario:** Office network with IP range `172.16.30.0/25`
- Gateway: `172.16.30.114`
- DNS: `172.16.30.114` (internal) and `8.8.8.8` (Google)
- Assigned Static IP: `172.16.30.100`

### Step 1: Change VirtualBox Network Mode

#### Shutdown the VM

```bash
sudo shutdown -h now
```

#### Configure Bridged Adapter

1. In VirtualBox, select your VM
2. Click **Settings** → **Network**
3. **Adapter 1** tab:
   - **Enable Network Adapter**: ✅ Checked
   - **Attached to**: Select `Bridged Adapter`
   - **Name**: Select your physical network adapter
     - Ethernet: Usually named `Intel(R) Ethernet...` or `Realtek...`
     - WiFi: Usually named `Intel(R) Wi-Fi...` or `Wireless...`
   - **Adapter Type**: `Intel PRO/1000 MT Desktop` (default is fine)
   - **Promiscuous Mode**: `Allow All`
   - **Cable Connected**: ✅ Checked
4. Click **OK**

#### Start the VM

Start your VM and log in.

### Step 2: Configure Static IP in Ubuntu

#### Gather Network Information

Before configuring, you need:
- **Static IP address**: e.g., `172.16.30.100`
- **Subnet mask**: e.g., `/25` or `255.255.255.128`
- **Gateway**: e.g., `172.16.30.114`
- **DNS servers**: e.g., `172.16.30.114`, `8.8.8.8`

**How to find this information:**

On your **Windows host**, open Command Prompt:

```cmd
ipconfig /all
```

Look for:
- **IPv4 Address**: Use a similar address in the same subnet
- **Subnet Mask**: Convert to CIDR (e.g., `255.255.255.128` = `/25`)
- **Default Gateway**: Use this as your VM's gateway
- **DNS Servers**: Note these down

#### Create Netplan Configuration

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

#### Add Bridged Configuration

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:  # Replace with your interface name
      dhcp4: no
      addresses:
        - 172.16.30.100/25  # Your static IP with subnet mask
      routes:
        - to: default
          via: 172.16.30.114  # Your network gateway
      nameservers:
        addresses:
          - 172.16.30.114     # Primary DNS (often internal)
          - 8.8.8.8           # Secondary DNS (Google)
          - 8.8.4.4           # Tertiary DNS (Google backup)
```

**Configuration Breakdown:**

- **addresses**: Your VM's static IP address with CIDR notation
- **routes/via**: Default gateway (usually your router)
- **nameservers/addresses**: DNS servers for domain name resolution

#### Common Subnet Masks (CIDR Notation)

| Subnet Mask | CIDR | Hosts | Common Use |
|-------------|------|-------|------------|
| 255.255.255.0 | /24 | 254 | Small networks |
| 255.255.255.128 | /25 | 126 | Medium networks |
| 255.255.255.192 | /26 | 62 | Small subnets |
| 255.255.254.0 | /23 | 510 | Large networks |

#### Set Permissions

```bash
sudo chmod 600 /etc/netplan/01-netcfg.yaml
```

#### Test Configuration

```bash
sudo netplan try
```

Press `Enter` if everything works, or wait 120 seconds for automatic rollback.

#### Apply Configuration

```bash
sudo netplan apply
```

### Step 3: Verify Bridged Network

```bash
# Check IP address
ip addr show enp0s3

# Expected: inet 172.16.30.100/25

# Check routing
ip route show

# Expected: default via 172.16.30.114 dev enp0s3

# Test gateway
ping -c 4 172.16.30.114

# Test external DNS
ping -c 4 8.8.8.8

# Test domain resolution
ping -c 4 google.com
```

### Step 4: Test Connectivity from Host

From your **Windows host**:

```cmd
# Ping the VM
ping 172.16.30.100

# SSH to the VM (if SSH server is installed)
ssh username@172.16.30.100

# Access web services directly
http://172.16.30.100:8000
```

### Step 5: Access from Other Network Devices

Since the VM is on the same network, other devices can access it directly:

```bash
# From any device on the network
http://172.16.30.100:8000   # ERPNext
http://172.16.30.100        # Web server
ssh user@172.16.30.100      # SSH
```

---

## Troubleshooting

### Issue 1: Cannot Ping Gateway

**Symptoms:**
```bash
ping 172.16.30.114
# Result: Destination Host Unreachable
```

**Causes and Solutions:**

#### 1. Wrong Network Mode
**Check:** Is VM in Bridged mode?

```bash
# In VirtualBox Settings → Network
# Ensure "Attached to: Bridged Adapter"
```

**Solution:** Change to Bridged Adapter and restart VM.

#### 2. Wrong Physical Adapter Selected
**Check:** Correct physical adapter selected in VirtualBox?

**Solution:**
- In VirtualBox → Settings → Network
- Try different physical adapters from the dropdown
- Use the one actively connected to your network

#### 3. Network Cable Disconnected in VirtualBox
**Check:** Is "Cable Connected" checked?

**Solution:**
- VirtualBox Settings → Network → Advanced
- Ensure "Cable Connected" is ✅ checked

#### 4. Interface Not Up
**Check:**
```bash
ip link show enp0s3
```

**Solution:**
```bash
sudo ip link set enp0s3 up
sudo netplan apply
```

### Issue 2: DNS Resolution Failing

**Symptoms:**
```bash
ping google.com
# Result: ping: google.com: Temporary failure in name resolution
```

**Causes and Solutions:**

#### 1. Check DNS Configuration
```bash
cat /etc/resolv.conf
```

Should show:
```
nameserver 172.16.30.114
nameserver 8.8.8.8
```

#### 2. Manually Set DNS (Temporary)
```bash
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
ping google.com
```

#### 3. Fix Netplan DNS Configuration
```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

Ensure `nameservers` section is correct:
```yaml
nameservers:
  addresses:
    - 8.8.8.8
    - 8.8.4.4
```

Apply:
```bash
sudo netplan apply
```

#### 4. Restart systemd-resolved
```bash
sudo systemctl restart systemd-resolved
sudo systemctl status systemd-resolved
```

### Issue 3: Configuration Not Applying

**Symptoms:**
- Changes don't take effect
- Old IP still showing

**Solutions:**

#### 1. Check for YAML Syntax Errors
```bash
sudo netplan --debug apply
```

Common YAML mistakes:
- ❌ Wrong indentation (use 2 spaces, not tabs)
- ❌ Missing colons
- ❌ Extra spaces

#### 2. Restart Networking Service
```bash
sudo systemctl restart systemd-networkd
sudo netplan apply
```

#### 3. Check for Multiple Netplan Files
```bash
ls -la /etc/netplan/
```

If multiple `.yaml` files exist, they can conflict. Keep only one:
```bash
sudo rm /etc/netplan/50-cloud-init.yaml  # If exists
```

#### 4. Flush IP Configuration
```bash
sudo ip addr flush dev enp0s3
sudo netplan apply
```

### Issue 4: IP Conflict on Network

**Symptoms:**
- Intermittent connectivity
- Network drops randomly
- "Duplicate IP" warnings

**Solutions:**

#### 1. Check for IP Conflict
```bash
# From Ubuntu VM
sudo arping -I enp0s3 172.16.30.100

# From Windows Host
arp -a | findstr "172.16.30.100"
```

#### 2. Change to Different IP
```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

Use a different IP address:
```yaml
addresses:
  - 172.16.30.101/25  # Changed from .100 to .101
```

#### 3. Verify IP is Not in DHCP Range
- Contact network admin
- Ensure static IP is outside DHCP pool
- Common practice: Reserve IPs above `.100` for static use

### Issue 5: Cannot Access VM from Host (Bridged Mode)

**Symptoms:**
```cmd
ping 172.16.30.100
# Result: Request timed out
```

**Causes and Solutions:**

#### 1. Check Windows Firewall
```cmd
# Run as Administrator
# Allow ICMP (ping)
netsh advfirewall firewall add rule name="ICMPv4" protocol=icmpv4:8,any dir=in action=allow

# Allow specific port (e.g., 8000 for ERPNext)
netsh advfirewall firewall add rule name="ERPNext" dir=in action=allow protocol=TCP localport=8000
```

#### 2. Check Ubuntu Firewall (UFW)
```bash
sudo ufw status

# If active, allow necessary ports
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 8000/tcp  # ERPNext
sudo ufw allow 443/tcp   # HTTPS

# Or disable UFW for testing (not recommended for production)
sudo ufw disable
```

#### 3. Verify Service is Listening
```bash
# Check if service is running
sudo netstat -tlnp | grep :8000

# Or using ss
sudo ss -tlnp | grep :8000

# Should show: LISTEN state
```

#### 4. Check Network Isolation
Some corporate networks have client isolation enabled:
- Devices cannot communicate with each other
- Contact network administrator
- May need to use different network or VPN

### Issue 6: Lost Internet After Static IP Configuration

**Quick Fix - Revert to DHCP:**

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

Replace with DHCP configuration:
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
```

Apply:
```bash
sudo netplan apply
```

Test:
```bash
ping -c 4 google.com
```

---

## Verification Commands

### Network Interface Information

```bash
# Show all network interfaces
ip addr show

# Show specific interface
ip addr show enp0s3

# Show interface statistics
ip -s link show enp0s3

# Legacy command (if net-tools installed)
ifconfig enp0s3
```

### Routing Information

```bash
# Show routing table
ip route show

# Show default gateway
ip route | grep default

# Show route to specific destination
ip route get 8.8.8.8

# Legacy command
route -n
```

### DNS Configuration

```bash
# Check DNS resolution configuration
cat /etc/resolv.conf

# Check systemd-resolved status
systemd-resolve --status

# Test DNS query
nslookup google.com

# Test DNS with dig (if dnsutils installed)
dig google.com

# Test DNS with host
host google.com
```

### Connectivity Tests

```bash
# Test gateway connectivity
ping -c 4 172.16.30.114

# Test external IP connectivity
ping -c 4 8.8.8.8

# Test DNS resolution
ping -c 4 google.com

# Trace route to destination
traceroute google.com

# Or tracepath (no root required)
tracepath google.com

# Test specific port connectivity
nc -zv google.com 80

# Or using telnet
telnet google.com 80
```

### Network Service Status

```bash
# Check systemd-networkd status
sudo systemctl status systemd-networkd

# Check NetworkManager status (if used)
sudo systemctl status NetworkManager

# Check systemd-resolved status
sudo systemctl status systemd-resolved

# View networkd logs
sudo journalctl -u systemd-networkd

# View netplan logs
sudo journalctl -u netplan-*
```

### Port and Socket Information

```bash
# Show listening ports
sudo netstat -tlnp

# Show all connections
sudo netstat -anp

# Using ss (modern alternative)
sudo ss -tlnp

# Show specific port
sudo ss -tlnp | grep :8000

# Show processes using network
sudo lsof -i
```

### ARP Table

```bash
# Show ARP cache
ip neigh show

# Show ARP for specific interface
ip neigh show dev enp0s3

# Legacy command
arp -a
```

### Netplan Configuration

```bash
# Validate netplan configuration
sudo netplan try

# Apply configuration
sudo netplan apply

# Generate backend configuration
sudo netplan generate

# Debug mode
sudo netplan --debug apply

# Show current netplan configuration
cat /etc/netplan/*.yaml
```

---

## Common Issues and Solutions

### Issue: "Permission Denied" When Editing Netplan

**Problem:**
```bash
nano /etc/netplan/01-netcfg.yaml
# Error: Permission denied
```

**Solution:**
```bash
# Use sudo
sudo nano /etc/netplan/01-netcfg.yaml
```

### Issue: YAML Syntax Error

**Problem:**
```bash
sudo netplan apply
# Error: Invalid YAML syntax
```

**Common Mistakes:**

❌ **Wrong (using tabs):**
```yaml
network:
	version: 2
```

✅ **Correct (using 2 spaces):**
```yaml
network:
  version: 2
```

❌ **Wrong (missing colon):**
```yaml
network
  version: 2
```

✅ **Correct:**
```yaml
network:
  version: 2
```

**Solution:**
- Always use 2 spaces for indentation
- Never use tabs
- Check colons after each key
- Validate with: `sudo netplan --debug apply`

### Issue: Multiple IP Addresses on Interface

**Problem:**
```bash
ip addr show enp0s3
# Shows both old and new IP addresses
```

**Solution:**
```bash
# Flush all IP addresses from interface
sudo ip addr flush dev enp0s3

# Reapply configuration
sudo netplan apply

# Verify
ip addr show enp0s3
```

### Issue: Gateway Not Reachable After Reboot

**Problem:**
- Network works initially
- Fails after reboot

**Solution:**

Check if configuration persists:
```bash
cat /etc/netplan/01-netcfg.yaml
```

Ensure permissions are correct:
```bash
sudo chmod 600 /etc/netplan/01-netcfg.yaml
sudo chown root:root /etc/netplan/01-netcfg.yaml
```

Ensure systemd-networkd is enabled:
```bash
sudo systemctl enable systemd-networkd
sudo systemctl restart systemd-networkd
```

### Issue: Interface Name Changed After Kernel Update

**Problem:**
- Interface was `enp0s3`, now it's `eth0` or vice versa

**Solution:**

1. Find current interface name:
```bash
ip link show
```

2. Update netplan configuration:
```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

Change interface name accordingly.

3. Apply:
```bash
sudo netplan apply
```

### Issue: Slow Network Performance

**Possible Causes:**

1. **MTU Size Mismatch**

Check MTU:
```bash
ip link show enp0s3 | grep mtu
```

Try setting MTU:
```bash
sudo ip link set enp0s3 mtu 1450
```

Add to netplan:
```yaml
ethernets:
  enp0s3:
    mtu: 1450
```

2. **Adapter Type in VirtualBox**

In VirtualBox Settings → Network → Advanced:
- Try different "Adapter Type"
- `Intel PRO/1000 MT Desktop` is usually fastest

3. **Promiscuous Mode**

Set to "Allow All" in VirtualBox Network settings.

---

## Best Practices

### 1. Always Test Before Applying

```bash
# Use try instead of apply
sudo netplan try
```

This gives you 120 seconds to test, with automatic rollback.

### 2. Backup Configuration Before Changes

```bash
# Backup current config
sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.backup

# Restore if needed
sudo cp /etc/netplan/01-netcfg.yaml.backup /etc/netplan/01-netcfg.yaml
```

### 3. Document Your Network Configuration

Create a text file with network details:

```bash
nano ~/network-config.txt
```

Content:
```
VM Name: Ubuntu-ERPNext-Server
Network Mode: Bridged Adapter
Physical Adapter: Intel(R) Ethernet Connection
Static IP: 172.16.30.100/25
Gateway: 172.16.30.114
DNS: 172.16.30.114, 8.8.8.8
Interface: enp0s3
Date Configured: 2025-01-19
```

### 4. Use Consistent IP Address Scheme

For multiple VMs:
- Web Server: `172.16.30.100`
- Database Server: `172.16.30.101`
- Development: `172.16.30.102`

### 5. Security Considerations

```bash
# Enable firewall
sudo ufw enable

# Allow only necessary ports
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# Check status
sudo ufw status verbose
```

### 6. Monitor Network Performance

```bash
# Install monitoring tools
sudo apt install -y iftop nethogs iptraf-ng

# Monitor bandwidth
sudo iftop -i enp0s3

# Monitor per-process network usage
sudo nethogs enp0s3
```

---

## Quick Reference

### Netplan Configuration Template (NAT)

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 10.0.2.15/24
      routes:
        - to: default
          via: 10.0.2.2
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

### Netplan Configuration Template (Bridged)

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 172.16.30.100/25
      routes:
        - to: default
          via: 172.16.30.114
      nameservers:
        addresses:
          - 172.16.30.114
          - 8.8.8.8
```

### Netplan Configuration Template (DHCP)

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
```

### Essential Commands Cheat Sheet

```bash
# Apply network configuration
sudo netplan apply

# Test configuration (with auto-rollback)
sudo netplan try

# View IP addresses
ip addr show

# View routing table
ip route show

# Restart networking
sudo systemctl restart systemd-networkd

# Check DNS
cat /etc/resolv.conf

# Test connectivity
ping -c 4 google.com

# Check listening ports
sudo netstat -tlnp

# View interface statistics
ip -s link show enp0s3
```

---

## Additional Resources

### Official Documentation

- [Ubuntu Netplan Documentation](https://netplan.io/)
- [VirtualBox Networking Guide](https://www.virtualbox.org/manual/ch06.html)
- [Ubuntu Server Guide - Networking](https://ubuntu.com/server/docs/network-introduction)

### Useful Tools to Install

```bash
# Network diagnostic tools
sudo apt install -y net-tools
sudo apt install -y dnsutils
sudo apt install -y traceroute
sudo apt install -y iftop
sudo apt install -y nethogs
sudo apt install -y iptraf-ng
sudo apt install -y tcpdump

# Text editors
sudo apt install -y vim
sudo apt install -y nano

# SSH server (for remote access)
sudo apt install -y openssh-server
```

---

## Conclusion

This guide covered:
- ✅ Understanding VirtualBox network modes (NAT vs Bridged)
- ✅ DHCP vs Static IP configuration
- ✅ Configuring static IP in Ubuntu 24.04 using Netplan
- ✅ Setting up port forwarding for NAT mode
- ✅ Troubleshooting common networking issues
- ✅ Verification and testing procedures

### Next Steps for ERPNext Setup

Once networking is configured:

1. **Update system:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install prerequisites:**
   ```bash
   sudo apt install -y python3-dev python3-pip python3-venv
   sudo apt install -y mariadb-server redis-server
   sudo apt install -y git curl wget
   ```

3. **Install Frappe/ERPNext:**
   Follow the official Frappe documentation

4. **Configure firewall:**
   ```bash
   sudo ufw allow 8000/tcp  # Development
   sudo ufw allow 80/tcp    # Production
   sudo ufw allow 443/tcp   # HTTPS
   ```

---

## Support and Feedback

For issues specific to:
- **Netplan**: [Netplan GitHub Issues](https://github.com/canonical/netplan/issues)
- **VirtualBox**: [VirtualBox Forums](https://forums.virtualbox.org/)
- **Ubuntu**: [Ubuntu Community](https://askubuntu.com/)

---

**Document Version:** 1.0  
**Last Updated:** January 19, 2025  
**Author:** Technical Documentation  
**Tested On:** Ubuntu 24.04.2 LTS with VirtualBox 7.x
