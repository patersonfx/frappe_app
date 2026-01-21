# How to Prefer IPv4 over IPv6 on Linux

## Problem

By default, Linux systems prefer IPv6 over IPv4 when both are available. This can cause:
- Slower connections if IPv6 routing is suboptimal
- Compatibility issues with some services

### Example

```bash
# IPv4 resolution (github.com)
$ ping github.com
PING github.com (20.207.73.82) 56(84) bytes of data.
64 bytes from 20.207.73.82: icmp_seq=1 ttl=118 time=8.98 ms

# IPv6 resolution (google.com)
$ ping google.com
PING google.com (2404:6800:4009:80c::200e) 56 data bytes
64 bytes from pnbomb-bd-in-x0e.1e100.net: icmp_seq=1 ttl=117 time=3.97 ms
```

## Solution

Modify the `/etc/gai.conf` file to give IPv4 higher precedence.

### Step 1: Edit the configuration file

```bash
sudo nano /etc/gai.conf
```

### Step 2: Add or uncomment the following line

```
precedence ::ffff:0:0/96  100
```

This line gives IPv4-mapped addresses (::ffff:0:0/96) a precedence of 100, which is higher than the default IPv6 precedence.

### Step 3: Save and exit

- Press `Ctrl + O` to save
- Press `Ctrl + X` to exit

### Step 4: Verify the change

No restart is required. Test immediately with:

```bash
ping google.com
```

You should now see an IPv4 address (e.g., `142.250.x.x`) instead of an IPv6 address.

## Alternative: Disable IPv6 Completely (Not Recommended)

If you need to completely disable IPv6:

```bash
# Temporary (until reboot)
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Permanent (add to /etc/sysctl.conf)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

> **Warning:** Disabling IPv6 entirely may break some applications and services that rely on it.

## References

- `man gai.conf` - getaddrinfo configuration file documentation
- RFC 3484 - Default Address Selection for IPv6
