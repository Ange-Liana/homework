#!/bin/bash

# Clear existing rules
iptables -F

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

HOST=$(hostname)

if [ "$HOST" = "web-01" ] || [ "$HOST" = "web-02" ]; then
    echo "Configuring firewall for $HOST..."

    # Allow SSH from anywhere
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT

    # Allow HTTP only from the Load Balancer
    iptables -A INPUT -p tcp -s 172.25.0.10 --dport 80 -j ACCEPT

    # Allow loopback interface
    iptables -A INPUT -i lo -j ACCEPT

    # Allow established connections
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

elif [ "$HOST" = "lb-01" ]; then
    echo "Configuring firewall for $HOST..."

    # Allow SSH from anywhere
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT

    # Allow HTTPS from anywhere
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT

    # Allow loopback interface
    iptables -A INPUT -i lo -j ACCEPT

    # Allow established connections
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

else
    echo "Unknown host: $HOST"
    exit 1
fi

echo "Firewall rules applied successfully."
