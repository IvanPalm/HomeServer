# Home Server Setup Guide

This repository documents the configuration and setup of a home server, including details about server configuration, domain management, and services deployed in Docker containers. It serves as a guide to recreate or maintain the setup, with links to dedicated documentation for each service.

---

## Table of Contents

- [Install and Set Up UFW](#install-and-set-up-ufw)
- [Configure SSH Key Authentication](#configure-ssh-key-authentication)
- [Install and Configure Fail2Ban](#install-and-configure-fail2ban)
- [Setting Up a Custom Domain on Cloudfare](#setting-up-a-custom-domain-on-cloudfare)
- [Dockerized Services](#dockerized-services)
  
---

## Introduction

This document outlines the steps to set up and configure my home server. The services included aim to provide a comprehensive solution for file management, media streaming, content organization5, and personal cloud functionality. Each service is run in a containerized environment for easy deployment and management.

---

## Server Configuration

- **Operating System**: Ubuntu 24.04 LTS
- **Hardware**: Lenovo IdeaPad U430
- **Prerequisites**:
  - Non-root admin user with sudo permissions.
  - Docker and Docker Compose installed.

---

## Networking

For the first connection, use password-based access from the admin user on the server.

---

### Install and Set Up UFW

UFW (Uncomplicated Firewall) is a simple and effective way to secure your server by managing incoming and outgoing traffic.

1. **Install UFW** (if not already installed)  

   ```bash
   sudo apt install ufw
   ```

1. **Set Default Rules**  
   Configure UFW to deny all incoming traffic by default and allow all outgoing traffic:  

   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   ```

1. **Allow SSH**  
   Specify the port for SSH to ensure you don't lock yourself out of the server:  

   ```bash
   sudo ufw allow ssh
   ```

1. **Enable UFW**  
   Activate the firewall with the specified rules:  

   ```bash
   sudo ufw enable
   ```

1. **Verify Configuration**  
   Check which ports are allowed and ensure the firewall is active:  

   ```bash
   sudo ufw status
   ```

This setup provides basic protection, restricting access to only the specified ports. Be sure to configure additional rules for any other services you intend to expose.

---

### Configure SSH Key Authentication

1. **Generate an SSH Key Pair**
   On your client machine, generate a secure SSH key pair:  

   ```bash
   ssh-keygen -t rsa -b 4096
   ```

1. **Copy Public Key to Server**
   Transfer the public key to the server with [`ssh-copy-id`](https://linux.die.net/man/1/ssh-copy-id).  

   ```bash
   ssh-copy-id <USER>@<SERVER-IP>
   ```

   Replace `<USER>` and `<SERVER-IP>` with your username and server IP, respectively

1. **Enable Key-Based Login Only**
   Edit the SSH configuration file to allow only key-based authentication:  

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```

   Update the following lines:  

   ```yml
   PermitRootLogin no
   PasswordAuthentication no
   PubkeyAuthentication yes
   ```

   Restart the SSH daemon to apply changes:  

   ```bash
   sudo service sshd restart
   ```

### Install and Configure Fail2Ban

Fail2Ban helps protect against brute-force attacks by banning IPs with repeated failed login attempts.

1. **Install Fail2Ban**  

   ```bash
   sudo apt install fail2ban
   ```

1. **Create a Local Configuration**  
   Copy the default configuration to a new `.local` file:  

   ```bash
   sudo cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
   ```

1. **Set Up an SSH Jail**  
   Add the following to the end of `/etc/fail2ban/fail2ban.local`:  

   ```ini
   [sshd]
   enabled = true
   port = SSH_PORT
   filter = sshd
   logpath = /var/log/auth.log
   maxretry = 3
   bantime = -1
   ```

   > **Note**: `bantime = -1` bans indefinitely. Adjust as needed.

1. **Restart Fail2Ban**  

   ```bash
   sudo service fail2ban restart
   ```

1. **Check Fail2Ban Status**  
   View the status of the SSH jail:  

   ```bash
   sudo fail2ban-client status sshd
   ```

1. **Unban an IP Address**  
   If needed, unban a specific IP:  

   ```bash
   sudo fail2ban-client set sshd unbanip <IP-ADDRESS>
   ```

---

This configuration secures your server by enforcing key-based authentication and adding brute-force protection.

### Setting Up a Custom Domain on Cloudfare

1. **Domain Registration**
   - Register custom domain on [Cloudfare][cloudfare_main].

1. **DNS Configuration**
   - Configured `AAAA` record assigned to home-server public IPv6, setting host to `@`.
   - TODO: Set up subdomains for services (e.g., `nextcloud.mydomain.net`).

1. **Dynamic DNS**
   - Configured `ddclient` as shown below.
   - Set `run_damenon=true` in `/etc/default/ddclient` for `ddclient` to run as a daemon.
   - Forced run in debug mode with `sudo ddclient -daemon=0 -debug -verbose -noquiet -force`.
  
   ```yml
   # Configuration file for ddclient generated by debconf
   #
   # /etc/ddclient.conf
   
   syslog=yes              # log the output to syslog
   ssl=yes                 # use ssl when updating IP
   
   use=web, web=ifconfig.co/ip
   protocol=cloudflare, \
   zone=mydomain.net, \
   login=token, \
   password=my-cloudfare-api-token \
   mydomain.net
   ```

1. **Configure DNS Name-server**
   - By default, the DNS server and DNS domain were set to localhost and to the router.
   - Open the `systemd-resolved` configuration file with `sudo nano /etc/systemd/resolved.conf`.
   - Add the following entries:

   ```yml
   DNS=1.1.1.1 1.0.0.1
   Domains=mydomain.net
   ```

   - Restart the service with `sudo systemctl restart systemd-resolved`.

---

### Dockerized Services

Please see [dedicated guidance](./services/README.md).

---

[cloudfare_main]:https://www.cloudflare.com/
