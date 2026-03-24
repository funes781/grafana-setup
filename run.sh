#!/bin/bash

GF_PASSWORD=$(openssl rand -base64 16)
API_TOKEN=$(openssl rand -hex 32)

SERVER_IP=$(hostname -I | awk '{print $1}')

echo "GF_SECURITY_ADMIN_PASSWORD=$GF_PASSWORD" > .env
echo "API_TOKEN=$API_TOKEN" >> .env
echo "SERVER_IP=$PUBLIC_IP" >> .env


if ! [ -x "$(command -v docker)" ]; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

if docker compose version > /dev/null 2>&1; then
    docker compose up -d --build
elif docker-compose version > /dev/null 2>&1; then
    docker-compose up -d --build
else
    echo "ERROR: Neither 'docker compose' nor 'docker-compose' was found!"
    exit 1
fi

echo "------------------------------------------------"
echo "IM AM RUNNING <3"
echo "------------------------------------------------"
echo "------------------------------------------------"
echo "API (HTTPS): https://$(curl -s ifconfig.me)/log"
echo "API Token: $API_TOKEN"
echo "Grafana: http://$(curl -s ifconfig.me):3000"
echo "Grafana Password: $GF_PASSWORD"
echo "------------------------------------------------"
echo "SAVE THESE KEYS! They are also stored in .env file."