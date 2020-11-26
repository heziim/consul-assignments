#!/bin/bash


# Install nginx
sudo apt-get update
sudo apt-get install -y nginx
hostname | sudo tee -a  /var/www/html/index.nginx-debian.html
sudo systemctl start nginx




# Register web service with port 80 and  health check
tee /etc/consul.d/web.json > /dev/null <<EOF
{
  "service": {
    "name": "webserver",
    "tags": [
      "nginx"
    ],
    "port": 80,
    "check": {
      "args": [
        "curl",
        "localhost"
      ],
      "interval": "5s",
      "success_before_passing": 2,
      "failures_before_critical": 2
    }
  }
}
EOF


consul reload

