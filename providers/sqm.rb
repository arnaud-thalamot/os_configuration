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

      # registry key path value for SQM
      keypath_sqm = 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\SQMClient\\Windows'
      # registry key name value for SQM
      keyname_sqm = 'CEIPEnable'
      # registry key data value
      keydata = '0'

      Chef::Log.info('Disabling SQM....')
      Chef::Log.info("Setting registry key for SQM at path: #{keypath_sqm}")

      registry_key keypath_sqm do
        values [{ name: keyname_sqm,
                  type: :dword,
                  data: keydata }]
        action :create
        only_if { registry_key_exists?(keypath_sqm) }
        not_if { registry_data_exists?(keypath_sqm, { name: keyname_sqm, type: :dword, data: keydata }, :machine) }
      end
    end
  end
end
