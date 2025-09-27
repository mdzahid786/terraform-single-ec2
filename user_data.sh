#!/bin/bash
# Update and install dependencies
apt-get update -y
apt-get upgrade -y
apt-get install -y python3 python3-pip git

# Install Node.js (Node 20.x via NodeSource)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt-get install -y nodejs


# Git Rep
GIT_REPO="https://github.com/mdzahid786/flask-app.git"

# Clone app
cd /home/ubuntu
git clone $GIT_REPO flask_app
cd flask_app

# Flask App Setup
cd /home/ubuntu/flask_app/backend
mkdir -p /home/ubuntu/flask_app/backend/data
chown -R ubuntu:ubuntu /home/ubuntu/flask_app/backend/data
pip3 install -r requirements.txt  # assuming requirements.txt is in repo


# Create systemd service for Flask
cat <<EOF >/etc/systemd/system/flask.service
[Unit]
Description=Flask Backend Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/flask_app/backend
ExecStart=/usr/bin/python3 /home/ubuntu/flask_app/backend/app.py
Restart=always
Environment=PORT=5000
Environment=BACKEND_STORAGE_PATH=./data

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Flask service
systemctl daemon-reload
systemctl enable flask.service
systemctl start flask.service

# Create Express app
cd /home/ubuntu/flask_app/frontend
npm install

# Create systemd service for Express
cat <<EOF >/etc/systemd/system/express.service
[Unit]
Description=Express Frontend Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/flask_app/frontend
ExecStart=/usr/bin/node /home/ubuntu/flask_app/frontend/app.js
Restart=always
Environment=PORT=8000
Environment=BACKEND_URL=http://localhost:5000

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Express service
systemctl daemon-reload
systemctl enable express.service
systemctl start express.service
