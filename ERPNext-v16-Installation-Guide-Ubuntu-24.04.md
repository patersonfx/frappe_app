# Guide: How to Install ERPNext v16 on Linux Ubuntu 24.04 (Step-by-Step Instructions)

> **Original Author:** Shashank Shirke  
> **Source:** [Frappe Forum](https://discuss.frappe.io/t/guide-how-to-install-erpnext-v16-on-linux-ubuntu-24-04-step-by-step-instructions/159255)  
> **Published:** January 16, 2026

---

## 📄 Table of Contents

- [Pre-Requisites](#pre-requisites)
- [Step 1: Server Setup](#1️⃣-server-setup)
- [Step 2: Install Required Packages](#2️⃣-install-required-packages)
- [Step 3: Configure MySQL Server](#3️⃣-configure-mysql-server)
- [Step 4: Install Node, NPM, Yarn](#4️⃣-install-node-npm-yarn)
- [Step 5: Initialize Frappe Bench](#5️⃣-initialize-frappe-bench)
- [Step 6: Create New Site & Install Frappe Framework](#6️⃣-create-new-site--install-frappe-framework)
- [Step 7: Setup Production Environment](#7️⃣-setup-production-environment)
- [Step 8: Install ERPNext and Other Apps](#8️⃣-install-erpnext--other-apps)
- [Step 9: Custom Domain & SSL Setup](#9️⃣-custom-domain--ssl-setup)

---

## Pre-Requisites

- **Operating System:** Linux Ubuntu 24.04 LTS
- **SSH access** to the server
- **Software version requirements:**
  - Python 3.14
  - Node 24
  - MariaDB 11.8
  - Redis 6+
  - Yarn 1.22+
  - Pip 25.3+

---

## 1️⃣ SERVER SETUP

### 1.1 Login to the server using SSH

### 1.2 Setup correct date and timezone

Check the server's default timezone:

```bash
date
# Eg output: Fri Jan 16 02:29:39 UTC 2026
```

The default timezone is usually UTC. If you want to set a different timezone:

```bash
timedatectl set-timezone "America/Los_Angeles"
```

> Full list of IANA timezones: [List of tz database time zones - Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

### 1.3 Update & upgrade system packages

```bash
sudo apt-get update -y
sudo apt-get upgrade -y
```

### 1.4 Create a new user

We create this user as a security measure to avoid using root access. This user will be added to the admin group and will have sudo privileges. We will install Frappe Bench, ERPNext and other apps using this user.

```bash
sudo adduser [frappe-user]
usermod -aG sudo [frappe-user]
su [frappe-user]
cd /home/[frappe-user]/
```

> **Note:** Replace `[frappe-user]` with your desired username.

> For some cloud providers like AWS & Azure, you won't have root password access so you can simply run `sudo -i` when you login to the server using the default user (eg. `ubuntu` in AWS).

---

## 2️⃣ INSTALL REQUIRED PACKAGES

Frappe Framework and ERPNext require many packages to run smoothly. In this step we will install all the required packages for the system to work correctly.

> **Note:** During the installation of these packages the server might prompt you to confirm if you want to continue installing the package `[Y/n]`. Just hit `y` on your keyboard to continue.

### 2.1 Install Git

```bash
sudo apt-get install git -y
```

Verify: `git --version`

### 2.2 Install cURL

```bash
sudo apt-get install curl -y
```

Verify: `curl --version`

### 2.3 Install Python

Ubuntu 24.04 comes pre-installed with a system level Python (v3.12). We will be installing additional Python tools like pip, venv, etc.:

```bash
sudo apt-get install python3-dev python3-pip python3-setuptools -y
sudo apt-get install python3-venv -y
```

Verify: `python3 --version`

**Important:** Frappe v16 officially requires Python 3.14 and it's officially [recommended](https://docs.frappe.io/framework/user/en/installation) to install and manage Python virtual environment using the new `uv` package manager. In Frappe v15 and earlier versions we used the standard `pip` package manager and `venv` for managing virtual environments. This still works, but we will follow the official guidelines and use `uv`:

```bash
cd /home/[frappe-user]/

curl -LsSf https://astral.sh/uv/install.sh | sh

source ~/.bashrc

uv python install 3.14 --default
```

Verify uv: `uv --version`  
Verify Python 3.14: `python3 --version`

### 2.4 Install other required packages

```bash
sudo apt-get install software-properties-common -y
sudo apt-get install xvfb libfontconfig -y
sudo apt-get install libmysqlclient-dev -y
sudo apt-get install pkg-config -y
```

### 2.5 Install Redis Server

```bash
sudo apt-get install redis-server -y
```

Verify: `redis-server --version`

### 2.6 Install wkhtmltopdf

Frappe uses wkhtmltopdf library to generate PDF documents. This is an outdated library so Frappe v16 now also supports Chrome based PDF generation. However, for compatibility purposes, we will still install wkhtmltopdf.

**For ARM64:**

```bash
sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_arm64.deb
sudo dpkg -i wkhtmltox_0.12.6.1-2.jammy_arm64.deb
sudo apt-get -f install -y
sudo dpkg -i wkhtmltox_0.12.6.1-2.jammy_arm64.deb
```

**For AMD64 (x86_64):**

```bash
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo apt install ./wkhtmltox_0.12.6.1-2.jammy_amd64.deb -y
```

Verify: `wkhtmltopdf --version`  
Frappe requires a Qt patched version like this: `wkhtmltopdf 0.12.6.1 (with patched qt)`

---

## 3️⃣ CONFIGURE MySQL SERVER

Frappe v16 requires MariaDB 11.8+ so we will first install MariaDB server and client.

### 3.1 Install MariaDB server

```bash
sudo apt install mariadb-server mariadb-client -y
```

Verify: `mysql --version`

### 3.2 Configure MariaDB server

```bash
sudo mysql_secure_installation
```

During the setup process, the server will prompt you with the following questions:

| Prompt | Answer |
|--------|--------|
| Enter current password for root | Enter your SSH root user password or leave blank |
| Switch to unix_socket authentication [Y/n] | **Y** |
| Change the root password? [Y/n] | **Y** (set a new MySQL root password) |
| Remove anonymous users? [Y/n] | **Y** |
| Disallow root login remotely? [Y/n] | **N** (to allow remote DB access for BI tools) |
| Remove test database and access to it? [Y/n] | **Y** |
| Reload privilege tables now? [Y/n] | **Y** |

### 3.3 Update MariaDB config file

```bash
sudo nano /etc/mysql/my.cnf
```

Add the following code block at the **end** of the file:

```ini
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
```

> **Nano tip:** Paste the above code, press `CTRL+X`, then `Y`, then `Enter` to save.

### 3.4 Restart MariaDB server

```bash
sudo service mysql restart
```

---

## 4️⃣ INSTALL Node, NPM, Yarn

### 4.1 Install Node

Frappe v16 requires Node 24. We will install it using Node Version Manager (nvm):

```bash
cd /home/[frappe-user]/

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

source ~/.profile

nvm install 24
nvm use 24
```

Verify: `node --version`

### 4.2 Install Node Package Manager (npm)

```bash
sudo apt-get install npm -y
```

Verify: `npm --version`

### 4.3 Install Yarn

```bash
sudo npm install -g yarn
```

Verify: `yarn --version`

---

## 5️⃣ INITIALIZE FRAPPE BENCH

### 5.1 Install Frappe Bench

Frappe Bench is the command line utility (CLI tool) to manage Frappe sites and applications. Frappe v16 uses `uv` package manager to install Bench (instead of `pip`).

```bash
uv tool install frappe-bench
```

Verify: `bench --version`

### 5.2 Initialize Frappe Bench

When Frappe Bench is initialized, it creates a folder that acts as a container for all the sites and apps.

```bash
cd /home/[frappe-user]/

bench init --frappe-branch version-16 frappe-bench
```

### 5.3 Set bench directory permissions

```bash
cd /home/[frappe-user]/frappe-bench/

sudo chmod -R o+rx /home/[frappe-user]/
```

---

## 6️⃣ CREATE NEW SITE & INSTALL FRAPPE FRAMEWORK

### 6.1 Create new site

This will create a new Frappe site inside the Frappe Bench folder. As part of the site creation process it will:

- Create a new database on MariaDB server
- Create a new database user and assign it to the newly created database
- Install Frappe Framework app on the site
- Setup the Administrator user

```bash
bench new-site site1.local
```

> **Note:** During the site creation process, it will ask you to setup the password for the Administrator user. This user will have full system wide privileges so please use a strong password.

---

## 7️⃣ SETUP PRODUCTION ENVIRONMENT

To setup production environment we will be using the `supervisor` process manager to manage all important processes required to run Frappe & ERPNext smoothly.

### 7.1 Enable Scheduler Service

```bash
bench --site site1.local enable-scheduler
```

### 7.2 Disable Maintenance Mode

```bash
bench --site site1.local set-maintenance-mode off
```

### 7.3 Bench Setup Production

In Frappe v16, we need to install Ansible separately first (since `uv` is used instead of `pip`):

```bash
sudo apt install -y ansible

sudo env "PATH=$PATH" bench setup production [frappe-user]
```

> Depending on the network speed, it will take around 5-7 minutes for the full production setup to complete.

### 7.4 Setup NGINX web server

```bash
bench setup nginx
```

### 7.5 Restart all services using supervisor

```bash
sudo supervisorctl restart all
sudo supervisorctl status
```

After running the above command it should show a status of all services as below:

```
frappe-bench-16-redis-cache             RUNNING
frappe-bench-16-redis-queue             RUNNING
frappe-bench-16-frappe-web              RUNNING
frappe-bench-16-node-socketio           RUNNING
frappe-bench-16-frappe-long-worker-0    RUNNING
frappe-bench-16-frappe-schedule         RUNNING
frappe-bench-16-frappe-short-worker-0   RUNNING
```

### Troubleshooting: If services are not showing

```bash
ls -l /etc/supervisor/conf.d/
# Above command should show a frappe-bench.conf file.
# If it's missing then proceed to run next commands:

sudo ln -sf /home/[frappe-user]/frappe-bench/config/supervisor.conf /etc/supervisor/conf.d/frappe-bench.conf

sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart all
sudo supervisorctl status
```

---

## 8️⃣ INSTALL ERPNEXT & OTHER APPS

### 8.1 Fetch apps from GitHub

```bash
bench get-app --branch version-16 erpnext
bench get-app --branch version-16 hrms
```

### 8.2 Install apps on the site

```bash
bench --site site1.local install-app erpnext
bench --site site1.local install-app hrms
```

Verify installation: `bench version --format table`

### 🎉 Ready to Go!

Open your browser and go to `http://[server-ip-address]:80` and you will have a fresh new installation of ERPNext ready to be setup and configured!

### Firewall Configuration

If you are facing any issues with the ports, make sure to enable all the necessary ports on your firewall:

```bash
sudo ufw allow 22,25,143,80,443,3306,3022,8000/tcp
sudo ufw enable
```

---

## 9️⃣ CUSTOM DOMAIN & SSL SETUP

### 9.1 Enable DNS multi-tenancy

By default, Frappe uses port-based multi-tenancy. To use custom domains we have to enable DNS-based multi-tenancy:

```bash
cd /home/[frappe-user]/frappe-bench/

bench config dns_multitenant on
```

### 9.2 Add "A" record in your domain DNS

Login to your domain name control panel and go to DNS settings.  
Add a new **"A" record** and point it to your server IP address.

Example: `A record subdomain.yourdomain.com → 123.456.78.90`

### 9.3 Link custom domain to your site

```bash
bench setup add-domain [subdomain.yourdomain.com] --site site1.local

bench setup nginx
sudo service nginx reload
```

### 9.4 Install SSL certificate

We will install Let's Encrypt free SSL certificate to enable HTTPS access:

```bash
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot

sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo certbot --nginx
```

During the installation, it will prompt you for details like email, etc. and then show you a list of domains available for SSL setup. Enter the correct number for the domain you want to install SSL on and hit Enter.

---

## 🔟 Explore & Have Fun!

You now have a fully production-ready setup of Frappe & ERPNext on your server!

---

## Important Links

- [ERPNext v16 Announcement](https://frappe.io/erpnext/version-16)
- [ERPNext v16 Release Notes](https://github.com/frappe/erpnext/releases/tag/v16.0.0)
- [Frappe Official Installation Docs](https://docs.frappe.io/framework/user/en/installation)
- [One-Click Install Script (Community)](https://github.com/flexcomng/erpnext_quick_install)

---

## Earlier Installation Guides

- [ERPNext v15 Installation (Oct 2023)](https://discuss.frappe.io/t/guide-how-to-install-erpnext-v15-on-linux-ubuntu-step-by-step-instructions/111706)
- [ERPNext v14 Installation (Aug 2022)](https://discuss.frappe.io/t/guide-how-to-install-erpnext-v14-on-linux-ubuntu-step-by-step-instructions/92960)
