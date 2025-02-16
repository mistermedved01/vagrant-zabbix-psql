sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c | awk "{print $2}")-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt update
apt install postgresql-14 postgresql-contrib-14 -y

sudo -u postgres psql -c "CREATE USER zabbix WITH PASSWORD 'zabbix';"
sudo -u postgres psql -c "CREATE DATABASE zabbix OWNER zabbix;"

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf
sed -i "/# IPv4 local connections/i host    all             all             192.168.1.111/32        trust" /etc/postgresql/14/main/pg_hba.conf

systemctl restart postgresql