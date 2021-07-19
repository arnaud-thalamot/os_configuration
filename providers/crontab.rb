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
    end
    if platform_family?('aix')
      Chef::Log.info('Applying Crontab settings .........')
      # Create the cron file for root
      template '/tmp/crontab.tmp' do
        source 'root_aix.erb'
        owner 'root'
        group 'cron'
        mode 0600
        action :create
      end
    end
    if platform_family?('rhel')
      Chef::Log.info('Applying Crontab settings .........')

      # Create the cron file for root
      template '/var/spool/cron/root' do
        source 'root.erb'
        owner 'root'
        action :create
      end

      # Import the gpg key
      execute 'Import_Key' do
        command 'rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release'
      end
    end
  end
end
