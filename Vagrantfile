# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_plugin "vagrant-cachier"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "vagrant-centos-65-x86_64-minimal"
    config.vm.box_url = "http://files.brianbirkinbine.com/vagrant-centos-65-x86_64-minimal.box"

	config.cache.scope = :machine
	config.cache.auto_detect = true

	config.vm.provider :docker do |docker, override|
		override.vm.box = 'dummy'
		override.vm.box_url = 'http://bit.ly/vagrant-docker-dummy'
		docker.image = "tlalexan/vagrant-centos:latest"
	end

	config.vm.define 'go' do |node|
		node.vm.provider :virtualbox do |v, override|
			override.vm.network :private_network, ip: "192.168.50.2"
		end

	    node.vm.provision "ansible" do |ansible|
	        ansible.playbook = "site.yml"
	        ansible.sudo = true
	        ansible.verbose = 'vvv'
	    end
	end

	
end
