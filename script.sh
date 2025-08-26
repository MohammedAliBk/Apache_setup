#!/bin/bash
#================================================================
#  Script: setup_apache_pro.sh
#  Purpose: Install and configure Apache server on Debian/Ubuntu
#  Author: Mohamed Ali
#================================================================

set -euo pipefail
IFS=$'\n\t'

#-------------------------------
# Variables
#-------------------------------
APACHE_DIR="/var/www/html"
LOG_FILE="$HOME/setup_apache.log"

#-------------------------------
# Functions
#-------------------------------

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
}

# Trap any error and log it
trap 'log_error "Error occurred at line $LINENO. Exiting."' ERR

check_command() {
    command -v "$1" &> /dev/null || { log_error "$1 command not found! Exiting."; exit 1; }
}

update_system() {
    log_info "Updating system packages..."
    sudo apt update -y && sudo apt upgrade -y
}

install_apache() {
    log_info "Installing Apache2..."
    sudo apt install -y apache2
}

start_enable_apache() {
    log_info "Enabling and starting Apache service..."
    sudo systemctl enable apache2
    sudo systemctl start apache2
}

configure_firewall() {
    if command -v ufw &> /dev/null; then
        log_info "Configuring UFW firewall for Apache..."
        sudo ufw allow 'Apache Full'
        sudo ufw reload
    else
        log_info "UFW not installed, skipping firewall configuration."
    fi
}

create_test_page() {
    log_info "Creating test HTML page..."
    cat <<EOF | sudo tee "$APACHE_DIR/index.html" > /dev/null
<!DOCTYPE html>
<html>
<head>
<title>Apache Server Test</title>
</head>
<body>
<h1>Apache is running! 🚀</h1>
<p>Server setup successful on $(hostname).</p>
</body>
</html>
EOF
}

check_apache_status() {
    log_info "Checking Apache status..."
    sudo systemctl status apache2 --no-pager
}

#-------------------------------
# Main Script
#-------------------------------
log_info "Starting Apache setup script..."

# Check dependencies
check_command apt
check_command systemctl

# Execute steps
update_system
install_apache
start_enable_apache
configure_firewall
create_test_page
check_apache_status

log_info "Apache setup complete! Visit http://localhost or your server IP to test."

