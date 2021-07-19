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

action :create do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
    end
    if platform_family?('aix')
      Chef::Log.info('Configuring NAS .............')

      resource = @new_resource

      cmd = "crfs -v nfs -n #{resource.nashost}"
      cmd += " -d #{resource.nasvolume}"
      cmd += " -m #{resource.naspath} -A yes"
      cmd += " -a options='bg,soft,intr,rsize=32768,wsize=32768,timeo=600,sec=sys'"

      execute "creation of #{resource.naspath}" do
        command cmd
        not_if "lsfs #{resource.naspath} > /dev/null"
      end

      execute "mount #{resource.naspath}" do
        not_if "mount | grep -q #{resource.naspath}"
      end
    end
    if platform_family?('rhel')

      Chef::Log.info('Configuring NAS #{@new_resource.naspath}.....')
      resource = @new_resource

      # Create the directory to mount the share
      directory "Creating directory #{@new_resource.naspath}" do
        path resource.naspath
        action :create
        recursive true
        not_if { ::File.directory?(resource.naspath) }
      end

      # Add the record to fstab if it does not already exists
      execute "add to fstab #{resource.naspath}" do
        command "echo \"#{resource.nashost}:#{resource.nasvolume}     #{resource.naspath}              nfs     defaults        0 0\" >> /etc/fstab"
        action :run
        not_if { shell_out("cat /etc/fstab |grep #{resource.nashost}:#{resource.nasvolume}").stdout.chop != '' }
      end
    end
  end
end
