#!/bin/bash
sudo snap start amazon-ssm-agent
sudo snap services amazon-ssm-agent
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
sudo dpkg -i /tmp/session-manager-plugin.deb
session-manager-plugin