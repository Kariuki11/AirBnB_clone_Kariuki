#!/usr/bin/env bash

# Performs configuration, Installation, and starts the web server

# Improved comments explaining the specific configurations within the server block
SERVER_CONFIG="
server {
    # Listen on ports 80 and 80 (IPv4 and IPv6)
    listen 80 default_server;
    listen [::]:80 default_server;

    # Handle all requests with server_name directive
    server_name _;

    # Define default document root and error handling
    index index.html index.htm;
    error_page 404 /404.html;

    # Add header to identify server that handled the request
    add_header X-Served-By \$hostname;

    # Serve static content from /var/www/html
    location / {
        root /var/www/html/;
        try_files \$uri \$uri/ =404;
    }

    # Serve dynamic content from /data/web_static/current
    location /hbnb_static/ {
        alias /data/web_static/current/;
        try_files \$uri \$uri/ =404;
    }

    # Redirect specific URL (example)
    if (\$request_filename ~ redirect_me) {
        rewrite ^ https://sketchfab.com/bluepeno/models permanent;
    }

    # Internal location for custom 404 error page
    location = /404.html {
        root /var/www/error/;
        internal;
    }
}"

# Improved homepage content
HOME_PAGE="<!DOCTYPE html>
<html lang='en-US'>
  <head>
    <title>Home - AirBnB Clone</title>
  </head>
  <body>
    <h1>Welcome to AirBnB Clone!</h1>
  </body>
</html>"

# Use a more widely compatible package manager (adjust based on your system)
PACKAGE_MANAGER=$(which apt || which yum)

# Check if Nginx is installed and install it if not installed
if [[ "$(which nginx | grep -c nginx)" == '0' ]]; then
  sudo $PACKAGE_MANAGER update
  sudo $PACKAGE_MANAGER -y install nginx
fi

# Creates directories with proper permissions
mkdir -p /var/www/html /var/www/error
chmod -R 755 /var/www

# Create default content with single-quoted strings
echo 'Hello World!' > /var/www/html/index.html
echo 'This is not a page' > /var/www/error/404.html

# Prepare web application directory (replace with your copy command)
cp -r /data/web_static/releases/test /data/web_static/current

# Manage symbolic link (check if it exists before creating)
if [ ! -L /data/web_static/current ]; then
  ln -sf /data/web_static/current /data/web_static/
fi

# Set ownership for the web application directory
chown -hR ubuntu:ubuntu /data

# Configure Nginx with improved error handling
bash -c "echo -e '$SERVER_CONFIG' > /etc/nginx/sites-available/default" || { echo 'Failed to create Nginx server configuration'; exit 1; }

ln -sf '/etc/nginx/sites-available/default' '/etc/nginx/sites-enabled/default'

# Start or restart Nginx service
if [ "$(pgrep -c nginx)" -le 0 ]; then
  sudo service nginx start
else
  sudo service nginx restart
fi

# Script output (informational)
echo "Web server setup complete!"