# Ansible Paperless Setup Guide

## What You Need

### 1. SSH Key (if you don't have one)
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# Press Enter to use default location (~/.ssh/id_ed25519)
```

### 2. That's it!
Ansible will generate all other secrets automatically:
- Database passwords
- Paperless secret keys  
- User passwords

No manual secret generation needed!

## Step-by-Step Setup

### Step 1: Install Ansible
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# macOS  
brew install ansible

# Windows (WSL)
sudo apt install ansible
```

### Step 2: Create Project Structure
```bash
mkdir paperless-ansible
cd paperless-ansible

# Create directories
mkdir templates
```

### Step 3: Create Files

Copy the content from the artifacts into these files:

```bash
# Main files
touch playbook.yml inventory.ini

# Templates directory
touch templates/docker-compose.yml.j2
touch templates/Caddyfile.j2
touch templates/env.j2
touch templates/init-db.sql.j2
touch templates/backup.sh.j2
```

### Step 4: Create Hetzner Server Manually

1. Go to [console.hetzner-cloud.com](https://console.hetzner-cloud.com)
2. Create new project (if needed)
3. Add Server:
   - **Location:** Nuremberg (or nearest)
   - **Image:** Ubuntu 22.04
   - **Type:** CX21 (€4.51/month, 4GB RAM for dual setup)
   - **SSH Key:** Upload your public key (~/.ssh/id_ed25519.pub)
   - **Name:** paperless-server

4. **Copy the server IP** when it's created

### Step 5: Update Inventory File

Edit `inventory.ini` and replace:
- `your.server.ip.here` with your actual server IP
- `yourdomain.com` with your actual domain  
- `john` and `jane` with your preferred subdomain names

### Step 6: Run Ansible

```bash
# Test connection first
ansible paperless -i inventory.ini -m ping

# Should return: "pong" 

# Deploy everything
ansible-playbook -i inventory.ini playbook.yml

# This takes about 5-10 minutes
```

### Step 7: Add DNS Records in Strato

Ansible will show you the exact DNS records to add:

```
A  john.yourdomain.com   YOUR_SERVER_IP
A  jane.yourdomain.com   YOUR_SERVER_IP
```

Add these in your Strato DNS management panel.

### Step 8: Access Your Instances

Wait 5-10 minutes for DNS propagation, then visit:
- `https://john.yourdomain.com`  
- `https://jane.yourdomain.com`

**Default login for both:**
- Username: `john` or `jane` (whatever you configured)
- Password: `admin`

**Change the passwords immediately!**

## File Structure

```
paperless-ansible/
├── playbook.yml                    # Main Ansible playbook
├── inventory.ini                   # Server details
└── templates/
    ├── docker-compose.yml.j2       # Docker services template
    ├── Caddyfile.j2               # Reverse proxy config
    ├── env.j2                     # Environment variables
    ├── init-db.sql.j2             # Database setup
    └── backup.sh.j2               # Backup script
```

## What Ansible Does

1. **Updates server and installs packages** (Docker, security tools)
2. **Creates paperless user** with proper permissions
3. **Configures firewall** (only ports 22, 80, 443 open)
4. **Generates all secrets automatically** (stored in /tmp/ locally)
5. **Creates all configuration files** from templates
6. **Starts Docker services** (Caddy, PostgreSQL, Redis, both Paperless instances)
7. **Sets up automated backups** (runs daily at 2 AM) #Not really though -> We're going to set up pull based backup on a homelab and maybe offsite on a storage box, but thats for later
8. **Shows you DNS records to add**

## Managing Your Setup

### Check Status
```bash
# SSH into server
ssh paperless@YOUR_SERVER_IP

# Check service status
./status.sh

# View logs
docker compose logs -f paperless-john
docker compose logs -f paperless-jane
```

### Updates
```bash
# Re-run Ansible to update
ansible-playbook -i inventory.ini playbook.yml

# Or SSH in and update manually
ssh paperless@YOUR_SERVER_IP
cd paperless
docker compose pull
docker compose up -d
```

### Backups
```bash
# Manual backup
ssh paperless@YOUR_SERVER_IP
./backup.sh

# Backups run automatically daily at 2 AM
# Check backup logs
tail -f backup.log
```

## Troubleshooting

### If Ansible fails with "unreachable"
- Check server IP in inventory.ini
- Verify SSH key works: `ssh -i ~/.ssh/id_ed25519 root@SERVER_IP`
- Make sure server is running

### If services don't start
```bash
ssh paperless@SERVER_IP
cd paperless
docker compose logs
```

### If SSL doesn't work
- Check DNS propagation: `nslookup john.yourdomain.com`
- Wait 10-15 minutes for Let's Encrypt
- Check Caddy logs: `docker compose logs caddy`

## Security Features

- ✅ SSH key authentication only
- ✅ Firewall configured (UFW)  
- ✅ Fail2ban for SSH protection
- ✅ Automatic security updates
- ✅ Non-root user for services
- ✅ SSL/TLS encryption
- ✅ Security headers

## Cost Breakdown

- **Hetzner CX21:** €4.51/month
- **Domain:** ~€1/month (at Strato)
- **Total:** ~€5.51/month for both users

## Benefits of This Setup

- ✅ **Simple to run:** One command deployment  
- ✅ **Documented:** Everything in version control
- ✅ **Repeatable:** Can recreate identical setup
- ✅ **Secure:** Best practices built-in
- ✅ **Maintainable:** Easy to update and modify
- ✅ **No lock-in:** Standard Docker setup

Much simpler than Terraform but still gives you automation and documentation!