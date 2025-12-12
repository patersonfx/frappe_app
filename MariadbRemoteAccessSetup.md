# MariaDB Remote Access Configuration for Frappe/ERPNext

## Complete Setup Guide for Remote Database Access

This guide covers the complete process of configuring MariaDB to allow remote connections for Frappe/ERPNext applications.

---

## Prerequisites

- MariaDB installed and running
- Root/sudo access to the server
- Firewall configured to allow MySQL port (3306)

---

## Step 1: Locate MariaDB Configuration Files

First, identify where the MariaDB configuration files are located:

```bash
sudo grep -r "bind-address" /etc/mysql/
```

**Expected Output:**
```
/etc/mysql/mariadb.conf.d/50-server.cnf:bind-address = 127.0.0.1
```

This shows that the configuration is in `/etc/mysql/mariadb.conf.d/50-server.cnf`

---

## Step 2: Modify the Bind Address Configuration

Open the configuration file using nano editor:

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

### Inside the nano editor:

1. **Locate the bind-address line:**
   ```ini
   bind-address = 127.0.0.1
   ```

2. **Change it to allow connections from all interfaces:**
   ```ini
   bind-address = 0.0.0.0
   ```

   > **Note:** Using `0.0.0.0` allows connections from any IP address. For better security, you can specify a specific IP address instead.

3. **Save and exit:**
   - Press `Ctrl + O` to save
   - Press `Enter` to confirm the filename
   - Press `Ctrl + X` to exit nano

---

## Step 3: Restart MariaDB Service

Apply the configuration changes by restarting MariaDB:

```bash
sudo systemctl restart mariadb
```

**Verify the service is running:**
```bash
sudo systemctl status mariadb
```

---

## Step 4: Create Remote User and Grant Privileges

Log into MariaDB as root:

```bash
sudo mysql -u root -p
```

### Create a new remote user:

```sql
CREATE USER 'frappe_remote'@'%' IDENTIFIED BY 'strong_password';
```

**Parameters explained:**
- `frappe_remote` - Username for remote access (change as needed)
- `%` - Allows connections from any host (use specific IP for better security)
- `strong_password` - Set a secure password

### Grant privileges to the Frappe database:

```sql
GRANT ALL PRIVILEGES ON `db_name`.* TO 'frappe_remote'@'%';
```

**Parameters explained:**
- `db_name` - Your Frappe site's database name
- `.*` - Grants access to all tables in this database
- `frappe_remote@'%'` - The user created above

### Flush privileges to apply changes:

```sql
FLUSH PRIVILEGES;
```

### Exit MariaDB:

```sql
EXIT;
```

---

## Step 5: Configure Firewall (if applicable)

If you're using UFW firewall, allow MySQL port:

```bash
sudo ufw allow 3306/tcp
sudo ufw reload
```

For iptables:

```bash
sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
sudo service iptables save
```

---

## Security Best Practices

### 1. Use Specific IP Addresses Instead of '%'

Instead of allowing connections from anywhere (`%`), specify the client IP:

```sql
CREATE USER 'frappe_remote'@'192.168.1.100' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON `db_name`.* TO 'frappe_remote'@'192.168.1.100';
```

### 2. Use Strong Passwords

Generate a strong password using:

```bash
openssl rand -base64 32
```

### 3. Limit Bind Address

Instead of `0.0.0.0`, bind to a specific network interface:

```ini
bind-address = 192.168.1.50
```

### 4. Enable SSL/TLS Connections

For production environments, configure SSL for encrypted connections.

---

## Testing Remote Connection

From the remote machine, test the connection:

```bash
mysql -h server_ip_address -u frappe_remote -p
```

Or use the Frappe bench command:

```bash
bench --site site_name mariadb --host server_ip_address
```

---

## Troubleshooting

### Connection Refused

1. **Check if MariaDB is listening on the correct port:**
   ```bash
   sudo netstat -tlnp | grep 3306
   ```
   Should show `0.0.0.0:3306` or your specific IP.

2. **Verify firewall rules:**
   ```bash
   sudo ufw status
   ```

3. **Check MariaDB error logs:**
   ```bash
   sudo tail -f /var/log/mysql/error.log
   ```

### Access Denied Errors

1. **Verify user privileges:**
   ```sql
   SELECT User, Host FROM mysql.user WHERE User = 'frappe_remote';
   SHOW GRANTS FOR 'frappe_remote'@'%';
   ```

2. **Check database name:**
   ```sql
   SHOW DATABASES;
   ```

### Bind Address Not Changing

1. **Check for multiple configuration files:**
   ```bash
   sudo grep -r "bind-address" /etc/mysql/
   ```

2. **Ensure you edited the correct file and restarted MariaDB**

---

## Finding Your Frappe Database Name

If you don't know your site's database name:

```bash
# From Frappe bench directory
cat sites/your-site-name/site_config.json | grep db_name
```

Or login to MariaDB and list all databases:

```sql
SHOW DATABASES;
```

Frappe database names typically start with an underscore followed by a hash.

---

## Reverting Changes

To restrict access back to localhost only:

1. **Change bind-address back:**
   ```ini
   bind-address = 127.0.0.1
   ```

2. **Restart MariaDB:**
   ```bash
   sudo systemctl restart mariadb
   ```

3. **Remove remote user (optional):**
   ```sql
   DROP USER 'frappe_remote'@'%';
   FLUSH PRIVILEGES;
   ```

---

## Additional Resources

- [MariaDB Security Documentation](https://mariadb.com/kb/en/securing-mariadb/)
- [Frappe Framework Documentation](https://frappeframework.com/docs)
- [UFW Firewall Guide](https://help.ubuntu.com/community/UFW)

---

## Summary Checklist

- [ ] Located and modified `bind-address` in MariaDB configuration
- [ ] Restarted MariaDB service
- [ ] Created remote user with appropriate privileges
- [ ] Configured firewall to allow port 3306
- [ ] Tested remote connection
- [ ] Applied security best practices
- [ ] Documented credentials securely

---

**Last Updated:** November 2025
**Tested on:** Ubuntu 20.04/22.04 with MariaDB 10.6+