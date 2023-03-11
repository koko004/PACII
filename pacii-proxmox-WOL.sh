#!/bin/bash

apt-get update && apt-get install ethtool

echo 'What interface to enable WOL'
read INTERFACE

# Create service file

cd /etc/systemd/system/
echo "[Unit]
Description=Wake-on-LAN for $INTERFACE
Requires=network.target
After=network.target

[Service]
ExecStart=/usr/sbin/ethtool -s $INTERFACE wol g
ExecStop=/usr/sbin/ethtool -s $INTERFACE wol g

[Install]
WantedBy=multi-user.target" >> wol.service

# Install service

systemctl start wol.service
systemctl enable wol.service
systemctl is-enabled wol.service
systemctl daemon-reload

# Test
ethtool $INTERFACE | grep Wake-on
