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

      Chef::Log.info('Adding Windows feature for SNMP service')
      cmd = powershell_out('Add-WindowsFeature -Name SNMP-Service -IncludeAllSubFeature').stdout
      Chef::Log.debug('cmd : ' + cmd)
    end
  end
end
