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

action :disable do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')

      # registry key path value for AU
      keypath_au = 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update'
      # registry key name value for AU
      keyname_au = 'AUOptions'
      # registry key data value for AU
      keydata_au = '1'

      Chef::Log.info('Disabling Auto Update....')
      Chef::Log.info("Setting registry key to Disable Windows Auto Update at path: #{keypath_au}")

      # Create a key in registry to disable auto update
      registry_key keypath_au do
        values [{ name: keyname_au, type: :dword, data: keydata_au }]
        action :create
        only_if ::File.exist?(keypath_au)
        not_if { registry_data_exists?(keypath_au, { name: keyname_au, type: :dword, data: keydata_au }, :machine) }
      end
    end
  end
end
