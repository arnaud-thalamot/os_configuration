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

###################################
#        Windows parameters       #
###################################

# Download link fix framework 3.5
urlfix = 'https://client.com/ibm//windows2012R2/osconfig/NDPFixit-KB3005628-X64.exe'
# Download link framework 3.5
urlframework = 'https://client.com/ibm//windows2012R2/osconfig/dotnet_framework_35.zip'
# Path of fix framework 3.5
pathfix = 'C:/Windows/Temp/NDPFixit-KB3005628-X64.exe'
# Path of framework 3.5
pathframework = 'C:/Windows/Temp/dotnet_framework_35.zip'
# Domain
domain_integration = 'CLIENT.COM'
username_integration = 'username'
password_integration = 'password'

###################################
#        Redhat parameters        #
###################################

# Package group list to install
package_group_list = ['@base', '@directory-client', '@directory-server', '@emacs', '@network-file-system-client', '@x11']
# Package list to install
package_list = ['sysstat', 'iptraf', 'lvm2', 'e2fsprogs', 'ncompress', 'sendmail', 'sendmail-cf', 'openldap-clients',
                'ksh', 'telnet', 'dbus', 'perl', 'libstdc++-devel', 'ld-linux.so.2', 'kernel-headers', 'gcc', 'kernel-devel', 'nscd']
# attributes for /etc/yum.conf file
cachedir = '/var/cache/yum'
keepcache = 0
debuglevel = 3
logfile = '/var/log/yum.log'
distroverpkg = 'redhat-release'
tolerant = 1
exactarch = 1
obsoletes = 1
gpgcheck = 1
plugins = 0
exclude = 'kernel*'
tsflags = 'repackage'
metadata_expire = '1h'
# Login policy
passmaxdays = 90
passminlen = 8
uidmin = 500
gidmin = 500
# NTP servers
ntp1 = 'ntp1.client.com'
ntp2 = 'ntp2.client.com'
# Mail server
mail = 'ho.it_unix@client.com'
# SMTP server
smtp = 'cmaedi.client.com'
# Name servers
nameserver1 = '10.0.0.1'
nameserver2 = '10.0.0.2'
# SSH log level
loglevel = 'VERBOSE'
# SSH Maximum ssh login authorization failure allowed
maxauthries = 5
# SSH Permit Root to log via ssh
permitrootlogin = 'no'
# Url to retrieve sudoers
sudoersurl = 'https://10.0.0.2:81/Appl_Linux/sudo/sudoers'

###################################
# AIX os configuration parameters #
###################################

# Sources
#location = 'http://client.com/aix7/osconfig/osconfig.tar
location = '/distribnas/os_configuration'
# required FS
volumes = [
  { lvname: 'lvlog', fstype: 'jfs2', vgname: 'rootvg', size: 128, fsname: '/log' },
  { lvname: 'lvappl', fstype: 'jfs2', vgname: 'rootvg', size: 512, fsname: '/appl' },
  { lvname: 'lvprod', fstype: 'jfs2', vgname: 'rootvg', size: 64, fsname: '/production' },
  { lvname: 'lvmksysb', fstype: 'jfs2', vgname: 'rootvg', size: 8192, fsname: '/mksysb' },
  { lvname: 'lvldap', fstype: 'jfs2', vgname: 'rootvg', size: 512, fsname: '/opt/IBM/ldap' }
]
# NAS mounts
mounts = [
  { nashost: 'distrib-nfs', nasvolume: '/VOL_DISTRIB/Q_DISTRIB', naspath: '/distribnas' },
  { nashost: 'distrib-nfs', nasvolume: '/VOL_EXPORT/Q_EXPORT', naspath: '/exportnas' }
]
# Additional AIX filesets
custom_filesets = [
  'freeware.ccs.tuning',
  'freeware.ccs.security',
  'coe_unix_fr.sastracing',
  'freeware.ccs.sudo',
  'gsksa',
  'gskta',
  'idsldap.clt32bit61',
  'idsldap.clt64bit61',
  'idsldap.clt_max_crypto32bit61',
  'idsldap.clt_max_crypto64bit61',
  'idsldap.cltbase61',
  'idsldap.cltjava61'
]
# Config files to be modified
configfiles = [
  { filename: '/etc/ssh/ssh_config',
    separator: ' ',
    daemon: 'sshd',
    method: 'srcmstr',
    params:
      { 'StrictHostKeyChecking' => 'no' } },

  { filename: '/etc/ssh/sshd_config',
    separator: ' ',
    daemon: 'sshd',
    method: 'srcmstr',
    params:
      { 'XAuthLocation' => '/usr/bin/X11/xauth',
        'X11Forwarding' => 'yes',
        'MaxAuthTries' => '5',
        'PermitRootLogin' => 'no' } },

  { filename: '/etc/environment',
    separator: '=',
    daemon: '',
    method: '',
    params:
      { 'TZ' => 'CUT0',
        'HISTSIZE' => '5000',
        'EXTENDED_HISTORY' => 'ON' } },

  { filename: '/etc/cronlog.conf',
    separator: '=',
    daemon: 'cron',
    method: 'sighup',
    params:
      { 'logfile' => '/var/adm/cron/log',
        'size' => '1m',
        'rotate' => '10' } },

  { filename: '/etc/syslog.conf',
    separator: ' ',
    daemon: 'syslogd',
    method: 'srcmstr',
    params:
      { '*.err' => '/var/adm/syslog.err rotate size 1000k files 10',
        '*.debug' => '/var/adm/syslog.debug rotate size 1000k files 10',
        'auth.info' => '/var/log/auth.log rotate time 10d files 9 compress archive /var/log',
        'auth.debug' => '/var/adm/secure rotate files 3 time 1d compress' } },

  { filename: '/etc/security/ldap/ldap.cfg',
    separator: ' ',
    daemon: 'ldap',
    method: 'secladpclntd',
    params:
      { 'base' => 'o=ccs,c=com',
        'uri' => 'ldap://ldap1 ldap://ldap2',
        'sudoers_base' => 'cn=SUDOers,o=ccs,c=com',
        'binddn' => 'cn=ccssudo,cn=Clients,o=ccs,c=com',
        'bindpw' => 'password',
        'ssl' => 'no' } },

  { filename: '/etc/netsvc.conf',
    separator: '=',
    daemon: '',
    method: '',
    params:
      {  'sudoers' => 'ldap,files' } }
]

# Mail server
mail_aix = 'mail@client.com'

# LDAP
ldap = {
  servers: 'ldap1,ldap2',
  basedn: 'o=ccs,c=com',
  binddn: 'cn=ccs,cn=Clients,o=ccs,c=com',
  port: '636',
  pwd: 'O2Source',
  certdir: '/usr/ldap/etc',
  sslkeypath: '/usr/ldap/etc/clientkey.kdb',
  sslkeypwd: 'password',
  heartbeatinterval: '10',
  cachetimeout: '60',
  certificates: ['cert1', 'cert2']
}

# NIM server
nimserver = 'hostname'

action :configure do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
      # Windows Part ---------------------------------------------------------------------------------------------------

      ruby_block 'download-fix' do
        block do
          Chef::Log.info 'download-fix'
          command = powershell_out 'netsh advfirewall set allprofiles state off'
          Chef::Log.debug command
        end
      end

      # Download fix for dotnet framework

      ruby_block 'download-fix' do
        block do
          Chef::Log.info 'download-fix'
          command = powershell_out "curl -OutFile #{pathfix} #{urlfix}"
          Chef::Log.debug command
        end
        not_if { ::File.exist?(pathfix.to_s) }
      end
      # Download dotnet framework 3.5
      ruby_block 'download-framework' do
        block do
          Chef::Log.info 'download-framework'
          command = powershell_out "curl -OutFile #{pathframework} #{urlframework}"
          Chef::Log.debug command
        end
        not_if { ::File.exist?(pathframework.to_s) }
      end
      # Install dotnet Framework 3.5 with fix
      os_configuration_dotnet_framework_35 'install-dotnet-35' do
        action [:install]
        installerpath pathframework
        fixpath pathfix
      end
      # Generating user keys
      os_configuration_user 'create-users' do
        action [:createroot, :createunixtech, :createapptaddm, :createicouser]
      end
      # Enable RDP
      os_configuration_rdp 'enable_rdp' do
        action [:enable]
      end
      # Disabling SQM
      os_configuration_sqm 'disable_sqm' do
        action [:disable]
      end
      # Install telnet
      os_configuration_telnet 'install_telnet' do
        action [:install]
      end
      # Rename network adapter
      os_configuration_network_adapter 'rename_network_adapter' do
        action [:rename]
      end
      # Disable IPV6
      os_configuration_network 'disable_IPv6' do
        action [:disableIPv6]
      end
      #  Disable Auto Update
      os_configuration_windows_update 'disable_windowsupdate' do
        action [:disable]
      end
      # Change CD drive letter
      os_configuration_cd_drive 'rename_cddrive' do
        action [:rename]
      end
      #  Add Windows Feature SNMP Service
      os_configuration_snmp 'install_snmp' do
        action [:install]
      end
      # Applying Folder Security
      os_configuration_folder_security 'apply_foldersecurity' do
        action [:apply]
      end

      # Joining Domain
      os_configuration_domain 'join_domain' do
        action [:join]
        domain domain_integration
        ou ou_integration
        username username_integration
        password password_integration
      end
    end
    if platform_family?('rhel')
       Linux Part -----------------------------------------------------------------------------------------------------
     # Applying network settings
     os_configuration_resolv 'configure-resolv' do
       action :configure
       nameserver1 nameserver1
       nameserver2 nameserver2
     end
     # configuring the yum repository
     os_configuration_yum_config 'Configure-Yum_Repository' do
       action :config
       cachedir cachedir
       keepcache keepcache
       debuglevel debuglevel
       logfile logfile
       distroverpkg distroverpkg
       tolerant tolerant
       exactarch exactarch
       obsoletes obsoletes
       gpgcheck gpgcheck
       plugins plugins
       exclude ''
       tsflags tsflags
       metadata_expire metadata_expire
     end
     # installing the prerequisite group packages on the system
     package_group_list.each do |group|
       execute "install #{group}" do
         command "yum install #{group} -y"
         action :run
       end
     end

     # installing the prerequisite packages on the system
     package_list.each do |dep|
       yum_package dep do
         action :install
         flush_cache [:before]
         ignore_failure true
       end
     end
     # configuring the yum repository
     os_configuration_yum_config 'Configure-Yum_Repository_with_exclude' do
       action :config
       cachedir cachedir
       keepcache keepcache
       debuglevel debuglevel
       logfile logfile
       distroverpkg distroverpkg
       tolerant tolerant
       exactarch exactarch
       obsoletes obsoletes
       gpgcheck gpgcheck
       plugins plugins
       exclude exclude
       tsflags tsflags
       metadata_expire metadata_expire
     end

     # Configure NAS
     os_configuration_nas_share 'create-nas-share-exportnas' do
       action :create
       naspath '/exportnas'
       nasvolume '/VOL_EXPORT/Q_EXPORT'
       nashost 'export-nfs.client.com'
     end
     os_configuration_nas_share 'create-nas-share-distribnas' do
       action :create
       naspath '/distribnas'
       nasvolume '/VOL_DISTRIB/Q_DISTRIB'
       nashost 'tools-nfs.client.com'
     end
     os_configuration_nas_share 'create-nas-share-tools' do
       action :create
       naspath '/tools'
       nasvolume '/VOL_TOOLS/Q_TOOLS'
       nashost 'tools-nfs.client.com'
     end

     # setting file /etc/login.defs parameters
     os_configuration_login_config 'apply-login-config' do
       action :apply
       PASS_MAX_DAYS passmaxdays
       PASS_MIN_LEN passminlen
       UID_MIN uidmin
       GID_MIN gidmin
     end
     # configuring NTP
     os_configuration_ntp 'configure-ntp' do
       action :configure
       ntp1 ntp1
       ntp2 ntp2
     end
     # Applying kernel settings
     Chef::Log.info('Applying Kernel settings .........')
     template '/etc/sysctl.conf' do
       source 'sysctl.conf.erb'
       owner 'root'
       mode '0644'
       action :create
     end

     execute 'reload-sysctl' do
       command 'sysctl --system'
       action :run
     end

     # configuring Mail settings
     os_configuration_mail_config 'configure-mail' do
       action :apply
       servername mail
       smtpname smtp
     end
     # Applying crontab settings
     os_configuration_crontab 'configure-crontab' do
       action :configure
     end
     # Create swap
     os_configuration_swap 'create-swap' do
       action :create
       size 4
     end
     # Disable Network Manager
     service 'NetworkManager' do
       action :disable
     end

     # Add Hostname in ifcfg-eth0
     execute 'add-hostname-ifcfg-eth0' do
       command "echo HOSTNAME=#{node['hostname']} >> /etc/sysconfig/network-scripts/ifcfg-eth0"
       action :run
       not_if { shell_out("cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep HOSTNAME=#{node['hostname']}").stdout.chop != '' }
     end
     # Applying Grub settings
     execute 'grub_setting' do
       command "sed -i \'s/GRUB_CMDLINE_LINUX=\"\\(.*\\)\"/GRUB_CMDLINE_LINUX=\"\\1 net.ifnames=0\"/' /etc/sysconfig/grub"
       action :run
       not_if { shell_out('cat /etc/sysconfig/grub | grep net.ifnames=0').stdout.chop != '' }
     end
     # Updating SSH server settings
     os_configuration_ssh 'configure-ssh' do
       action :configure
       loglevel loglevel
       maxauthtries maxauthries
       permitrootlogin permitrootlogin
     end

     # SUDOERS - save locally
     remote_file '/etc/sudoers' do
       source sudoersurl
       action :create
     end

     # Generating user keys
     os_configuration_user 'create-users' do
       action [:createroot, :createunixtech, :createapptaddm, :createmasterico]
     end

     # Create disk ISM Tools
     os_configuration_ism_tools_disk 'create-ismtools-disk' do
       action :create
     end
     # LDAP/SSSD settings
     os_configuration_ldap 'configure-ldap' do
       action :configure
     end

     # Mount NFS Shares
     execute 'mount-shares' do
       command 'mount -a'
       action :run
     end
    end
    if platform_family?('aix')
      # AIX Part -----------------------------------------------------------------------------------------------------

      # Custom FS creation
      volumes.each do |data|
        os_configuration_makefs "creation of #{data[:fsname]} file system" do
          lvname data[:lvname]
          fsname data[:fsname]
          vgname data[:vgname]
          fstype data[:fstype]
          size data[:size]
        end
      end

      # Configure NAS
      mounts.each do |data|
        os_configuration_nas_share "creation of #{data[:naspath]}" do
          naspath data[:naspath]
          nasvolume data[:nasvolume]
          nashost data[:nashost]
        end
      end

      # Custom filesets installation
      custom_filesets.each do |pack|
        if pack == 'freeware.ccs.security' && shell_out('ls /home/ldapccs > /dev/null').stderr.empty?
          Chef::Log.info('installation of freeware ccs.security.rte canceled due to /home/ldapccs mounted')
          next
        else
          os_configuration_installp "installation of #{pack}" do
            fileset pack
            location location
            options '-a -g -X -Y'
          end
        end
      end

      # configuring NTP
      os_configuration_ntp 'configure-ntp' do
        action :configure
      end

      # configuring TCPIP daemons
      os_configuration_rctcpip 'configure-rc.tcpip' do
        action :configure
      end

      # configuring Mail settings
      os_configuration_mail_config 'configure-mail' do
        action :apply
        servername mail_aix
        smtpname smtp
      end

      # Applying crontab settings
      os_configuration_crontab 'configure-crontab' do
        action :configure
      end

      # Generating user keys
      os_configuration_user 'create-users' do
        action [:createroot, :createunixtech, :createicouser]
      end

      # FC tuning
      os_configuration_fscsi_tuning 'tune FC protocol devices' do
        action :configure
      end

      # Change params in various config files
      configfiles.each do |file|
        filename = file[:filename]
        separator = file[:separator]
        daemon = file[:daemon]
        method = file[:method]
        file[:params].each do |parameter, value|
          os_configuration_config_files "change #{parameter} in #{filename}" do
            filename filename
            separator separator
            parameter parameter
            value value
            daemon daemon
            method method
            action :configure
          end
        end
      end

      # install complementary tools
      os_configuration_tools 'install-tools' do
        action :install
      end

      # LDAP installation
      os_configuration_ldap 'install-ldap' do
        servers ldap[:servers]
        basedn ldap[:basedn]
        binddn ldap[:binddn]
        port ldap[:port]
        pwd ldap[:pwd]
        certdir ldap[:certdir]
        sslkeypath ldap[:sslkeypath]
        sslkeypwd ldap[:sslkeypwd]
        heartbeatinterval ldap[:heartbeatinterval]
        cachetimeout ldap[:cachetimeout]
        certificates ldap[:certificates]
      end

      adapter = shell_out("netstat -rn|grep default|awk '{print $6}'").stdout.chomp
      nimclient = node['hostname']
      os_configuration_niminit 'configure niminfo file' do
        nimserver nimserver
        nimclient nimclient
        adapter adapter
      end
    end
  end
end
