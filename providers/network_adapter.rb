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

action :rename do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')

      # Renaming the Network Adapter name
      Chef::Log.info('Renaming the Network Adapter name....')
      netadapter = powershell_out("Get-NetAdapter -Name Ether* | Rename-NetAdapter -NewName 'Local Area Network' –PassThru").stdout
      Chef::Log.debug('netadapter : ' + netadapter)
    end
  end
end
