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

action :enable do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')

      # registry key path value for RDP
      keypath_rdp = 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server'
      # registry key name value for RDP
      keyname_rdp = 'fDenyTSConnections'
      # registry key data value
      keydata = '0'

      registry_key keypath_rdp do
        Chef::Log.info('Enabling RDP....')
        values [{ name: keyname_rdp, type: :dword, data: keydata }]
        action :create
        only_if ::File.exist?(keyname_rdp)
        not_if { registry_data_exists?(keypath_rdp, { name: keyname_rdp, type: :dword, data: keydata }, :machine) }
      end
    end
  end
end
