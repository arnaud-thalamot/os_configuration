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

action :disableIPv6 do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')

      # registry key path value for IPV6
      keypath_ipv6 = 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\TCPIP6\\Parameters'
      # registry key name value for IPV6
      keyname_ipv6 = 'DisabledComponents'
      # registry key data value for IPV6
      keydata_ipv6 = 0xff

      Chef::Log.debug("Setting registry key to Disable IPV6 at path: #{keypath_ipv6}")
      Chef::Log.info('Disablings IPV6....')

      # Create a key in registry to disable ipv6
      registry_key keypath_ipv6 do
        values [{ name: keyname_ipv6, type: :dword, data: keydata_ipv6 }]
        action :create
      end
    end
  end
end
