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
    end
    if platform_family?('aix')

      sslkeypath = @new_resource.sslkeypath
      sslkeypwd = @new_resource.sslkeypwd
      servers = @new_resource.servers
      basedn = @new_resource.basedn
      binddn = @new_resource.binddn
      pwd = @new_resource.pwd
      port = @new_resource.port
      heartbeatinterval = @new_resource.heartbeatinterval
      cachetimeout = @new_resource.cachetimeout
      certdir = @new_resource.certdir
      certificates = @new_resource.certificates

      Chef::Log.info('automount creation.........')
      ####################
      # automount creation
      ####################

      directory '/home/ldapccs' do
        mode '0755'
        user 'root'
      end

      typesrv = shell_out('hostname|sed "s/-//g"').stdout.chomp.slice(3, 2)
      case typesrv
      when 'pr', 'ra', 'dv', 'da', 'poc', 'fc'
        env = 'dev'
      else
        env = 'prd'
      end
      line = '/home/ldapccs   -intr,bg,soft   ldap_home-'
      line += env
      line += '-nfs.client.com:/VOL_LDAP_HOME_'
      line += env.upcase
      line += '/Q_LDAP_HOME_'
      line += env.upcase
      cmd = 'echo ' + line + ' > /etc/auto.ccs'

      ruby_block 'create /home/ldapccs automount' do
        block do
          shell_out('stopsrc -s automountd')
          shell_out('echo "/-\t/etc/auto.ccs" > /etc/auto_master')
          shell_out(cmd)
          tempfile = Chef::Util::FileEdit.new('/etc/rc.nfs')
          tempfile.search_file_replace_line('/usr/sbin/automount.*', '/usr/sbin/automount -i 60')
          tempfile.write_file
          shell_out('startsrc -s automountd')
          shell_out('/usr/sbin/automount -i 60')
        end
        not_if 'grep /home/ldapccs /etc/auto.ccs'
      end

      Chef::Log.info('LDAP filesets configuration.........')
      #############################
      # LDAP filesets configuration
      #############################
      directory '/usr/local/lib' do
        recursive true
      end
      ruby_block 'creating links for LDAP client utilities' do
        block do
          shell_out('/opt/IBM/ldap/V6.1/bin/idslink -i -l 64')
          shell_out('ln -sf /opt/IBM/ldap/V6.1/lib/libibmldap.a /usr/lib/libibmldap.a')
          shell_out('ln -sf /opt/IBM/ldap/V6.1/lib/libibmldap.a /usr/local/lib/libibmldap.a')
          shell_out('ln -sf /opt/IBM/ldap/V6.1/lib/libibmldapdbg.a /usr/local/lib/libibmldapdbg.a')
          shell_out('ln -sf /opt/IBM/ldap/V6.1/lib/libidsldapiconv.a /usr/local/lib/libidsldapiconv.a')
          shell_out('ln -sf /etc/security/ldap/ldap.cfg /etc/ldap.conf')
        end
        not_if 'ls /usr/lib/libibmldap.a /usr/local/lib/libibmldap.a /usr/local/lib/libibmldapdbg.a /usr/local/lib/libidsldapiconv.a /etc/ldap.conf >/dev/null'
      end

      Chef::Log.info('LDAP installation.........')
      ###################
      # LDAP installation
      ###################
      directory certdir do
        owner 'root'
        group 'system'
        mode '644'
        recursive true
      end

      file = ::File.open('/tmp/mkldap.sh', 'w')
      file.puts('export PATH=/usr/java5/bin:$PATH')
      file.puts("gsk7cmd -keydb -create -db #{sslkeypath} -pw #{sslkeypwd} -type cms")
      file.puts("gsk7cmd -keydb -stashpw -db #{sslkeypath} -pw #{sslkeypwd}")
      certificates.each do |certificate|
        label = certificate.split('.')[0]
        cookbook_file "#{certdir}/#{certificate}" do
          source certificate
          owner 'root'
          group 'system'
          mode '644'
          action :create_if_missing
        end
        file.puts("gsk7cmd -cert -add -db #{sslkeypath} -pw #{sslkeypwd} -file #{certdir}/#{certificate} -format ascii -label #{label} -trust enable")
      end
      file.puts("mksecldap -c -h #{servers} -d #{basedn} -a #{binddn} -p #{pwd} -n #{port} -k #{sslkeypath} -T #{heartbeatinterval} -t #{cachetimeout}")
      file.close

      execute 'LDAP installation' do
        command 'ksh /tmp/mkldap.sh'
        not_if 'ls-secldapclntd > /dev/null'
      end

      ruby_block 'update of 2307aixuser.map' do
        block do
          tempfile = Chef::Util::FileEdit.new('/etc/security/ldap/2307aixuser.map')
          line = "lastupdate\tSEC_INT\t\tshadowlastchange\ts\tseconds\tyes"
          tempfile.search_file_replace_line('^lastupdate', line)
          tempfile.write_file
        end
        not_if 'grep ^lastupdate /etc/security/ldap/2307aixuser.map|grep -q seconds'
      end

      Chef::Log.info('Users configuration for LDAP.........')
      #####################
      # Users configuration
      #####################
      localusers = shell_out('lsuser -R compat -a ALL | grep -Ewv "root|daemon|bin|sys|adm|uucp|guest|nobody|lpd|lp|invscout|snapp|nuucp|ipsec|sshd|ldap"').stdout.split
      # localusers += data['username'].split

      localusers.uniq.reject { |i| i == 'root' }.each do |user|
        execute "chsec -f /etc/security/user -s #{user} -a SYSTEM=compat -a registry=files" do
          not_if { shell_out("grep -p #{user} /etc/security/user | egrep  'SYSTEM = \"compat\"|registry = files' | wc -l").stdout.chomp.to_i == 2 }
        end
      end

      execute 'chsec -f /etc/security/user -s default -a SYSTEM="LDAP or compat" -a registry=LDAP' do
        not_if 'lssec -f /etc/security/user -s default -a registry -a SYSTEM | grep "registry=LDAP" | grep "LDAP or compat"'
      end

      cookbook_file '/etc/sudoers' do
        source 'sudoers'
        owner 'root'
        group 'system'
        mode '0440'
      end

      file '/etc/sudoers.local' do
        owner 'root'
        group 'system'
        mode '0440'
      end
    end
    if platform_family?('rhel')
      Chef::Log.info('Configuring LDAP/SSSD Authentication.....')

      # updating /etc/sysconfig/authconfig
      Chef::Log.info('Updating /etc/sysconfig/authconfig..................')
      auth_conf = '/etc/sysconfig/authconfig'

      USEMKHOMEDIR = shell_out("sed -i -e 's/USEMKHOMEDIR=.*/USEMKHOMEDIR=yes/' #{auth_conf}")
      USESSSDAUTH = shell_out("sed -i -e 's/USESSSDAUTH=.*/USESSSDAUTH=yes/' #{auth_conf}")
      FORCELEGACY = shell_out("sed -i -e 's/FORCELEGACY=.*/FORCELEGACY=yes/' #{auth_conf}")
      USELDAPAUTH = shell_out("sed -i -e 's/USELDAPAUTH=.*/USELDAPAUTH=no/' #{auth_conf}")
      USELDAP = shell_out("sed -i -e 's/USELDAP=.*/USELDAP=no/' #{auth_conf}")
      USEFPRINTD = shell_out("sed -i -e 's/USEFPRINTD=.*/USEFPRINTD=no/' #{auth_conf}")
      passalgo = shell_out('authconfig --enableshadow --passalgo=md5')

      Chef::Log.debug("USEMKHOMEDIR : #{USEMKHOMEDIR}")
      Chef::Log.debug("USESSSDAUTH : #{USESSSDAUTH}")
      Chef::Log.debug("FORCELEGACY : #{FORCELEGACY}")
      Chef::Log.debug("USELDAPAUTH : #{USELDAPAUTH}")
      Chef::Log.debug("USELDAP : #{USELDAP}")
      Chef::Log.debug("USEFPRINTD : #{USEFPRINTD}")
      Chef::Log.debug("passalgo : #{passalgo}")

      # Adding ldap home to fstab
      Chef::Log.info('Adding ldap home to fstab..................')

      if (node['hostname'].include? '-lx') || (node['hostname'].include? '-mrspl')
        execute 'fstab-ldapccs-prd' do
          command 'echo "nashost:/vol/ldap_home_prd      /home/ldapccs   nfs     defaults        0 0" >> /etc/fstab'
          action :run
          not_if { shell_out('cat /etc/fstab |grep nashost:/vol/ldap_home_prd').stdout.chop != '' }
        end
      else
        execute 'fstab-ldapccs-dev' do
          command 'echo "hostname.client.com:/VOL_LDAP_HOME_DEV/Q_LDAP_HOME_DEV      /home/ldapccs   nfs     defaults        0 0" >> /etc/fstab'
          action :run
          not_if { shell_out('cat /etc/fstab |grep hostname.client.com:/VOL_LDAP_HOME_DEV/Q_LDAP_HOME_DEV').stdout.chop != '' }
        end
      end
      shell_out('mount /home/ldapccs')

      # Configuring NSSwitch
      Chef::Log.info('Configuring NSSwitch and updating /etc/nsswitch.conf..................')
      nsswitch_conf = '/etc/nsswitch.conf'

      passwd = shell_out("sed -i -e 's/passwd:.*/passwd:  files sss/' #{nsswitch_conf}")
      shadow = shell_out("sed -i -e 's/shadow:.*/shadow:  files sss/' #{nsswitch_conf}")
      group = shell_out("sed -i -e 's/group:.*/group:  files sss/' #{nsswitch_conf}")
      services = shell_out("sed -i -e 's/services:.*/services:  files sss/' #{nsswitch_conf}")
      netgroup = shell_out("sed -i -e 's/netgroup:.*/netgroup:  files sss/' #{nsswitch_conf}")
      automount = shell_out("sed -i -e 's/automount:.*/automount:  files sss/' #{nsswitch_conf}")
      sudoers = shell_out("sed -i -e 's/^sudoers:.*/sudoers:  files sss/' #{nsswitch_conf}")

      Chef::Log.debug("passwd : #{passwd}")
      Chef::Log.debug("shadow : #{shadow}")
      Chef::Log.debug("group : #{group}")
      Chef::Log.debug("services : #{services}")
      Chef::Log.debug("netgroup : #{netgroup}")
      Chef::Log.debug("automount : #{automount}")
      Chef::Log.debug("sudoers : #{sudoers}")

      # SSSD file /etc/sssd/sssd.conf
      Chef::Log.info('Configuring SSSD..................')
      template '/etc/sssd/sssd.conf' do
        source 'sssd.conf.erb'
        owner 'root'
        mode '0600'
        action :create
      end

      # Configuring LDAP
      Chef::Log.info('Configuring LDAP............')

      template '/etc/openldap/ldap.conf' do
        source 'ldap.conf.erb'
        owner 'root'
        mode '0644'
        action :create
      end

      # Updating sudo access Rights
      Chef::Log.info('Configuring LDAP sudo access............')
      template '/etc/sudo-ldap.conf' do
        source 'sudo-ldap.conf.erb'
        owner 'root'
        mode '0644'
        action :create
      end

      # Updating sudo access rights in nsswitch
      execute 'sudo-access-rights' do
        command "echo 'sudoers:    files sss' >> /etc/nsswitch.conf"
        action :run
        not_if { shell_out('cat /etc/nsswitch.conf |grep "sudoers:    files sss"').stdout.chop != '' }
      end

      # Applying Authentication
      Chef::Log.info('Reload authentification configuration............')
      execute 'applying-authentication' do
        command 'authconfig --updateall'
        action :run
      end

      # Restart sssd service
      Chef::Log.info('Restarting sssd service............')
      service 'sssd' do
        action :restart
      end

      # Enable autofs service
      Chef::Log.info('Enabling autofs service............')
      service 'autofs' do
        action :enable
      end

      # Enable rpcbind service
      Chef::Log.info('Enabling rpcbind service............')
      service 'rpcbind' do
        action :enable
      end
    end
  end
end
