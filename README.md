OS-Configuration Cookbook

OS-configuration cookbook configures/installs policies and configuration requirement. It is responsible for prerequisite configuration and installation once the VM is provisioned.It installs base packages required for utilities and application deployment on the system. Policies for linux platform are performed by this cookbook.

Following configuration changes are performed by OS-configuration cookbook:-

- Install Prerequite packages @ base, @ directory-client, @ directory-server, @ emacs, @ network-file-system-client, @ x11, sysstat, bluez-pin, NetworkManager, iptraf, lvm2, e2fsprogs, ncompress, sendmail, sendmail-cf, openldap-clients, ksh, telnet, dbus, perl, libstdc++-devel, ld-linux.so.2, kernel-headers, gcc, kernel-devel, nscd
- Configure Yum repository
- Configure Network Attached Storage
- Setting site-specific configuration for shadow
- Configuring NTP server
- Chron setting
- Kernel Settings
- Setting Profile - Color Shell
- Mail server setting
- Setting crontab
- Setting swap size
- Configuring Network
- SSH-Server setting
- Updating User
- Setting LDAP/SSSD Authentication
- Automounting LDAP user home
- Configuring Network switch
- Setting Sudo Access Rights
- Applying Authentication setting
- Installing Complimentary settings
- Troubleshooting
- Update Settings

Requirements

- Storage : 2 GB
- RAM : 2 GB
- Versions
	- Chef Development Kit Version: 0.17.17
	- Chef-client version: 12.13.37
	- Kitchen version: 1.11.1

Platforms

    RHEL-7

Chef

    Chef 11+

Cookbooks

    none

Resources/Providers

- os_config
	This lwrp calls other lwrp's for different configurational changes. This lwrp is called from the recipe.

  Example
 
  os_configuration_os_config 'configure_os' do
    action [:configure]
  end

  Actions
  configure : this action configures the entire system into client complaint configuration.
  
- crontab
	This lwrp is used for applying crontab settings for client environment.

 Example

  os_configuration_crontab 'configure-crontab' do
    action :configure
  end
  
  Actions
  configure : this action is use to set the crontab for the system.

- domain
	This lwrp is used for configuring the network domain for the provisioned VM.

  Example

  os_configuration_domain 'join_domain' do
    action [:join]
    domain domain_integration
    ou ou_integration
    username username_integration
    password password_integration
  end
  
  Actions
  join : this action is use join the client domain.

- folder_security
	This lwrp is used for applying folder security to the provisioned VM to comply with client-CGM security policies.

  Example

  os_configuration_folder_security 'apply_foldersecurity' do
    action [:apply]
  end
  
  Actions
  apply : this action applies the folder security to be client complaint
  
- ism_tools_disk
	This lwrp creates a file system for installing the ISM tools. It is mandatory to have dedicated file system for ISM tools as a part of client compliance.

  Example

  os_configuration_ism_tools_disk 'create-ismtools-disk' do
    action :create
  end
  
  Actions
  create : this action creates a dedicated disk on the node for ISM tools to comply with client policy.
  
- ldap
	This lwrp will apply the LDAP/SSSD authentication settings.

  Example

  os_configuration_ldap 'configure-ldap' do
    action :configure
  end
  
  Actions
  configure : this action sets the ldap configuration.

- login_config
	This lwrp will apply site specific configuration for shadow. It modifies the login.defs system file.

  Example

  os_configuration_ldap 'configure-ldap' do
    action :configure
  end
  
  Actions
  configure : It configures the login for ldap by changing the login.defs file.

- mail_config
	This lwrp will configure the mail notification setting for the provisioned VM.

  Example

  os_configuration_mail_config 'configure-mail' do
    action :apply
    servername mail
    smtpname smtp
  end
  
  Actions
  apply : this action configures the mail on the system to send notifications for certain operations on the system.

- nas_share
	This lwrp will configure the NAS for sharing data across.

  Example

  os_configuration_nas_share 'create-nas-share-exportnas' do
    action :create
    naspath ''
    nasvolume ''
    nashost ''
  end

  where,
    naspath - It is the path for NAS sharing
    nasvolume - It is the volume set for NAS
    nashost - It is the host for NAS sharing
	
  Actions
  create : this action is used to configure the Network sharing to access client repository.


- network
	This lwrp will configure the IPv6 to enable/disable.

  Example

  os_configuration_network 'disable_IPv6' do
    action [:disableIPv6]
  end
  
  Actions
  disableIPv6 : this action is used to disable the IPV6 on the system.

- network_adapter
	This lwrp can create/rename network adapter for the provisioned VM.

  Example

  os_configuration_network_adapter 'rename_network_adapter' do
    action [:rename]
  end
  
  Actions
  rename : this action is used to rename the network ethernet adapter.

- ntp
	This lwrp will configure the NTP server.

  Example

  os_configuration_ntp 'configure-ntp' do
    action :configure
    ntp1 ntp1
    ntp2 ntp2
  end

  where,
  ntp1 - primary server for NTP
  ntp2 - secondary/backup server for NTP
  
  Actions
  configure : this action is used to configure the NTP server.
	
- resolve
	This lwrp will set the hostname and nameserver to resolve specific host.
	
  Example

  os_configuration_resolv 'configure-resolv' do
    action :configure
    nameserver1 nameserver1
    nameserver2 nameserver2
    nameserver3 nameserver3
  end

  where,
  nameserver1,nameserver2 and nameserver3 - are different domain name in resolv.conf for DNS settins on the node
  
  Actions
  configure : this action updatees the resolv.conf file to communicate in different domains.
  
- snmp

- sqm
	This lwrp disable SQM
  Example

  os_configuration_sqm 'disable_sqm' do
    action [:disable]
  end
  
  Actions
  disable : 

- ssh
	This lwrp installs Open-ssh server for enabling the ssh communication for the node. Also it will update ssh server settings for the node.

  Example

  os_configuration_ssh 'configure_ssh' do
    action [:configure]
  end
  
  Actions
  configure : enables ssh in the system.

- swap
	This lwrp creates swap space with input size specified.

  Example

  os_configuration_swap 'create-swap' do
    action :create
    size 4
  end
  
  create : this action creates the swap space in the system.

- telnet
	This lwrp installs telnet service in the node.
	
  Example

  os_configuration_telnet 'install_telnet' do
    action [:install]
  end
  
  Actions
  install : this action installs the telnet service in the system.

- tools
	This lwrp installs complementary tools. Performs authentication configuration changes. Modifies system profile for the node.

  Example

  os_configuration_tools 'install_tools' do
    action :install
  end
  
  Actions
  install : this action installs the complimentary tools in the system and configures the system profile.

- user
	This lwrp is used for generating ssh keys, creating authorized keys and updating root settings.

  Example

  os_configuration_user 'create-users' do
    action [:createroot, :createunixtech, :createapptaddm]
  end
  
  Actions
  createroot : this action creates root user
  createunxtech :
  createapptaddm : 
  
- yum_config
	This lwrp is used for configuring the yum repository with client specific repository settings. This enables installing rpms and its dependencies.

  Example

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
  
  where,
  cachedir, keepcache, debuglevel, logfile, distroverpkg, tolerant, exactarch, obsoletes, gpgcheck, plugins, exclude, tsflags, metadata_expire - are the configuraiton parameters required to configure the yum repository

  Actions
  configure : this action configure the yum repository in the system to install the packages.

Recipes

    configure:: This recipe performs the configuration for client specific environment. It configures system level settings to comply with client-CGM policies and network.
 
