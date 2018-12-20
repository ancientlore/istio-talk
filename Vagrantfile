Vagrant.configure("2") do |config|

  # Build 
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = true

  config.vm.network "private_network", ip: "192.168.99.101"

  #config.vm.network "forwarded_port", guest: 8080, host: 8080
  #config.vm.network "forwarded_port", guest: 8081, host: 8081
  #config.vm.network "forwarded_port", guest: 8082, host: 8082

  config.vm.provider "virtualbox" do |v|
    v.name = "istiotalk"
    v.memory = "4096"
    v.cpus = "2"
  end

  config.vm.provision "shell", path: "vagrant/setup.sh"
  
end
