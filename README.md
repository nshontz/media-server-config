# Jellyfin Ansible Provisioner

This Ansible playbook provisions a Jellyfin media server on Ubuntu 24.04 with essential plugins.

## Hardware

**Server Specifications:**
- **Beelink Mini S12 Pro Mini PC**
- Intel 12th Gen N100 (4C/4T, up to 3.4GHz)
- 16GB DDR4 RAM
- 500GB SSD
- Dual HDMI 4K@60Hz support
- WiFi 6, Bluetooth 5.2
- Low power consumption, NAS capable

## Prerequisites

1. Ubuntu 24.04 server with SSH access
2. Ansible installed on your local machine
3. SSH key configured for passwordless access

## Setup

1. Copy the example inventory file:
   ```bash
   cp inventory.yml.example inventory.yml
   ```

2. Edit `inventory.yml` and replace:
   - `YOUR_STATIC_IP_HERE` with your server's IP address
   - `YOUR_USERNAME_HERE` with your server username
   - `YOUR_PASSWORD_HERE` with your sudo password
   - Update SSH key path if different from `~/.ssh/id_rsa`

3. Test connectivity:
   ```bash
   ansible all -m ping
   ```

## Installation

Run the playbook:
```bash
ansible-playbook jellyfin-playbook.yml
```

## What Gets Installed

- **Jellyfin Media Server** (latest stable version from official repository)
- **Docker & Docker Compose** (for Jellystat)
- **Jellystat** (statistics application for Jellyfin)
- **Plugins:**
  - Session Cleaner
  - SkinManager  
  - Playback Reporting
  - Subtitle Extract
  - Intro Skipper
  - Jellystat (via Docker)

- **Configuration:**
  - Jellyfin service enabled to start on boot
  - Docker service enabled to start on boot
  - Firewall rules for ports 8096 (Jellyfin) and 3000 (Jellystat)
  - Proper file permissions

## Post-Installation

### Jellyfin Setup
1. Access Jellyfin at `http://YOUR_SERVER_IP:8096`
2. Complete the initial setup wizard
3. Configure your media libraries
4. Enable and configure plugins in the admin dashboard
5. Generate an API key for Jellystat integration

### Jellystat Setup  
1. Access Jellystat at `http://YOUR_SERVER_IP:3000`
2. Complete the initial setup
3. Connect to your Jellyfin server using:
   - Jellyfin URL: `http://localhost:8096`
   - API Key: (generated from Jellyfin admin panel)

## Security Notes

**IMPORTANT: Before sharing or deploying:**

- **Never commit `inventory.yml`** - It contains sensitive information
- Use `inventory.yml.example` as a template and add `inventory.yml` to `.gitignore`
- Consider using Ansible Vault for sensitive variables:
  ```bash
  ansible-vault encrypt inventory.yml
  ```
- Change the default passwords in the playbook variables:
  - `jellystat_postgres_password`
  - `jellystat_jwt_secret`
- The server will be accessible on ports 8096 (Jellyfin) and 3000 (Jellystat)
- Regularly update system packages and Jellyfin for security patches