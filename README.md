# :rocket:Vagrant установка Zabbix и PostgreSQL:

:gear:Создает две ВМ (Ubuntu 22.04 LTS):

**zabbix_serv** - Zabbix Version: 7.0, Web Server: Nginx, PHP Version: 8.1

**zabbix_db** - PostgreSQL 14

## Тревобания

- **Vagrant** (version 2.2+)
- **VirtualBox**

**Установка**

**1. Клонируем репозиторий:**
```bash
git clone https://github.com/mistermedved01/vagrant-zabbix-psql.git
cd vagrant-zabbix-psql
```

**2. Инициализируем ВМ в Vagrant:**
```bash    
vagrant up
```    
**3. Доступ к веб-интерфейсу Zabbix:**

После того как ВМ будут запущены, доступ к веб-интерфейсу Zabbix:

http://192.168.1.111

***login:pass - Admin:zabbix***

**:fire:Удалить ВМ:**
```bash
vagrant destroy
```