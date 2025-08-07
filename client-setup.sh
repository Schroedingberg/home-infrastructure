!#/bin/bash


# PACKAGES

sudo apt install keepassxc

sudo apt install xclip

sudo apt install nextcloud-client

## uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env


uv add ansible


## vscode


sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm -f microsoft.gpg


sudo echo 'Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg' > /etc/apt/sources.list.d/vscode.sources
