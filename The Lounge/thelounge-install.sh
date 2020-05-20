#!/bin/bash

# The Lounge Installer by Xan#7777
# Quick and dirty way to install The Lounge to USB Slot
# Install NVM and Node using the following command

# curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash && source .bashrc && nvm install node


# Install The Lounge
npm install --global --unsafe-perm thelounge

# Generate Config file and Test The Lounge Installation
timeout 5 thelounge start

# Unused Port Picker
app-ports show

echo "Pick any application from this list that you're not currently using."
echo "We'll be using this port for The Lounge."
echo "For example, you chose SickRage so type in 'sickrage'. Please type it in full name."
echo "Type in the application below."

read -r appname
proper_app_name=$(app-ports show | grep -i "$appname" | cut -c 7-)
port=$(app-ports show | grep -i "$appname" | cut -b -5)

echo "Are you sure you want to use $proper_app_name's port? type 'confirm' to proceed."
read -r input
if [ ! "$input" = "confirm" ]
then
    exit
fi

# Sed ZNC Port
sed  -i "s/port: 9000,/port: $port,/g" "$HOME"/.thelounge/config.js

# Set NGINX conf
echo 'location ^~ /thelounge/ {
    proxy_pass http://127.0.0.1:>port</;
    proxy_redirect      off;
    proxy_connect_timeout 300;
    proxy_send_timeout 300;
    proxy_read_timeout 300;
    proxy_set_header Connection "upgrade";
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
}' > "$HOME/.apps/nginx/proxy.d/thelounge.conf"

sed  -i "s/>port</$port/g" "$HOME"/.apps/nginx/proxy.d/thelounge.conf

# Set reverseProxy on conf

sed  -i "s/reverseProxy: false,/reverseProxy: true,/g" "$HOME"/.thelounge/config.js

app-nginx restart

# Systemd service

echo "[Unit]
Description=The Lounge

[Service]
Type=simple

WorkingDirectory=$NVM_DIR/versions/node/v14.2.0
ExecStart=$(command -v node) bin/thelounge start

[Install]
WantedBy=default.target" > "$HOME/.config/systemd/user/thelounge.service"

systemctl --user daemon-reload
systemctl --user start thelounge.service
systemctl --user enable thelounge.service

echo ""
echo ""
echo "Installation complete."
echo "You can access it via https://$USER.$HOSTNAME.usbx.me/thelounge"
echo "Run the command below to add username before accessing The Lounge"
echo ""
echo "============================="
echo "thelounge add <name>"
echo "============================="

exit