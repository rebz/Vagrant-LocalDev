class LocalDev
  def self.configure(config, settings)
    # Set The VM Provider
    ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

    # Configure Local Variable To Access Scripts From Remote Location
    script_dir = File.dirname(__FILE__)

    # Allow SSH Agent Forward from The Box
    config.ssh.forward_agent = true

    # Configure Verify Host Key
    if settings.has_key?('verify_host_key')
      config.ssh.verify_host_key = settings['verify_host_key']
    end

    # Configure The Box
    config.vm.define settings['name'] ||= 'localDev'
    config.vm.box = settings['box'] ||= 'ubuntu/bionic64'
    config.vm.hostname = 'localDev'

    # Configure A Private Network IP
    if settings['ip'] != 'autonetwork'
      config.vm.network :private_network, ip: settings['ip'] ||= '192.168.10.10'
    else
      config.vm.network :private_network, ip: '0.0.0.0', auto_network: true
    end

    # Configure A Few VirtualBox Settings
    config.vm.provider 'virtualbox' do |vb|

      vb.customize [
        "storagectl", :id,
        "--name", "SCSI",
        "--hostiocache", "on"
      ]

      vb.name = settings['name'] ||= 'localDev'
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ['modifyvm', :id, '--memory', settings['memory'] ||= '2048']
      vb.customize ['modifyvm', :id, '--cpus', settings['cpus'] ||= '2']
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', settings['natdnshostresolver'] ||= 'on']
      vb.customize ['modifyvm', :id, '--ostype', 'Ubuntu_64']
      if settings.has_key?('gui') && settings['gui']
        vb.gui = true
      end
    end

    # Standardize Ports Naming Schema
    if settings.has_key?('ports')
      settings['ports'].each do |port|
        port['guest'] ||= port['to']
        port['host'] ||= port['send']
        port['protocol'] ||= 'tcp'
      end
    else
      settings['ports'] = []
    end

    # Add Custom Ports From Configuration
    if settings.has_key?('ports')
      settings['ports'].each do |port|
        config.vm.network 'forwarded_port', guest: port['guest'], host: port['host'], protocol: port['protocol'], auto_correct: true
      end
    end

    # Configure The Public Key For SSH Access
    if settings.include? 'authorize'
      if File.exist? File.expand_path(settings['authorize'])
        config.vm.provision 'shell' do |s|
          s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo \"\n$1\" | tee -a /home/vagrant/.ssh/authorized_keys"
          s.args = [File.read(File.expand_path(settings['authorize']))]
        end
      end
    end

    # Copy The SSH Private Keys To The Box
    if settings.include? 'keys'
      if settings['keys'].to_s.length.zero?
        puts 'Check your LocalDev.yaml file, you have no private key(s) specified.'
        exit
      end
      settings['keys'].each do |key|
        if File.exist? File.expand_path(key)
          config.vm.provision 'shell' do |s|
            s.privileged = false
            s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
            s.args = [File.read(File.expand_path(key)), key.split('/').last]
          end
        else
          puts 'Check your LocalDev.yaml (or LocalDev.json) file, the path to your private key does not exist.'
          exit
        end
      end
    end

    # Register All Of The Configured Shared Folders
    if settings.include? 'folders'
      settings['folders'].each do |folder|
        if File.exist? File.expand_path(folder['map'])
          mount_opts = []

          if folder['type'] == 'nfs'
            mount_opts = folder['mount_options'] ? folder['mount_options'] :  ['actimeo=0', 'nolock']


          elsif folder['type'] == 'smb'
            mount_opts = folder['mount_options'] ? folder['mount_options'] : ['vers=3.02', 'mfsymlinks']

            smb_creds = {smb_host: folder['smb_host'], smb_username: folder['smb_username'], smb_password: folder['smb_password']}
          end

          # For b/w compatibility keep separate 'mount_opts', but merge with options
          options = (folder['options'] || {}).merge({ mount_options: mount_opts }).merge(smb_creds || {})

          # Double-splat (**) operator only works with symbol keys, so convert
          options.keys.each{|k| options[k.to_sym] = options.delete(k) }

          config.vm.synced_folder folder['map'], folder['to'], type: folder['type'] ||= nil, **options
        else
          config.vm.provision 'shell' do |s|
            s.inline = ">&2 echo \"Unable to mount one of your folders. Please check your folders in LocalDev.yaml\""
          end
        end
      end
    end

    # Clear any LocalDev sites and insert markers in /etc/hosts
    config.vm.provision 'shell' do |s|
      s.path = script_dir + '/hosts-reset.sh'
    end

    config.vm.provision 'shell' do |s|
      s.name = 'Update motd'
      s.inline = 'sudo service motd-news restart'
    end
  end
end