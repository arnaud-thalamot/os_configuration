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

action :apply do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
    else

      Chef::Log.info('Updating /etc/login.defs ..................')

      resource = @new_resource
      login_defs = '/etc/login.defs'

      # Modifies login_defs parameters with given values
      ruby_block "Update the file #{login_defs}" do
        block do
          sed = Chef::Util::FileEdit.new(login_defs)
          sed.search_file_replace_line('^PASS_MAX_DAYS', "PASS_MAX_DAYS    #{resource.PASS_MAX_DAYS}")
          sed.search_file_replace_line('^PASS_MIN_LEN', "PASS_MIN_LEN    #{resource.PASS_MIN_LEN}")
          sed.search_file_replace_line('^UID_MIN', "UID_MIN      #{resource.UID_MIN}")
          sed.search_file_replace_line('^GID_MIN', "GID_MIN      #{resource.GID_MIN}")
          sed.write_file
        end
      end
    end
  end
end
