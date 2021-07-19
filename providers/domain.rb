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

action :join do
  converge_by("Create #{@new_resource}") do
    if (platform_family?('windows') and !node['os_configuration']['domain_added'])
      resource = @new_resource

      Chef::Log.info('Joining domain...')

      # Setting the DNS Integration
      # TODO: This should be done only when the Chef environment is CMA Integration
      dns = powershell_out("Set-DnsClientServerAddress -InterfaceIndex 12 -ServerAddresses ('10.0.0.1','10.0.0.2')").stdout
      Chef::Log.debug('dns : ' + dns)

      # Joining a domain, putting the machine in the OU, with given login/password
      join = powershell_out("Add-computer -DomainName '#{resource.domain}' -OUPath '#{resource.ou}' -Credential (New-Object System.Management.Automation.PSCredential('#{resource.username}@#{resource.domain}', (ConvertTo-SecureString #{resource.password} -asPlainText -Force))) -Force -PassThru").stdout
      Chef::Log.debug('join : ' + join)

      # Update computer settings values
      gpupdate = powershell_out('gpupdate /force').stdout
      Chef::Log.debug('gpupdate : ' + gpupdate)
      node.set['os_configuration']['domain_added'] = true
    end
  end
end

action :unjoin do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
      resource = @new_resource

      Chef::Log.info('Unjoining domain...')

      # Joining a domain, putting the machine in the OU, with given login/password
      unjoin = powershell_out("Remove-Computer -UnjoinDomaincredential (New-Object System.Management.Automation.PSCredential('#{resource.username}@#{resource.domain}', (ConvertTo-SecureString #{resource.password} -asPlainText -Force))) -PassThru -Verbose -Force").stdout
      Chef::Log.debug('unjoin : ' + unjoin)
    end
  end
end
