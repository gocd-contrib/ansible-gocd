# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'go'
  config.vm.box = "vagrant-centos-65-x86_64-minimal"
  config.vm.box_url = "http://files.brianbirkinbine.com/vagrant-centos-65-x86_64-minimal.box"

  if Vagrant.has_plugin?("vagrant-cachier")
  	config.cache.scope = :machine
  	config.cache.auto_detect = true
      # If you are using VirtualBox, you might want to use that to enable NFS for
      # shared folders. This is also very useful for vagrant-libvirt if you want
      # bi-directional sync
      # config.cache.synced_folder_opts = {
      #   type: :nfs,
      #   # The nolock option can be useful for an NFSv3 client that wants to avoid the
      #   # NLM sideband protocol. Without this option, apt-get might hang if it tries
      #   # to lock files needed for /var/cache/* operations. All of this can be avoided
      #   # by using NFSv4 everywhere. Please note that the tcp option is not the default.
      #   mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
      # }
  end
  

	# support docker
	config.vm.provider :docker do |docker, override|
		override.vm.box = 'dummy'
		override.vm.box_url = 'http://bit.ly/vagrant-docker-dummy'
		docker.image = "tlalexan/vagrant-centos:latest"
	end

	# configure ansible...
    config.vm.provision "ansible" do |ansible|
        ansible.host_key_checking = false
        ansible.playbook = "site.yml"
        ansible.sudo = true
        ansible.verbose = ''
        ansible.extra_vars = {
	      gocd: {
	        agent: {
	          instances: 2
	        },
	        server: {
	          host: "127.0.0.1",
	          port: 8153,
	          autoregister_key: "this-is-insecure"
	        }
	      }
	  	}
	end

	# machines are defined here...

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", "1500"]
  end
  config.vm.network :private_network, ip: "192.168.50.2"

	
end
