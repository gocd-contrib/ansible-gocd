
Vagrant.configure("2") do |config|
  config.vm.hostname = 'go'
  config.vm.box = 'opscode-fedora-20'
  config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-20_chef-provisionerless.box'
  # config.vm.box = 'opscode-fedora-19'
  # config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-19_chef-provisionerless.box'
  # config.vm.box = 'opscode-centos-6.5'
  # config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box'
  # config.vm.box = 'opscode-ubuntu-13.10'
  # config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.10_chef-provisionerless.box'

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

  # Support testing roles by themselves.  You can't specify this on command line, but can via environment variable.
  # This assumes you've checked out into a directory matching the role name (ansible-gocd)
  ENV['ANSIBLE_ROLES_PATH'] = '..'

	# configure ansible...
    config.vm.provision "ansible" do |ansible|
        ansible.host_key_checking = false
        ansible.playbook = "site.yml"
        # Set tags to either server or agent as needed.  Default is both.
        #ansible.tags = "server,agent"
        ansible.sudo = true
        ansible.verbose = ''
        # Use this if you want to override the Role defaults for example to force a specific number of agents.
        ansible.extra_vars = {
          GOCD_ADMIN_EMAIL: 'tpbrown@gmail.com'
          # GOCD_AGENT_INSTANCES: 2
      }
	end

	# machines are defined here...

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", "2048"]
  end
  # config.vm.network :private_network, ip: "192.168.50.2"
  config.vm.network "forwarded_port", guest:8153, host: 8153

	
end
