#!/bin/bash
set -e

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create it from .env.example"
    echo "cp .env.example .env"
    exit 1
fi

# Check if SSL certificates exist
if [ ! -f nginx/ssl/fullchain.pem ] || [ ! -f nginx/ssl/privkey.pem ]; then
    echo "SSL certificates not found. Generating self-signed certificates..."
    ./generate-ssl-cert.sh
fi

# Create necessary directories
mkdir -p nginx/logs
mkdir -p grafana/dashboards

# Start the services
echo "Starting n8n high availability deployment..."
docker-compose up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Check service status
echo "Checking service status..."
docker-compose ps

echo "n8n high availability deployment is now running."
echo "Access the n8n interface at https://your-domain.com"
echo "Access Grafana at https://your-domain.com:3000"
