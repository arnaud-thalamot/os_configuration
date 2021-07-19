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

action :install do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')

      fixpath = @new_resource.fixpath.to_s

      #  Creating the Temp file
      directory 'C:/Windows/Temp' do
        action :create
      end

      # Install the .Net framework 3.5
      ruby_block 'install-framework' do
        block do
          Chef::Log.info 'install-framework'
          command = powershell_out('Install-WindowsFeature Net-Framework-Core -LogPath C:/Windows/Logs/dotnet-3.5.log -Source C:/Windows/Temp/sxs')
          Chef::Log.debug command.to_s
          not_if { powershell_out('(Get-WindowsFeature Net-Framework-Core -Verbose:$false).InstallState -ne \'Installed\'').stdout.chop == 'True' }
        end
        action :nothing
      end

      # Extracting the zip containing the framework
      ruby_block 'extracting-archive' do
        block do
          Chef::Log.info 'extracting-archive'
          command = powershell_out "Add-Type -assembly \"system.io.compression.filesystem\"; [io.compression.zipfile]::ExtractToDirectory('C:/Windows/Temp/dotnet_framework_35.zip', 'C:/Windows/Temp')"
          Chef::Log.debug command.to_s
          not_if { File.exist?('C:/Windows/Temp/sxs') }
        end
        action :nothing
        notifies :run, 'ruby_block[install-framework]', :immediately
      end

      # Install the fix to let the framework be installed, instead it cannot be
      ruby_block 'install-fix' do
        block do
          Chef::Log.info 'install-fix'
          command = powershell_out "& #{fixpath}"
          Chef::Log.debug command.to_s
          not_if { powershell_out('Get-Hotfix -id 2966828 -ErrorAction SilentlyContinue').stdout.chop != '' }
        end
        notifies :run, 'ruby_block[extracting-archive]', :immediately
      end
    end
  end
end
