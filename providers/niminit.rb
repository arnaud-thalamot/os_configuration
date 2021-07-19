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

use_inline_resources

action :configure do
  if platform_family?('aix')
    resource = @new_resource
    nimserver = resource.nimserver
    nimclient = resource.nimclient
    adapter = resource.adapter
    protocol = resource.protocol
    force = resource.force

    Chef::Log.info('nim client fileset configuration.........')
    cmd = "niminit -a name=#{nimclient} -a master=#{nimserver} -a pif_name=#{adapter} -a connect=#{protocol}"
    niminit = ::Mixlib::ShellOut.new(cmd)
    if ::File.exist?('/etc/niminfo') && force == false
      Chef::Log.info('nothing to change')
    else
      converge_by("Create #{@new_resource}") do
        if ::File.exist?('/etc/niminfo')
          FileUtils.mv '/etc/niminfo', '/etc/niminfo.ori', force: true
        end
        niminit.run_command
        if niminit.error?
          Chef::Log.error('the command ' + cmd + ' failed')
          Chef::Log.error("\n" + niminit.stderr)
          raise
        end
      end
    end
  end
end
