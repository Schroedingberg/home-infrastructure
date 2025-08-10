#!/bin/bash
# deploy.sh - Main deployment script

set -e

echo "🚀 Starting paperless-ngx deployment..."


# Check if inventory exists
if [ ! -f "inventory.yml" ]; then
    echo "❌ inventory.yml not found. Please create it first."
    exit 1
fi

# Check if group_vars/all.yml exists
if [ ! -f "group_vars/all.yml" ]; then
    echo "❌ group_vars/all.yml not found. Please create it first."
    exit 1
fi

# Run the playbook
echo "📋 Running Ansible playbook..."
uv run ansible-playbook -i inventory.yml playbook.yml

echo "✅ Deployment complete!"
echo ""
echo "🌐 Your services should be available at:"
while IFS= read -r line; do
    if [[ $line =~ name:\ ([^[:space:]]+) ]]; then
        name="${BASH_REMATCH[1]}"
    elif [[ $line =~ subdomain:\ ([^[:space:]]+) ]]; then
        subdomain="${BASH_REMATCH[1]}"
        echo "  - https://${subdomain}.$(grep 'domain:' group_vars/all.yml | cut -d' ' -f2)"
    fi
done < group_vars/all.yml

