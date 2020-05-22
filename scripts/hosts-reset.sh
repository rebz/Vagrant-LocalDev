#!/usr/bin/env bash

# Remove any LOCAL-DEV entries from /etc/hosts and prepare for adding new ones.

sudo sed -i '/#### LOCAL-DEV-SITES-BEGIN/,/#### LOCAL-DEV-SITES-END/d' /etc/hosts

printf "#### LOCAL-DEV-SITES-BEGIN\n#### LOCAL-DEV-SITES-END\n" | sudo tee -a /etc/hosts > /dev/null