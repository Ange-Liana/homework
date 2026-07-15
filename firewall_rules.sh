#!/bin/bash


iptables -F

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

HOST=$(hostname)

if [ "$HOST" = "web-01" ] || [ "$HOST" = "web-02" ]; then
    echo "Configuring firewall for $HOST..."

    iptables -A INPUT -p tcp --dport 22 -j ACCEPT

    iptables -A INPUT -p tcp -s 172.25.0.10 --dport 80 -j ACCEPT

    iptables -A INPUT -i lo -j ACCEPT

    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

elif [ "$HOST" = "lb-01" ]; then
    echo "Configuring firewall for $HOST..."

    iptables -A INPUT -p tcp --dport 22 -j ACCEPT


    iptables -A INPUT -p tcp --dport 443 -j ACCEPT

    
    iptables -A INPUT -i lo -j ACCEPT

    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

else
    echo "Unknown host: $HOST"
    exit 1
fi

echo "Firewall rules applied successfully."
