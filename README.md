
# Practica 01-04
Nos aparecerá en el navegador para darle a este sitio no es seguro, si le damos en la barra de búsqueda la opción de no es seguro podemos meternos en el certificado para ver los datos metidos en el *.env*

En la ruta *C:\Windows\System32\drivers\etc\hosts* tenemos que editar el archivo para poner la IP de la instancia y un nombre para que salga en la URL del navegador

En esta practica tenemos que tener 2 carpetas, la primera la llamaremos *Scripts* y otra llamada *Conf*
Dentro de la carpeta Scripts tendremos los siguientes archivos: 
*install_lamp.sh*, *setup_selfsigned_certificate.sh* y *.env*.
Dentro de la carpeta Conf hay que tener: *000-default.conf* y *default-ssl.conf*.
## install_lamp.sh

    #!/bin/bash

Muestra todos los comandos que se van ejecutando

    set -x
Actualizamos los repositorios

    apt update

Actualizamos los paquetes 

    apt upgrade -y

Instalamos el servidor web **Apache**

    apt install apache2 -y

Instalar  el sistema gestor de datos **MySQL**

    apt install mysql-server -y

Instalamos **PHPMyAdmin**

    sudo apt install php libapache2-mod-php php-mysql -y

Copiar el archivo de configuración de **Apache**

    cp ../conf/000-default.conf /etc/apache2/sites-available

Reiniciamos **Apache**

    systemctl restart apache2

Copiamos el archivo de prueba de **PHPMyAdmin**

    cp ../php/index.php /var/www/html

Modificamos el propietario de la carpeta */var/www/html*

    chown -R www-data:www-data /var/www/html


## setup_selfsigned_certificate.sh

    #!/bin/bash

Muestra todos los comandos que se van ejecutando

    set -x

Actualizamos los repositorios

    apt update

Actualizamos los paquetes 

    #apt upgrade -y

Ponemos las variables del archivo *.env*

    source .env

Creamos un certificado y una clave privada

    sudo openssl req \
      -x509 \
      -nodes \
      -days 365 \
      -newkey rsa:2048 \
      -keyout /etc/ssl/private/apache-selfsigned.key \
      -out /etc/ssl/certs/apache-selfsigned.crt \
      -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"

Consultar la información del sujeto del certificado

    openssl x509 -in /etc/ssl/certs/apache-selfsigned.crt -noout -subject

Consultamos el archivo de configuración del **VirtualHost** donde queremos habilitar el tráfico **HTTPS**

    cat /etc/apache2/sites-available/default-ssl.conf

Copiamos el archivo de configuración de **Apahe** para **HTTPS**

    cp ../conf/default-ssl.conf /etc/apache2/sites-available/

Habilitamos el **VirtualHost** que acabamos de configurar.

    a2ensite default-ssl.conf

Habilitamos el módulo **SSL** en **Apache**.

    a2enmod ssl

Configuramos el virtual host de **HTTP** para que redirija todo el tráfico a **HTTPS**.
Copiamos el archivo de configuración de **VirtualHost** para **HTTP**.

    cp ../conf/000-default.conf /etc/apache2/sites-available

Habilitamos el módulo **Rewrite**

    a2enmod rewrite

Reiniciamos el servicio **Apache**

    systemctl restart apache2

## .env
Configuramos las variables con los datos que necesita el certificado

    OPENSSL_COUNTRY="SP"
    OPENSSL_PROVINCE="Almeria"
    OPENSSL_LOCALITY="Almeria"
    OPENSSL_ORGANIZATION="IES Celia Vinas"
    OPENSSL_ORGUNIT="IAW"
    OPENSSL_COMMON_NAME="practicaiaw.local"
    OPENSSL_EMAIL="gsanmoy472@g.educaand.es"

## default-ssl.conf

    ServerSignature Off
    ServerTokens Prod
    
    <VirtualHost *:443>
        #ServerName practica-https.local
        DocumentRoot /var/www/html
        DirectoryIndex index.php index.html
        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    </VirtualHost>


## 000-default.conf

    <VirtualHost *:80>
        # ServerName practica-https.local
        DocumentRoot /var/www/html
    
        # Redirige al puerto 443 (HTTPS)
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
    </VirtualHost>

