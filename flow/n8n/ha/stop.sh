#!/bin/bash
set -e

echo "Stopping n8n high availability deployment..."
docker-compose down

echo "n8n high availability deployment has been stopped."
echo "Data is preserved in Docker volumes."
