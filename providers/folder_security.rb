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

      # path of the directories to secure
      dir_win = '\\Windows'
      dir_security = '\\Windows\\security'
      dir_syst = '\\Windows\\system'
      dir_syst32 = '\\Windows\\systeme32'
      dir_grppolicy = '\\Windows\\system32\\GroupPolicy'
      dir_config = '\\Windows\\system32\\config'
      dir_drives = '\\Windows\\system32\\drivers'
      dir_spool = '\\Windows\\system32\\spool'
      dir_syswow = '\\Windows\\syswow64'
      dir_sysdriver = '\\Windows\\syswow64\\drivers'
      folders = [dir_win, dir_security, dir_syst, dir_syst32, dir_grppolicy, dir_config, dir_drives, dir_spool, dir_syswow, dir_sysdriver]

      Chef::Log.info('Applying the security on folders....')

      ruby_block 'create-file' do
        block do
          # Get the system drive
          drive = powershell_out('Get-Content env:systemdrive').stdout.chop
          Chef::Log.debug("Driver Letter: #{drive}")

          # For each folders, change owner and apply acl
          folders.each do |i|
            Chef::Log.info("Applying folder security on: #{drive}#{i}")
            takeown = powershell_out("TAKEOWN /F '#{drive}#{i}'").stdout
            Chef::Log.debug('takeown : ' + takeown)

            acl = powershell_out("get-acl #{drive}#{i} -audit | set-acl #{drive}#{i}").stdout
            Chef::Log.debug('acl : ' + acl)
          end
          # Disable UAC
          uac = powershell_out('New-ItemProperty -Path HKLM:Software\\Microsoft\\Windows\\CurrentVersion\\policies\\system -Name EnableLUA -PropertyType DWord -Value 0 -Force').stdout
          Chef::Log.debug("uac : #{uac}")
        end
        action :create
      end

      powershell_script 'disable-tls' do
      code <<-EOH
      New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Force
      New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -Force
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name 'Enabled' -value 0 –PropertyType DWORD
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name 'DisabledByDefault' -value 1 –PropertyType DWORD
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -name 'Enabled' -value 0 –PropertyType DWORD
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -name 'DisabledByDefault' -value 1 –PropertyType DWORD

      New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -Force
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -name Enabled -value 0 –PropertyType DWORD

      New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Force
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -name Enabled -value 0 –PropertyType DWORD

      New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Force
      New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Force
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name 'Enabled' -value 1 –PropertyType DWORD
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name 'DisabledByDefault' -value 0 –PropertyType DWORD
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name 'Enabled' -value 1 –PropertyType DWORD
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name 'DisabledByDefault' -value 0 –PropertyType DWORD

      New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force
      New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Force
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'Enabled' -value 1 –PropertyType DWORD
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'DisabledByDefault' -value 0 –PropertyType DWORD
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'Enabled' -value 1 –PropertyType DWORD
      New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'DisabledByDefault' -value 0 –PropertyType DWORD

      Disable-TlsCipherSuite -Name TLS_RSA_WITH_RC4_128_MD5
      Disable-TlsCipherSuite -Name TLS_RSA_WITH_RC4_128_SHA
      EOH
      end

      Chef::Log.info('Configuring security audit')
      powershell_out('auditpol /set /subcategory:"IPsec Driver" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Sensitive Privilege Use" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Audit Policy Change" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Directory Service Access" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Directory Service Changes" /failure:enable')
      powershell_out('auditpol /set /subcategory:"SAM" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Security System Extension" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Detailed Directory Service Replication" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Other Logon/Logoff Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Logoff" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Directory Service Replication" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Computer Account Management" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Security State Change" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Application Generated" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Certification Services" /failure:enable')
      powershell_out('auditpol /set /subcategory:"IPsec Main Mode" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"IPsec Extended Mode" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Account Lockout" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Application Group Management" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Kernel Object" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Other Policy Change Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Authorization Policy Change" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Kerberos Service Ticket Operations" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Other Privilege Use Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Distribution Group Management" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Non Sensitive Privilege Use" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Authentication Policy Change" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"MPSSVC Rule-Level Policy Change" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Other Account Management Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Other Object Access Events" /failure:enable')
      powershell_out('auditpol /set /subcategory:"File System" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Registry" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Filtering Platform Policy Change" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Kerberos Authentication Service" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Audit Logon Credential Validation" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Special Logon" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Security Group Management" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Handle Manipulation" /failure:enable')
      powershell_out('auditpol /set /subcategory:"File Share" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Filtering Platform Packet Drop" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Detailed File Share" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Filtering Platform Connection" /failure:enable')
      powershell_out('auditpol /set /subcategory:"IPsec Quick Mode" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Other Account Logon Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"User Account Management" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Kerberos Service Ticket Operations" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Other Account Management Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Filtering Platform Policy Change" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Audit Logon Credential Validation" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Detailed Directory Service Replication" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Detailed File Share" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Application Group Management" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Non Sensitive Privilege Use" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Directory Service Access" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Other Policy Change Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"IPsec Extended Mode" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Other Logon/Logoff Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Computer Account Management" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Account Lockout" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Kernel Object" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Security State Change" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Directory Service Replication" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Security System Extension" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Other Privilege Use Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Filtering Platform Connection" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Other Object Access Events" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Application Generated" /failure:enable')
      powershell_out('auditpol /set /subcategory:"MPSSVC Rule-Level Policy Change" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Handle Manipulation" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Distribution Group Management" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Directory Service Changes" /failure:enable')
      powershell_out('auditpol /set /subcategory:"File System" /failure:enable')
      powershell_out('auditpol /set /subcategory:"User Account Management" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Authorization Policy Change" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Authentication Policy Change" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"File Share" /failure:enable')
      powershell_out('auditpol /set /subcategory:"IPsec Main Mode" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Other Account Logon Events" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"IPsec Quick Mode" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Special Logon" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Kerberos Authentication Service" /failure:enable /success:enable')
      powershell_out('auditpol /set /subcategory:"Certification Services" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Filtering Platform Packet Drop" /failure:enable')
      powershell_out('auditpol /set /subcategory:"Security Group Management" /failure:enable /success:enable')

      Chef::Log.info('Configuring password policy')
      powershell_out('net accounts /lockoutthreshold:5 /minpwlen:8 /uniquepw:5')

      Chef::Log.info('Administrator password to expire')
      powershell_out('wmic useraccount where "name=\'Administrator\'" set PasswordExpires=true')

    end
  end
end
