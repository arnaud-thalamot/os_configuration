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
    else
      set_resolve_conf = "search cma-cgm.com\nnameserver #{@new_resource.nameserver1}\nnameserver #{@new_resource.nameserver2}"
      resolve_conf = '/etc/resolv.conf'

      Chef::Log.info('Setting resolv configuration...')
      execute 'write-resolv-conf' do
        command "echo \"#{set_resolve_conf}\" > #{resolve_conf}"
        action :run
      end
    end
  end
end
