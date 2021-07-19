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
    Chef::Log.info('ssh, syslog, cronlog and environment configuration.........')
    resource = @new_resource
    filename = resource.filename
    separator = resource.separator
    parameter = resource.parameter
    value = resource.value
    daemon = resource.daemon
    method = resource.method

    if shell_out("grep '#{parameter}#{separator}#{value}' #{filename} | grep -v '^#'").stdout.empty?
      converge_by("Create #{@new_resource}") do
        Chef::Log.info("save config file #{filename}")
        OsConfiguration.save_config_file(filename)
        FileUtils.cp filename, filename + '.wrk'
        OsConfiguration.change_config_file(filename + '.wrk', separator, parameter, value)
        FileUtils.mv filename + '.wrk', filename, force: true
        FileUtils.rm filename + '.wrk.old', force: true
        # restart daemon
        next if daemon.empty?
        if method == 'srcmstr'
          shell_out("stopsrc -s #{daemon}")
          shell_out("startsrc -s #{daemon}")
        elsif method == 'sighup'
          pid = shell_out("ps -ef|grep #{daemon}|grep -v grep|awk '{print $2}'").stdout.chomp
          shell_out("kill -1 #{pid}")
        elsif method == 'ldap'
          shell_out('restart-secldapclntd')
        end
      end
    else
      Chef::Log.info('nothing to change')
    end
  end
end
