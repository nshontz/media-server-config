#!/bin/bash

# Bootstrap script for setting up Jellyfin media server
# Usage: ./bootstrap.sh <username> <ip_address>

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <ip_address>"
    echo "Example: $0 myuser 192.168.1.100"
    exit 1
fi

USERNAME="$1"
IP_ADDRESS="$2"

# Check if SSH public key exists
PUBLIC_KEY_FILE="$HOME/.ssh/id_rsa.pub"
if [ ! -f "$PUBLIC_KEY_FILE" ]; then
    echo "No SSH public key found at $PUBLIC_KEY_FILE"
    echo "Generating new SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
fi

echo "Copying public key to ${USERNAME}@${IP_ADDRESS}..."
ssh-copy-id -i "$PUBLIC_KEY_FILE" "${USERNAME}@${IP_ADDRESS}"

echo "Setting up Jellyfin media server on ${USERNAME}@${IP_ADDRESS}..."

# Create the server setup script
cat > /tmp/jellyfin_setup.sh << 'EOF'
#!/bin/bash
set -e

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing required packages..."
sudo apt install -y openssh-server wget vim lsb-release curl apt-transport-https ca-certificates ufw samba

echo "Installing Jellyfin..."
wget -O- https://repo.jellyfin.org/jellyfin_team.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/jellyfin-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jellyfin-archive-keyring.gpg arch=amd64] https://repo.jellyfin.org/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list
sudo apt update
sudo apt install -y jellyfin

echo "Starting and enabling Jellyfin service..."
sudo systemctl enable jellyfin
sudo systemctl start jellyfin

echo "Configuring firewall for Jellyfin..."
sudo ufw allow 8096/tcp
sudo ufw allow 8920/tcp
sudo ufw allow 1900/udp
sudo ufw allow 7359/udp
sudo ufw --force enable

echo "Creating shared media directory..."
sudo mkdir -p /srv/media
sudo chmod 755 /srv/media
sudo chown nobody:nogroup /srv/media

echo "Setting up Samba share for media folder..."
sudo tee -a /etc/samba/smb.conf << 'SAMBA_EOF'

[media]
    path = /srv/media
    browseable = yes
    read only = no
    guest ok = yes
    create mask = 0664
    directory mask = 0775
    force user = nobody
    force group = nogroup
SAMBA_EOF

sudo systemctl restart smbd
sudo systemctl enable smbd

echo "Installing Certbot for Let's Encrypt SSL..."
sudo apt install -y snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -sf /snap/bin/certbot /usr/bin/certbot

echo "Opening Samba ports in firewall..."
sudo ufw allow samba

echo "Setup complete!"
echo "Jellyfin is available at: http://$(hostname -I | awk '{print $1}'):8096"
echo "Shared media folder is available at: //$(hostname -I | awk '{print $1}')/media"
echo ""
echo "To complete setup:"
echo "1. Access Jellyfin web interface and complete initial setup"
echo "2. Add media libraries pointing to /srv/media"
echo "3. For SSL certificate, run: sudo certbot --nginx -d your-domain.com"
echo "4. Configure remote access in Jellyfin settings"
EOF

# Copy and execute the setup script on the remote server
scp /tmp/jellyfin_setup.sh ${USERNAME}@${IP_ADDRESS}:/tmp/
ssh ${USERNAME}@${IP_ADDRESS} "chmod +x /tmp/jellyfin_setup.sh && /tmp/jellyfin_setup.sh"

echo "Successfully set up Jellyfin media server on ${USERNAME}@${IP_ADDRESS}"
echo "Access Jellyfin at: http://${IP_ADDRESS}:8096"