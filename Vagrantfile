ENV['VAGRANT_SERVER_URL'] = 'http://vagrant.elab.pro'

Vagrant.configure("2") do |config|
  # Настройка первой VM для Zabbix DB
  config.vm.define "zabbix-db" do |zabbix_db|
    zabbix_db.vm.box = "ubuntu/jammy64"
    zabbix_db.vm.network "private_network", ip: "192.168.1.110"
    zabbix_db.vm.provision "shell", path: "zabbix_db_install.sh"
    zabbix_db.vm.provider "virtualbox" do |vb|
      vb.memory = "2000"
      vb.cpus = 2
    end
  end

  # Настройка второй VM для Zabbix Server
  config.vm.define "zabbix-serv" do |zabbix_serv|
    zabbix_serv.vm.box = "ubuntu/jammy64"
    zabbix_serv.vm.network "private_network", ip: "192.168.1.111"
    zabbix_serv.vm.provision "shell", path: "zabbix_serv_install.sh"
    zabbix_serv.vm.provider "virtualbox" do |vb|
      vb.memory = "2000"
      vb.cpus = 2
    end
  end
end