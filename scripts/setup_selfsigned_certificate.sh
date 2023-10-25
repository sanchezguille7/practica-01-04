#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -x

# Actualizamos los repositorios
apt update

# Actualizamos los paquetes 
#apt upgrade -y

# Ponemos las variables del archivo .env
source .env

# Creamos un certificado y una clave privada
sudo openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"

# Consultar la información del sujeto del certificado
# openssl x509 -in /etc/ssl/certs/apache-selfsigned.crt -noout -subject

# Consultamos el archivo de configuración del virtual host donde queremos habilitar el tráfico HTTPS
# cat /etc/apache2/sites-available/default-ssl.conf

# Copiamos el archivo de configuracion de Apahe para HTTPS
cp ../conf/default-ssl.conf /etc/apache2/sites-available/

# Habilitamos el virtual host que acabamos de configurar.
a2ensite default-ssl.conf

# Habilitamos el módulo SSL en Apache.
a2enmod ssl

# Configuramos el virtual host de HTTP para que redirija todo el tráfico a HTTPS.
# Copiamos el archivo de configuracion de VirtualHost para HTTP.
cp ../conf/000-default.conf /etc/apache2/sites-available

# Hablitamos el modulo rewrite
a2enmod rewrite

# Reiniciamos el servicio Apache
systemctl restart apache2