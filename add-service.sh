#!/bin/bash
# add-service.sh - Script to add a new service template

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <service-name>"
    echo "Example: $0 nextcloud"
    exit 1
fi

SERVICE_NAME=$1
TEMPLATE_DIR="templates/$SERVICE_NAME"

# Create service template directory
mkdir -p "$TEMPLATE_DIR"

# Create basic docker-compose template
cat > "$TEMPLATE_DIR/docker-compose.yml.j2" << EOF
version: "3.4"
services:
  $SERVICE_NAME:
    image: # Add your service image here
    restart: unless-stopped
    ports:
      - "{{ user.port }}:80"  # Adjust port as needed
    volumes:
      - ./data:/data
    environment:
      # Add service-specific environment variables
    env_file: .env

volumes:
  data:
EOF

# Create basic .env template
cat > "$TEMPLATE_DIR/.env.j2" << EOF
# {{ service_name | upper }} Configuration for {{ user.name }}

# Add service-specific environment variables here
SERVICE_USER={{ user.name }}
SERVICE_EMAIL={{ user.email }}
SERVICE_DOMAIN={{ user.subdomain }}.{{ domain }}
EOF

echo "✅ Created service template at $TEMPLATE_DIR"
echo "📝 Edit the following files:"
echo "   - $TEMPLATE_DIR/docker-compose.yml.j2"
echo "   - $TEMPLATE_DIR/.env.j2"
echo "🔄 Then run: ansible-playbook -i inventory.yml playbook.yml"