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
  converge_by("Create #{@new_resource}") do
    if platform_family?('aix')
      Chef::Log.info('Configuring /etc/rc.tcpip.............')

      FileUtils.cp '/etc/rc.tcpip', '/etc/rc.tcpip.wrk'
      ruby_block 'save the current /etc/rc.tcpip' do
        block do
          OsConfiguration.save_config_file('/etc/rc.tcpip')
          FileUtils.mv '/etc/rc.tcpip' + '.wrk', '/etc/rc.tcpip', force: true
          FileUtils.rm '/etc/rc.tcpip' + '.wrk.old', force: true
        end
        action :nothing
      end

      ruby_block 'update /etc/rc.tcpip for NTP start' do
        block do
          tempfile = Chef::Util::FileEdit.new('/etc/rc.tcpip.wrk')
          line = shell_out("grep xntpd /etc/rc.tcpip.wrk|sed 's/^#//'").stdout.chomp
          tempfile.search_file_replace_line('^#start /usr/sbin/xntpd.*', line)
          tempfile.write_file
        end
        not_if "grep -q '^start /usr/sbin/xntpd' /etc/rc.tcpip.wrk"
      end

      replaces = ['/usr/sbin/hostmibd', '/usr/sbin/snmpmibd', '/usr/sbin/aixmibd']
      replaces.each do |i|
        ruby_block "SNMP: update #{i} start in /etc/rc.tcpip" do
          block do
            tempfile = Chef::Util::FileEdit.new('/etc/rc.tcpip.wrk')
            tempfile.search_file_replace_line("start #{i}.*", "start #{i} \"$src_running\" \"-c AiXMiBD\"")
            tempfile.write_file
          end
          not_if "grep '#{i}' /etc/rc.tcpip.wrk | grep -v '^#' | grep -q 'AiXMiBD'"
        end
      end

      ruby_block 'notify save /etc/rc.tcpip' do
        block do
        end
        notifies :run, 'ruby_block[save the current /etc/rc.tcpip]', :immediately
        only_if { ::File.exist?('/etc/rc.tcpip.wrk.old') }
      end
    end
  end
end
