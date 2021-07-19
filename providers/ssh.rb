########################################################################################################################
#                                                                                                                      #
#                                  Attributes for osconfiguration Cookbook                                     #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 09/08/2016                                                                                   #
#   Date Last Update    : 09/09/2016                                                                                   #
#   Version             : 1.0                                                                                          #
#   Author              : Arnaud Thalamot                                                                              #
#                                                                                                                      #
########################################################################################################################

require 'chef/resource'

use_inline_resources

def whyrun_supported?
  true
end

action :configure do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')

      # Download link framework 3.5
      urlopenssh = 'https://pulp.cma-cgm.com/ibm/windows2012R2/osconfig/OpenSSH-Win64.zip'
      # Path of framework 3.5
      pathopenssh = 'C:/Windows/Temp/OpenSSH-Win64.zip'

      Chef::Log.info('Downloading OpenSSH ..................')
      # Download dotnet framework 3.5
      ruby_block 'download-openssh' do
        block do
          Chef::Log.info 'download-openssh'
          command = powershell_out("curl -OutFile #{pathopenssh} #{urlopenssh}")
          Chef::Log.debug command
        end
        action :run
        not_if { ::File.exist?(pathopenssh.to_s) }
      end

      Chef::Log.info('Extracting OpenSSH ..................')
      # Extracts the archive
      ruby_block 'extracting-archive' do
        block do
          Chef::Log.info 'extracting-archive'
          command = powershell_out("Add-Type -assembly \"system.io.compression.filesystem\"; [io.compression.zipfile]::ExtractToDirectory('#{pathopenssh}', 'C:/Program Files') | Out-Null")
          Chef::Log.debug command
        end
        action :run
      end

      Chef::Log.info('Installing OpenSSH ..................')
      # Install OpenSSH
      powershell_script 'install-openssh' do
        code <<-EOH
        cd 'C:/Program Files/OpenSSH-Win64/'
        ./install-sshd.ps1
        EOH
      end

      Chef::Log.info('Generating server keys ..................')
      # Generate a set of keys for the server
      powershell_script 'generate-keys' do
        code <<-EOH
        cd 'C:/Program Files/OpenSSH-Win64/'
        ./ssh-keygen.exe -A
        ./FixHostFilePermissions.ps1 -Confirm:$false
        EOH
      end

      Chef::Log.info('Configuring path ..................')
      # Configure the path to include openssh
      powershell_script 'generate-keys' do
        code <<-EOH
        $env:Path='$env:Path;C:\\Program Files\\OpenSSH-Win64'
        EOH
      end

      Chef::Log.info('Changing service sshd rights ..................')
      # Change sshd service rights to be able to start it
      powershell_script 'ssh-service-rights' do
        code <<-EOH
        $service = gwmi win32_service -filter "name='sshd'"
        $service.change($null,$null,$null,$null,$null,$null,"LocalSystem","")
        EOH
      end

      # SSHD configuration file
      Chef::Log.info('Configuring SSH configuration file..................')
      template 'C:\\Program Files\\OpenSSH-Win64\\sshd_config' do
        source 'sshd_config.erb'
        mode '0600'
        action :create
      end

      Chef::Log.info('Configuring ssh-agent ..................')
      # Start ssh-agent service
      windows_service 'ssh-agent' do
        action :configure_startup
        startup_type :automatic
      end

      Chef::Log.info('Configuring sshd agent ..................')
      # Start sshd service
      windows_service 'sshd' do
        action :configure_startup
        startup_type :automatic
      end

    else
      Chef::Log.info('Configuring SSH server settings ..................')
      sshd_config = '/etc/ssh/sshd_config'
      resource = @new_resource

      # Set ssh configuration parameters to the given values
      hostkey = shell_out("sed -i -e 's/^\\(HostKey\\)/#\\1/' #{sshd_config}")
      loglevel1 = shell_out("sed -i -e 's/^LogLevel.*/LogLevel #{resource.loglevel}/' #{sshd_config}")
      loglevel2 = shell_out("sed -i -e 's/^#LogLevel.*/LogLevel #{resource.loglevel}/' #{sshd_config}")
      maxauthtries = shell_out("sed -i -e 's/.MaxAuthTries.*/MaxAuthTries #{resource.maxauthtries}/' #{sshd_config}")
      rootlogin1 = shell_out("sed -i -e 's/^PermitRootLogin.*/PermitRootLogin #{resource.permitrootlogin}/' #{sshd_config}")
      rootlogin2 = shell_out("sed -i -e 's/^#PermitRootLogin.*/PermitRootLogin #{resource.permitrootlogin}/' #{sshd_config}")
      acceptenv = shell_out("sed -i -e 's/^\\(AcceptEnv\\)/#\\1/' /etc/ssh/sshd_config")

      Chef::Log.debug("hostkey : #{hostkey}")
      Chef::Log.debug("loglevel1 : #{loglevel1}")
      Chef::Log.debug("loglevel2 : #{loglevel2}")
      Chef::Log.debug("maxauthtries : #{maxauthtries}")
      Chef::Log.debug("rootlogin1 : #{rootlogin1}")
      Chef::Log.debug("rootlogin2 : #{rootlogin2}")
      Chef::Log.debug("acceptenv : #{acceptenv}")
    end
  end
end
