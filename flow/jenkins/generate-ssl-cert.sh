#!/bin/bash
set -e

# Create directory for SSL certificates
mkdir -p nginx/ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/privkey.pem \
  -out nginx/ssl/fullchain.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=jenkins.example.com"

# Set proper permissions
chmod 600 nginx/ssl/privkey.pem
chmod 644 nginx/ssl/fullchain.pem

echo "Self-signed SSL certificate generated successfully."
echo "For production use, replace these with proper certificates from a trusted CA."
