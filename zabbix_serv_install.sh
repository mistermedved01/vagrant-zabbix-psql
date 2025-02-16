# Обновление системы
apt update
# Загрузка и установка репозитория Zabbix
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb
dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb
apt update
# Установка необходимых пакетов
apt install -y zabbix-server-pgsql zabbix-frontend-php php8.1-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
# Ищет строку, начинающуюся с #, затем заменяет 8080 на 80, убирая комментарий
sed -i 's/#\s*listen\s*8080;/\tlisten 80;/g' /etc/zabbix/nginx.conf

# Разархивация SQL-скрипта для PostgreSQL
gunzip /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz

# Установка PostgreSQL клиента
apt install -y postgresql-client

# Импортирование SQL-скрипта в базу данных Zabbix
sudo -u zabbix psql -h 192.168.1.110 -U zabbix -d zabbix -f /usr/share/zabbix-sql-scripts/postgresql/server.sql

# Настройка конфигурации Zabbix server
sed -i 's/# DBPassword=.*/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf
sed -i 's/# DBHost=.*/DBHost=192.168.1.110/' /etc/zabbix/zabbix_server.conf

systemctl enable --now zabbix-server zabbix-agent

# Настройка Nginx для Zabbix
echo "server {
    listen 80;
    server_name localhost;

    root /usr/share/zabbix;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}" > /etc/nginx/sites-available/default

sed -i 's/post_max_size = 8M/post_max_size = 16M/' /etc/php/8.1/cli/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 16M/' /etc/php/8.1/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 16M/' /usr/lib/php/8.1/php.ini-production
sed -i 's/post_max_size = 8M/post_max_size = 16M/' /usr/lib/php/8.1/php.ini-development
sed -i 's/post_max_size = 8M/post_max_size = 16M/' /usr/lib/php/8.1/php.ini-production.cli
sed -i 's/post_max_size = 2M/post_max_size = 16M/' /etc/zabbix/php-fpm.conf

# Изменить max_execution_time и max_input_time во всех php.ini файлах
find /etc/php/ -type f -name "*.ini" -exec sed -i 's/max_execution_time = 30/max_execution_time = 300/' {} \;
find /etc/php/ -type f -name "*.ini" -exec sed -i 's/max_input_time = 60/max_input_time = 300/' {} \;

cat <<EOF | sudo tee /usr/share/zabbix/conf/zabbix.conf.php > /dev/null
<?php
// Zabbix GUI configuration file.

\$DB['TYPE'] = 'POSTGRESQL';
\$DB['SERVER'] = '192.168.1.110';
\$DB['PORT'] = '5432';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER'] = 'zabbix';
\$DB['PASSWORD'] = 'zabbix';

// Schema name. Used for PostgreSQL.
\$DB['SCHEMA'] = '';

// Used for TLS connection.
\$DB['ENCRYPTION'] = true;
\$DB['KEY_FILE'] = '';
\$DB['CERT_FILE'] = '';
\$DB['CA_FILE'] = '';
\$DB['VERIFY_HOST'] = false;
\$DB['CIPHER_LIST'] = '';

// Vault configuration. Used if database credentials are stored in Vault secrets manager.
\$DB['VAULT'] = '';
\$DB['VAULT_URL'] = '';
\$DB['VAULT_PREFIX'] = '';
\$DB['VAULT_DB_PATH'] = '';
\$DB['VAULT_TOKEN'] = '';
\$DB['VAULT_CERT_FILE'] = '';
\$DB['VAULT_KEY_FILE'] = '';

// Uncomment to bypass local caching of credentials.
// \$DB['VAULT_CACHE'] = true;

// Uncomment and set to desired values to override Zabbix hostname/IP and port.
// \$ZBX_SERVER = '';
// \$ZBX_SERVER_PORT = '';

\$ZBX_SERVER_NAME = 'Zabbix';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;

// Uncomment this block only if you are using Elasticsearch.
// Elasticsearch url (can be string if same url is used for all types).
//\$HISTORY['url'] = [
//  'uint' => 'http://localhost:9200',
//  'text' => 'http://localhost:9200'
//];
// Value types stored in Elasticsearch.
//\$HISTORY['types'] = ['uint', 'text'];

// Used for SAML authentication.
// Uncomment to override the default paths to SP private key, SP and IdP X.509 certificates, and to set extra settings.
//\$SSO['SP_KEY'] = 'conf/certs/sp.key';
//\$SSO['SP_CERT'] = 'conf/certs/sp.crt';
//\$SSO['IDP_CERT'] = 'conf/certs/idp.crt';
//\$SSO['SETTINGS'] = [];

// If set to false, support for HTTP authentication will be disabled.
// \$ALLOW_HTTP_AUTH = true;
EOF

chown www-data:www-data /usr/share/zabbix/conf/zabbix.conf.php
chmod 644 /usr/share/zabbix/conf/zabbix.conf.php

systemctl restart nginx php8.1-fpm
systemctl restart nginx
systemctl restart zabbix-server.service