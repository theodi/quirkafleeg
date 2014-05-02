# -*- mode: ruby -*-
# vi: set ft=ruby :

require "yaml"
y = YAML.load File.open ".chef/rackspace_secrets.yaml"

mongo_nodes         = 1
frontend_nodes      = 3
backend_nodes       = 3
dapaas_nodes        = 1
elasticsearch_nodes = 1
rummager_nodes      = 1

Vagrant.configure("2") do |config|

  config.butcher.knife_config_file = '.chef/knife.rb'

  mongo_nodes.times do |num|
    index = "%02d" % [
        num + 1
    ]

    config.vm.define :"mongo_quirkafleeg_#{index}" do |config|
      config.vm.box      = "dummy"
      config.vm.hostname = "mongo-quirkafleeg-#{index}"

      config.ssh.private_key_path = "./.chef/id_rsa"
      config.ssh.username         = "root"

      config.vm.synced_folder 'foo/', '/vagrant'

      config.vm.provider :rackspace do |rs|
        rs.username        = y["username"]
        rs.api_key         = y["api_key"]
        rs.flavor          = /1GB/
        rs.image           = /Precise/
        rs.public_key_path = "./.chef/id_rsa.pub"
        rs.rackspace_region = :lon
      end

      config.vm.provision :shell, :inline => "curl -L https://www.opscode.com/chef/install.sh | bash"

      config.vm.provision :chef_client do |chef|
        chef.node_name              = "mongo-quirkafleeg-#{index}"
        chef.environment            = "quirkafleeg-preduction"
        chef.chef_server_url        = "https://chef.theodi.org"
        chef.validation_client_name = "chef-validator"
        chef.validation_key_path    = ".chef/chef-validator.pem"
        chef.run_list               = chef.run_list = [
            "role[chef-client]",
            "role[mongodb]"
        ]
      end
    end
  end

#  config.vm.define :mysql_quirkafleeg do |config|
#    config.vm.box      = "dummy"
#    config.vm.hostname = "mysql-quirkafleeg"
#
#    config.ssh.private_key_path = "./.chef/id_rsa"
#    config.ssh.username         = "root"
#
#    config.vm.synced_folder 'foo/', '/vagrant'
#
#    config.vm.provider :rackspace do |rs|
#      rs.username        = y["username"]
#      rs.api_key         = y["api_key"]
#      rs.flavor          = /1GB/
#      rs.image           = /Precise/
#      rs.public_key_path = "./.chef/id_rsa.pub"
#      rs.rackspace_region = :lon
#    end
#
#    config.vm.provision :shell, :inline => "curl -L https://www.opscode.com/chef/install.sh | bash"
#
#    config.vm.provision :chef_client do |chef|
#      chef.node_name              = "mysql-quirkafleeg"
#      chef.environment            = "quirkafleeg-preduction"
#      chef.chef_server_url        = "https://chef.theodi.org"
#      chef.validation_client_name = "chef-validator"
#      chef.validation_key_path    = ".chef/chef-validator.pem"
#      chef.run_list               = chef.run_list = [
#          "role[quirkafleeg]",
#          "role[chef-client]",
#          "role[mysql]"
#      ]
#    end
#  end

  rummager_nodes.times do |num|
    index = "%02d" % [
        num + 1
    ]

    config.vm.define :"rummager_quirkafleeg_#{index}" do |config|
      config.vm.box      = "dummy"
      config.vm.hostname = "rummager-quirkafleeg-#{index}"

      config.ssh.private_key_path = "./.chef/id_rsa"
      config.ssh.username         = "root"

      config.vm.provider :rackspace do |rs|
        rs.username        = y["username"]
        rs.api_key         = y["api_key"]
        rs.flavor          = /1GB/
        rs.image           = /Trusty/
        rs.public_key_path = "./.chef/id_rsa.pub"
        rs.rackspace_region = :lon
      end
    end

    config.vm.provision :shell, :inline => "wget https://opscode.com/chef/install.sh && bash install.sh"

    config.vm.provision :chef_client do |chef|
      chef.node_name              = "rummager-quirkafleeg-#{index}"
      chef.environment            = "quirkafleeg-preduction"
      chef.chef_server_url        = "https://chef.theodi.org"
      chef.validation_client_name = "chef-validator"
      chef.validation_key_path    = ".chef/chef-validator.pem"
      chef.run_list               = chef.run_list = [
          "role[base]",
          "role[chef-client]",
          "recipe[odi-rummager-node]",
      ]
    end

  end

  elasticsearch_nodes.times do |num|
    index = "%02d" % [
        num + 1
    ]

    config.vm.define :"elasticsearch_quirkafleeg_#{index}" do |config|
      config.vm.box      = "dummy"
      config.vm.hostname = "elasticsearch-quirkafleeg-#{index}"

      config.ssh.private_key_path = "./.chef/id_rsa"
      config.ssh.username         = "root"

      config.vm.provider :rackspace do |rs|
        rs.username        = y["username"]
        rs.api_key         = y["api_key"]
        rs.flavor          = /1GB/
        rs.image           = /Trusty/
        rs.public_key_path = "./.chef/id_rsa.pub"
        rs.rackspace_region = :lon
      end

      config.vm.provision :shell, :inline => "wget https://opscode.com/chef/install.sh && bash install.sh"

      config.vm.provision :chef_client do |chef|
        chef.node_name              = "elasticsearch-quirkafleeg-#{index}"
        chef.environment            = "quirkafleeg-preduction"
        chef.chef_server_url        = "https://chef.theodi.org"
        chef.validation_client_name = "chef-validator"
        chef.validation_key_path    = ".chef/chef-validator.pem"
        chef.run_list               = chef.run_list = [
            "role[base]",
            "role[chef-client]",
            "recipe[odi-elasticsearch-node]",
        ]
      end
    end
  end

  frontend_nodes.times do |num|
    index = "%02d" % [
        num + 1
    ]

    config.vm.define :"frontend_quirkafleeg_#{index}" do |config|
      config.vm.box      = "dummy"
      config.vm.hostname = "frontend-quirkafleeg-#{index}"

      config.ssh.private_key_path = "./.chef/id_rsa"
      config.ssh.username         = "root"

      config.vm.synced_folder 'foo/', '/vagrant'

      config.vm.provider :rackspace do |rs|
        rs.username        = y["username"]
        rs.api_key         = y["api_key"]
        rs.flavor          = /4GB/
        rs.image           = /Precise/
        rs.public_key_path = "./.chef/id_rsa.pub"
        rs.rackspace_region = :lon
      end

      config.vm.provision :shell, :inline => "curl -L https://www.opscode.com/chef/install.sh | bash"

      config.vm.provision :chef_client do |chef|
        chef.node_name              = "frontend-quirkafleeg-#{index}"
        chef.environment            = "quirkafleeg-preduction"
        chef.chef_server_url        = "https://chef.theodi.org"
        chef.validation_client_name = "chef-validator"
        chef.validation_key_path    = ".chef/chef-validator.pem"
        chef.run_list               = chef.run_list = [
            "role[quirkafleeg-frontend]",
            "role[chef-client]",
            "role[quirkafleeg-webnode]"
        ]
      end
    end
  end

  backend_nodes.times do |num|
    index = "%02d" % [
        num + 1
    ]

    config.vm.define :"backend_quirkafleeg_#{index}" do |config|
      config.vm.box      = "dummy"
      config.vm.hostname = "backend-quirkafleeg-#{index}"

      config.ssh.private_key_path = "./.chef/id_rsa"
      config.ssh.username         = "root"

      config.vm.synced_folder 'foo/', '/vagrant'

      config.vm.provider :rackspace do |rs|
        rs.username        = y["username"]
        rs.api_key         = y["api_key"]
        rs.flavor          = /4GB/
        rs.image           = /Precise/
        rs.public_key_path = "./.chef/id_rsa.pub"
        rs.rackspace_region = :lon
      end

      config.vm.provision :shell, :inline => "curl -L https://www.opscode.com/chef/install.sh | bash"

      config.vm.provision :chef_client do |chef|
        chef.node_name              = "backend-quirkafleeg-#{index}"
        chef.environment            = "quirkafleeg-preduction"
        chef.chef_server_url        = "https://chef.theodi.org"
        chef.validation_client_name = "chef-validator"
        chef.validation_key_path    = ".chef/chef-validator.pem"
        chef.run_list               = chef.run_list = [
            "role[quirkafleeg-backend]",
            "role[chef-client]",
            "role[quirkafleeg-webnode]"
        ]
      end
    end
  end

  dapaas_nodes.times do |num|
    index = "%02d" % [
        num + 1
    ]

    config.vm.define :"dapaas_quirkafleeg_#{index}" do |config|
      config.vm.box      = "dummy"
      config.vm.hostname = "dapaas-quirkafleeg-#{index}"

      config.ssh.private_key_path = "./.chef/id_rsa"
      config.ssh.username         = "root"

      config.vm.synced_folder 'foo/', '/vagrant'

      config.vm.provider :rackspace do |rs|
        rs.username        = y["username"]
        rs.api_key         = y["api_key"]
        rs.flavor          = /4GB/
        rs.image           = /Precise/
        rs.public_key_path = "./.chef/id_rsa.pub"
        rs.auth_url        = "https://lon.identity.api.rackspacecloud.com/v2.0"
      end

      config.vm.provision :shell, :inline => "curl -L https://www.opscode.com/chef/install.sh | bash"

      config.vm.provision :chef_client do |chef|
        chef.node_name              = "dapaas-quirkafleeg-#{index}"
        chef.environment            = "quirkafleeg-preduction"
        chef.chef_server_url        = "https://chef.theodi.org"
        chef.validation_client_name = "chef-validator"
        chef.validation_key_path    = ".chef/chef-validator.pem"
        chef.run_list               = chef.run_list = [
            "role[dapaas-frontend]",
            "role[chef-client]",
            "role[quirkafleeg-webnode]"
        ]
      end
    end
  end
end
