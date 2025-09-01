# Jellyfin Ansible Provisioner

This Ansible playbook provisions a Jellyfin media server on Ubuntu 24.04 with essential plugins.

## Prerequisites

1. Ubuntu 24.04 server with SSH access
2. Ansible installed on your local machine
3. SSH key configured for passwordless access

## Setup

1. Edit `inventory.yml` and replace:
   - `YOUR_STATIC_IP_HERE` with your server's IP address
   - `YOUR_USERNAME_HERE` with your server username (typically `ubuntu`)
   - Update SSH key path if different from `~/.ssh/id_rsa`

2. Test connectivity:
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

- Change the default passwords in the playbook variables:
  - `jellystat_postgres_password`
  - `jellystat_jwt_secret`
- Consider using Ansible Vault for sensitive variables
- The server will be accessible on ports 8096 (Jellyfin) and 3000 (Jellystat)