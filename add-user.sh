---
#!/bin/bash  
# add-user.sh - Script to add a new user

set -e

if [ $# -ne 3 ]; then
    echo "Usage: $0 <username> <subdomain> <email>"
    echo "Example: $0 alice alice alice@yourdomain.com"
    exit 1
fi

USERNAME=$1
SUBDOMAIN=$2
EMAIL=$3

# Find next available port
LAST_PORT=$(grep -o 'port: [0-9]*' group_vars/all.yml | awk '{print $2}' | sort -n | tail -1)
NEXT_PORT=$((LAST_PORT + 1))

# Add user to group_vars/all.yml
echo "  - name: $USERNAME" >> group_vars/all.yml
echo "    subdomain: $SUBDOMAIN" >> group_vars/all.yml  
echo "    port: $NEXT_PORT" >> group_vars/all.yml
echo "    email: $EMAIL" >> group_vars/all.yml

echo "✅ Added user $USERNAME with port $NEXT_PORT"
echo "🔄 Run ./deploy.sh to deploy the new user"


