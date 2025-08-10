# home-infrastructure# Paperless-ngx Multi-User Ansible Setup

This setup provides a scalable, reproducible deployment of paperless-ngx with per-user isolation and a centralized reverse proxy.

## Architecture Overview

- **Single Caddy reverse proxy** handles SSL/TLS termination and routes requests to user-specific containers
- **Per-user isolated environments** with dedicated databases, Redis instances, and data directories  
- **Port-based routing** with Caddy proxying subdomains to specific ports
- **Extensible template system** for adding other services

## Directory Structure

```
ansible/
├── playbook.yml                    # Main playbook
├── inventory.yml                   # Server inventory
├── group_vars/
│   └── all.yml                     # Global configuration
├── templates/
│   ├── caddy/
│   │   └── Caddyfile.j2           # Reverse proxy config
│   └── paperless/
│       ├── docker-compose.yml.j2  # Paperless service template
│       └── .env.j2                # Environment variables template
├── deploy.sh                      # Main deployment script
├── add-user.sh                    # Add new user script
└── add-service.sh                 # Add new service template script
```

## Quick Start

### 1. Initial Setup

```bash
# Clone/create your ansible directory
mkdir ansible && cd ansible

# Copy all the provided files into their respective locations
# (See the artifacts above for file contents)

# Make scripts executable
chmod +x *.sh
```

### 2. Configure Your Setup

Edit `group_vars/all.yml`:
```yaml
domain: your-domain.com  # Change this to your domain

users:
  - name: john
    subdomain: john  
    port: 8001
    email: john@your-domain.com
  - name: jane
    subdomain: jane
    port: 8002  
    email: jane@your-domain.com
```

Edit `inventory.yml`:
```yaml
all:
  hosts:
    paperless-server:
      ansible_host: YOUR_HETZNER_SERVER_IP
      ansible_user: root
      ansible_ssh_private_key_file: ~/.ssh/your_private_key
```

### 3. Deploy

```bash
./deploy.sh
```

### 4. Add More Users

```bash
./add-user.sh alice alice alice@your-domain.com
./deploy.sh
```

## Adding Other Services

### Method 1: Using the Helper Script

```bash
./add-service.sh nextcloud
# Edit templates/nextcloud/docker-compose.yml.j2
# Edit templates/nextcloud/.env.j2
```

### Method 2: Manual Template Creation

1. Create a new directory under `templates/` (e.g., `templates/nextcloud/`)
2. Add `docker-compose.yml.j2` and `.env.j2` templates
3. Modify the playbook to include tasks for the new service

### Example: Adding Nextcloud

Create `templates/nextcloud/docker-compose.yml.j2`:
```yaml
version: "3.4"
services:
  nextcloud:
    image: nextcloud:latest
    restart: unless-stopped
    ports:
      - "{{ user.port }}:80"
    volumes:
      - ./data:/var/www/html
    environment:
      - NEXTCLOUD_ADMIN_USER={{ user.name }}
      - NEXTCLOUD_ADMIN_PASSWORD=${NEXTCLOUD_ADMIN_PASSWORD}
      - NEXTCLOUD_TRUSTED_DOMAINS={{ user.subdomain }}.{{ domain }}
    env_file: .env

volumes:
  data:
```

Then add tasks to the playbook to deploy this service alongside paperless.

## Security Considerations

- Each user runs in their own Docker network namespace
- Caddy handles SSL/TLS termination automatically via Let's Encrypt
- User data is isolated in separate directories with proper permissions
- Firewall configured to only allow necessary ports
- Random passwords generated for each deployment

## Backup Strategy

User data is stored in `/home/{username}/{service}/data/`. You can easily backup these directories:

```bash
# Backup all user data
for user in john jane; do
    tar -czf "backup-${user}-$(date +%Y%m%d).tar.gz" "/home/${user}/"
done
```

## Troubleshooting

### Check service status
```bash
# Check if containers are running for a user
sudo -u john docker-compose -f /home/john/paperless/docker-compose.yml ps

# Check Caddy status
systemctl status caddy

# Check Caddy logs
journalctl -u caddy -f
```

### Common Issues

1. **Port conflicts**: Ensure each user has a unique port in `group_vars/all.yml`
2. **DNS not resolving**: Make sure your subdomains point to your server IP
3. **SSL issues**: Check Caddy logs and ensure your domain is publicly accessible
4. **Permission issues**: Verify user ownership of service directories

## Scaling

This setup can easily scale to dozens of users. For larger deployments, consider:
- Using external databases (PostgreSQL cluster)
- Implementing log rotation
- Adding monitoring (Prometheus/Grafana)
- Using Docker Swarm or Kubernetes for orchestration

## Service Templates

The template system makes it easy to add new services. Each service needs:
- `docker-compose.yml.j2` - Service definition with port templating
- `.env.j2` - Environment variables with user-specific values

The playbook automatically processes any service templates you add to the `templates/` directory.