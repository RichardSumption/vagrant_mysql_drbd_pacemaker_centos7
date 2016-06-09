boxes = [ { :name => "node02", :eth1 => "192.168.56.12", :mem => "1024", :cpu => "1", :file_name => "C:/apps/v_disks/node2_disk2.vdi" },
          { :name => "node01", :eth1 => "192.168.56.11", :mem => "1024", :cpu => "1", :file_name => "C:/apps/v_disks/node1_disk2.vdi" } ]

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
   config.vm.box = "Centos7"
   boxes.each do |opts|
      config.vm.define opts[:name] do |config|
         config.vm.hostname = opts[:name]
         config.vm.network :private_network, ip: opts[:eth1],
            virtualbox__intnet: "mynet"
         config.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
#        config.vm.synced_folder "C:\\apps\\__Software", "/software"
         config.vm.provider "virtualbox" do |vb|
            unless File.exist? opts[:file_name]
               vb.customize ['createhd', '--filename', opts[:file_name], '--size', 1000]
            end
            vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', opts[:file_name]]
            vb.customize ["modifyvm", :id, "--memory", opts[:mem]]
            vb.name = opts[:name]
         end
         # setup ssh, repo's & puppet instalation
         config.vm.provision "shell", path: "hostnames.sh"
         # Puppet provisioning
         config.vm.provision :puppet do |puppet|
            puppet.manifests_path = "manifests"
            puppet.module_path = "modules"
#            puppet.hiera_config_path = "hiera.yaml"
            puppet.manifest_file = "default.pp"
            puppet.options = "--verbose"
         end
      end
   end
end
