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
      Chef::Log.info('Configuring NTP .............')
      cookbook_file '/etc/ntp.conf' do
        source 'ntp.conf'
        owner 'root'
        group 'system'
        mode '0664'
      end
    end
    if platform_family?('rhel')

      resource = @new_resource
      ntp_conf = '/etc/ntp.conf'
      comment_servers = 'sed -i -e \'s/^\\(server\\)/#\\1/\''
      ntp_local_server = "#Local NTP Servers \nserver #{resource.ntp1} \nserver #{resource.ntp2}"

      Chef::Log.info('Configuring NTP .............')
      Chef::Log.info('Updating /etc/ntp.conf file.....')

      execute 'comment-servers' do
        command "#{comment_servers} #{ntp_conf}"
        action :run
        not_if { shell_out("cat #{ntp_conf} | grep \"#{ntp_local_server}\"").stdout.chop != '' }
      end

      execute 'add-servers' do
        command "echo \"#{ntp_local_server}\" >> #{ntp_conf}"
        action :run
        not_if { shell_out("cat #{ntp_conf} | grep \"#{ntp_local_server}\"").stdout.chop != '' }
      end

      Chef::Log.info('Disabling the ntpd service ....')
      service 'ntpd' do
        action :disable
      end

      Chef::Log.info('Applying Chrony settings.......')
      chrony_conf = '/etc/chrony.conf'

      execute 'comment-servers-chrony' do
        command "#{comment_servers} #{chrony_conf}"
        action :run
        not_if { shell_out("cat #{chrony_conf} | grep \"server #{resource.ntp1} iburst\"").stdout.chop != '' }
      end

      execute 'add-servers-chrony' do
        command "sed -i.old -e '/0.rhel.pool/i server #{resource.ntp1} iburst' -e '/0.rhel.pool/i server #{resource.ntp2} iburst' /etc/chrony.conf "
        action :run
        not_if { shell_out("cat #{chrony_conf} | grep \"server #{resource.ntp1} iburst\"").stdout.chop != '' }
      end

      Chef::Log.info('Setting the time zone to UTC .......')
      execute 'set-timezone' do
        command 'timedatectl set-timezone UTC'
        action :run
        not_if { shell_out('date | grep UTC').stdout.chop != '' }
      end

      Chef::Log.info('Enabling the chrony.service........')
      service 'chronyd.service' do
        action [:enable, :start]
      end
    end
  end
end
