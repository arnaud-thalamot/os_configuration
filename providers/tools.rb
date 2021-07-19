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

action :install do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
    end
    if platform_family?('aix')

      Chef::Log.info('setting TERM and PS1 variables.........')
      #####################
      # modify /etc/profile
      #####################
      ruby_block 'update TERM environment variable' do
        block do
          tempfile = Chef::Util::FileEdit.new('/etc/profile')
          unless tempfile.search_file_replace_line('export TERM.*', 'export TERM=dtterm')
            tempfile.insert_line_if_no_match('export TERM.*', 'export TERM=dtterm')
            tempfile.write_file
          end
        end
        not_if "grep 'export TERM=dtterm' /etc/profile"
      end

      ruby_block 'update PS1 environment variable' do
        block do
          typesrv = shell_out('hostname|sed "s/-//g"').stdout.chomp.slice(3, 2)
          case typesrv
          when 'pr', 'ra'
            shell_out("echo export PS1=\"\\\$(tput setaf 3)'('\\\$(hostname -s)') ['\\\$(whoami)']'' \\\$PWD > '\\\$(tput sgr0)\" >> /etc/profile")
          when 'dv', 'da', 'poc', 'fc'
            shell_out("echo export PS1=\"\\\$(tput setaf 2)'('\\\$(hostname -s)') ['\\\$(whoami)']'' \\\$PWD > '\\\$(tput sgr0)\" >> /etc/profile")
          else
            shell_out("echo export PS1=\"\\\$(tput setaf 1)'('\\\$(hostname -s)') ['\\\$(whoami)']'' \\\$PWD > '\\\$(tput sgr0)\" >> /etc/profile")
          end
        end
        not_if 'grep PS1 /etc/profile'
      end

      ruby_block 'vi setting' do
        block do
          shell_out('echo set -o vi >> /etc/profile')
        end
        not_if "grep 'set -o vi' /etc/profile"
      end

      Chef::Log.info('CCS tools installation.........')
      ########################
      # Install CCS tool files
      ########################
      ccstoolsversion = '1.1.38.0'
      location = '/distribnas/os_configuration'

      execute "cp #{location}/ccs.tools.#{ccstoolsversion}.tar.gz /tmp" do
        not_if "ls /tmp/ccs.tools.#{ccstoolsversion}.tar.gz >/dev/null"
      end

      execute 'install CCS tool files' do
        cwd '/'
        command "gzip -d /tmp/ccs.tools.#{ccstoolsversion}.tar.gz; tar xvf /tmp/ccs.tools.#{ccstoolsversion}.tar"
        not_if { ccstoolsversion == shell_out('cat /tmp/ccs.tools-version').stdout.chomp }
      end

      Chef::Log.info('CCS tools installation.........')
      ########################
      # Modify root crontab
      ########################
      ruby_block 'Modify root crontab' do
        block do
          shell_out('crontab -l > /tmp/crontab.txt')
          shell_out('cat /tmp/crontab.txt >> /tmp/crontab.tmp')
          shell_out("echo '\#{END_LOCAL}' >> /tmp/crontab.tmp")
          shell_out('crontab /tmp/crontab.tmp')
        end
        not_if "crontab -l | grep -q 'Template Crontab'"
      end

      ruby_block 'Update root crontab for SYSTEM' do
        block do
          shell_out('/home/root/sh/manage_cron.sh SYSTEM /tmp/template_cron.system')
        end
        not_if "crontab -l|awk '/BEGIN_SYSTEM/{i=1;next}/END_SYSTEM/{i=0}i'|sed 's/ $//'|diff /tmp/template_cron.system -"
      end

      ruby_block 'Update root crontab for TOOLS_ADM' do
        block do
          shell_out('home/root/sh/manage_cron.sh TOOLS_ADM /tmp/template_cron.tools_adm')
        end
        not_if "crontab -l|awk '/BEGIN_TOOLS_ADM/{i=1;next}/END_TOOLS_ADM/{i=0}i'|sed 's/ $//'|diff /tmp/template_cron.tools_adm -"
      end

      Chef::Log.info('CMA entry in /etc/inittab.........')
      ##########################
      # Add CMA entry in inittab
      ##########################
      cookbook_file '/tmp/inittab_cma' do
        source 'inittab_cma'
      end

      ruby_block 'Add CMA entry in inittab' do
        block do
          shell_out('cp -p /etc/inittab /etc/inittab.old')
          shell_out('cat /tmp/inittab_cma >> /etc/inittab')
        end
        not_if 'grep -q APPLICATIONS /etc/inittab'
      end

      Chef::Log.info('ssh, syslog, cronlog and environment configuration.........')
      ##############
      # Syslog files
      ##############
      files = ['/var/adm/syslog.err', '/var/adm/syslog.debug', '/var/log/auth.log', '/var/log/syslog.out', '/var/log/syslogd.log', '/var/adm/secure']
      files.each do |file|
        file "#{file} creation" do
          path file
          mode '0600'
          owner 'root'
          group 'system'
        end
      end

      Chef::Log.info('padmin user configuration for VIO servers.........')
      ###########################
      # padmin user configuration
      ###########################
      execute 'chuser gecos="MRS/F/*MRSUNX/CCS/vios admin account" padmin' do
        only_if 'grep -q padmin /etc/passwd'
        not_if 'grep padmin /etc/passwd | grep -q "MRS/F/\*MRSUNX/CCS/vios admin account"'
      end

      execute 'chsec -f /etc/security/user -s padmin -a SYSTEM=compat' do
        only_if 'grep -q padmin /etc/passwd'
        not_if 'grep -p padmin /etc/security/user | grep compat | grep -iv ldap > /dev/null'
      end

      execute 'chsec -f /etc/security/user -s padmin -a registry=files' do
        only_if 'grep -q padmin /etc/passwd'
        not_if 'grep -p padmin /etc/security/user | grep -q "registry = files"'
      end

      Chef::Log.info('security logs configuration.........')
      #############################
      # Security logs configuration
      #############################
      dirs = ['/log/security/wtmp', '/log/security/sulog', '/log/security/failedlogin', '/log/security/secure']
      dirs.each do |i|
        directory "#{i} creation" do
          path i
          mode '0700'
          owner 'root'
          group 'system'
          recursive true
        end
      end

      Chef::Log.info('users default limits definition.........')
      ##############################
      # Default ulimit configuration
      ##############################
      limits = %w(fsize core cpu data rss stack nofiles)
      limits.each do |i|
        execute "chsec -f /etc/security/limits -s default -a #{i}=-1" do
          not_if "lssec -f /etc/security/limits -s default -a #{i} | grep -q '\\\-1'"
          not_if 'lsuser padmin > /dev/null 2>&1'
        end
      end

      Chef::Log.info('/etc/exclude.rootvg for mksysb.........')
      #########################
      # exclude list for MKSYSB
      #########################
      cookbook_file '/etc/exclude.rootvg' do
        source 'exclude.rootvg'
        owner 'root'
        group 'system'
        mode '0644'
        action :create_if_missing
      end

      Chef::Log.info('/etc/rc.shutdown creation.........')
      ##################
      # /etc/rc.shutdown
      ##################
      file '/etc/rc.shutdown' do
        owner 'root'
        group 'system'
        mode '0755'
      end

      Chef::Log.info('WLM activation.........')
      ################
      # WLM activation
      ################
      execute 'mkitab "wlm:2:once:/usr/sbin/wlmcntrl -p -T class -T proc > /dev/console 2>&1"' do
        not_if 'lsitab wlm >/dev/null'
      end

      Chef::Log.info('deletion of /etc/hosts.equiv.........')
      #####################
      # host.equiv deletion
      #####################
      file '/etc/hosts.equiv' do
        action :delete
      end

      Chef::Log.info('/etc/motd configuration.........')
      ##########################
      # First run of update MOTD
      ##########################
      execute '/production/home/root/sh/ADM_SYS_edit_motd.ksh' do
        not_if 'grep -q CMA-CGM /etc/motd'
      end

      Chef::Log.info('installation of CMA libs.........')
      ############################
      # install CMA production lib
      ############################
      directory '/production/lib' do
        owner 'root'
        group 'system'
        mode 0755
      end

      cookbook_file '/production/lib/APP_LIB_production.lib' do
        source 'APP_LIB_production.lib'
        owner 'nobody'
        group 'staff'
        mode '0644'
      end

      Chef::Log.info('SNMP configuration.........')
      ############################

      ruby_block 'Modify SNMP conf files' do
        block do
          shell_out('cp -p /etc/snmpdv3.conf /etc/snmpdv3.conf.ori')
          shell_out('cp -p /tmp/snmpdv3.conf /etc/snmpdv3.conf')
          shell_out('cp -p /etc/snmpd.conf /etc/snmpd.conf.ori')
          shell_out('cp -p /tmp/snmpd.conf /etc/snmpd.conf')
          shell_out('stopsrc -s snmpd')
          shell_out('startsrc -s snmpd')
        end
        only_if { shell_out("grep -h -v '^#' /etc/snmpd*.conf|tr [A-Z] [a-z]|awk '$1 ~ /^community/ && $2 ~ /public/'|wc -l").stdout.chomp.to_i != 0 }
      end

    end
    if platform_family?('rhel')

      Chef::Log.info('Installing Complementary tools...........')
      # creating the required directories
      dir_list = ['/production/home', '/production/home/pilotage', '/usr/local/exploit', '/usr/local/nmon', '/root/sh', '/root/sh/nmon']

      # create each directory of dir_list
      dir_list.each do |path|
        directory path do
          owner 'root'
          mode '755'
          recursive true
          action :create
        end
      end

      Chef::Log.info('Downloading pilotage scripts...........')
      # downloading packages
      package_list = ['ADM_SYS_edit_motd_Linux.ksh', 'Check_ntp.ksh', 'Check_Process.ksh']

      package_list.each do |package|
        remote_file '/root/sh/' + package do
          source 'http://10.0.0.1:81/Appl_Linux/root_sh_scripts/' + package
          owner 'root'
          mode '744'
          # recursive true
          action :create_if_missing
        end
      end

      Chef::Log.info('Configuring nslcd...........')
      # setting nslcd.conf file
      template '/etc/nslcd.conf' do
        source 'nslcd.conf.erb'
        owner 'root'
        mode '0644'
        action :create
      end

      # Various commands for configuration
      shell_out('chmod 640 /etc/shadow')
      shell_out('touch /var/log/faillog')
      shell_out('chown root.root /var/log/faillog')
      shell_out('chmod 600 /var/log/faillog')
      shell_out('setfattr -x security.selinux /var/tmp')
      shell_out('setfattr -x security.selinux /tmp')

      Chef::Log.info('Adding ksh for troubleshooting ...........')
      # KSH - Add the line below to permit /usr/bin/ksh as login shell
      execute 'add-ksh' do
        command 'echo "/usr/bin/ksh" >> /etc/shells'
        action :run
        not_if { shell_out('cat /etc/shells | grep /usr/bin/ksh').stdout.chop != '' }
      end

      # security
      Chef::Log.info('Security...................')

      execute 'security-update' do
        command 'sed -i -e \'/^3270\\/tty/d\' -e \'/sclp/d\' -e \'/^hvs/d\' -e \'/^xvc/d\'  /etc/securetty'
        action :run
      end

      Chef::Log.info('Configuring password-auth...................')
      password_auth = '/etc/pam.d/password-auth'

      md5_required = shell_out("sed -i -e '/password    sufficient    pam_unix.so md5/i password    required      pam_unix.so remember=3 use_authtok md5 shadow' #{password_auth}")
      md5_sufficient = shell_out("sed -i -e '/password    sufficient    pam_unix.so md5/i password    sufficient    pam_unix.so remember=3 use_authtok md5 shadow' #{password_auth}")
      sha512_required = shell_out("sed -i -e '/password    sufficient    pam_unix.so sha512/i password    required      pam_unix.so remember=3 use_authtok md5 shadow' #{password_auth}")
      sha512_sufficient = shell_out("sed -i -e '/password    sufficient    pam_unix.so sha512/i password    sufficient    pam_unix.so remember=3 use_authtok md5 shadow' #{password_auth}")
      cracklib = shell_out("sed -i -e '/password    requisite     pam_pwquality.so/i password    required     pam_cracklib.so try_first_pass retry=3 minlen=8' #{password_auth}")

      Chef::Log.debug("md5_required : #{md5_required}")
      Chef::Log.debug("md5_sufficient : #{md5_sufficient}")
      Chef::Log.debug("sha512_required : #{sha512_required}")
      Chef::Log.debug("sha512_sufficient : #{sha512_sufficient}")
      Chef::Log.debug("cracklib : #{cracklib}")

      Chef::Log.info('Configuring system-auth...................')

      system_auth = '/etc/pam.d/system-auth'

      md5_required = shell_out("sed -i -e '/password    sufficient    pam_unix.so md5/i password    required      pam_unix.so remember=3 use_authtok md5 shadow' #{system_auth}")
      md5_sufficient = shell_out("sed -i -e '/password    sufficient    pam_unix.so md5/i password    sufficient    pam_unix.so remember=3 use_authtok md5 shadow' #{system_auth}")
      sha512_required = shell_out("sed -i -e '/password    sufficient    pam_unix.so sha512/i password    required      pam_unix.so remember=3 use_authtok md5 shadow' #{system_auth}")
      sha512_sufficient = shell_out("sed -i -e '/password    sufficient    pam_unix.so sha512/i password    sufficient    pam_unix.so remember=3 use_authtok md5 shadow' #{system_auth}")
      cracklib = shell_out("sed -i -e '/password    requisite     pam_pwquality.so/i password    required     pam_cracklib.so try_first_pass retry=3 minlen=8' #{system_auth}")

      Chef::Log.debug("md5_required : #{md5_required}")
      Chef::Log.debug("md5_sufficient : #{md5_sufficient}")
      Chef::Log.debug("sha512_required : #{sha512_required}")
      Chef::Log.debug("sha512_sufficient : #{sha512_sufficient}")
      Chef::Log.debug("cracklib : #{cracklib}")

      # Update rc.local
      Chef::Log.info('Updating rc.local file .......')
      execute 'update-rc-local' do
        command 'echo "/root/sh/ADM_SYS_edit_motd_Linux.ksh" >> /etc/rc.local'
        action :run
        not_if { shell_out("cat /etc/rc.local | grep '/root/sh/ADM_SYS_edit_motd_Linux.ksh'").stdout.chop != '' }
      end

      # Updating host file
      Chef::Log.info('Updating hosts file .........')
      execute 'update-hosts' do
        command "echo -e \"127.0.0.1\tlocalhost.localdomain\tlocalhost\" > /etc/hosts; echo -e \"#{node['ipaddress']}\t#{node['hostname']}.cma-cgm.com\t#{node['hostname']}\" >> /etc/hosts"
        action :run
        not_if { shell_out('sed -n 2p /etc/hosts | cut -f2').stdout.chop == "#{node['hostname']}.cma-cgm.com" }
      end

      Chef::Log.info('Configuring shell color ...................')
      execute 'shell-color' do
        command 'cat >>/etc/profile <<"EOF"
        export TERM=vt100

        # Color Shell
        export RED="\\\\033[1;31m"
        export NORMAL="\\\\033[0;39m"
        export YELLOW="\\\\033[1;33m"
        export GREEN="\\\\033[1;32m"

        $(hostname | egrep -qi "\-ix\-|\-lx\-|mrspl") && export PS1=\'$(echo -en "${RED}(`hostname`) [`whoami`] `pwd` > ${NORMAL}")\'
        $(hostname | egrep -qi "\-px\-|mrsrl") && export PS1=\'$(echo -en "${YELLOW}(`hostname`) [`whoami`] `pwd` > ${NORMAL}")\'
        $(hostname | egrep -qi "\-dx\-|mrsdl|poc") && export PS1=\'$(echo -en "${GREEN}(`hostname`) [`whoami`] `pwd` > ${NORMAL}")\''
        action :run
        not_if { shell_out('cat /etc/profile | grep "Color Shell"').stdout.chop != '' }
      end

      profile = '/etc/profile'

      execute 'add-cyan' do
        command "sed -i \"/HISTSIZE=1000/a\\CYAN=\\$(echo -e '\\\\\\e[0;36m')\" #{profile}"
        action :run
        not_if { shell_out("cat #{profile} | grep CYAN=").stdout.chop != '' }
      end

      execute 'add-normal' do
        command "sed -i \"/HISTSIZE=1000/a\\NORMAL=\\$(echo -e '\\\\\\e[0m')\" #{profile}"
        action :run
        not_if { shell_out("cat #{profile} | grep NORMAL=").stdout.chop != '' }
      end

      execute 'add-timeformat' do
        command "sed -i '/HISTSIZE=1000/a\\HISTTIMEFORMAT=\"${CYAN}[ %d/%m/%Y %H:%M:%S ]${NORMAL} \"' #{profile}"
        action :run
        not_if { shell_out("cat #{profile} | grep HISTTIMEFORMAT=").stdout.chop != '' }
      end

      export_path = shell_out("sed -i '/export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE INPUTRC/c\\export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE INPUTRC HISTTIMEFORMAT' #{profile}")
      Chef::Log.debug("export_path : #{export_path}")

      # Create authorized_keys
      cookbook_file '/etc/profile.d/ibm-sas.sh' do
        source 'ibm-sas.sh'
        action :create
      end
    end
  end
end
