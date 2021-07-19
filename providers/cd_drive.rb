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

action :rename do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
      Chef::Log.info('Renaming CD drive ....')

      # Get the CD drive and change its letter to X:
      driveletter = powershell_out("get-WmiObject Win32_Volume -Filter 'DriveType = 5 ' |  set-wmiinstance -Arguments @{DriveLetter = 'X:'}").stdout.chop

      Chef::Log.debug('driveletter : ' + driveletter)

      # registry key path value for Auto run
      keypath_auto_run = 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\Cdrom'
      # registry key name value for Auto run
      keyname_auto_run = 'AutoRun'
      # registry key data value
      keydata_auto_run = '0'

      registry_key keypath_auto_run do
        Chef::Log.info('Disabling Auto  Run....')
        values [{ name: keyname_auto_run, type: :dword, data: keydata_auto_run }]
        action :create_if_missing
        not_if { registry_data_exists?(keypath_auto_run, { name: keyname_auto_run, type: :dword, data: keydata_auto_run }, :machine) }
      end

      # registry key path value for Auto run
      keypath_auto_run_bis = 'HKEY_LOCAL_MACHINE\\SYSTEM\\ControlSet001\\Services\\Cdrom'

      registry_key keypath_auto_run_bis do
        Chef::Log.info('Disabling Auto  Run....')
        values [{ name: keyname_auto_run, type: :dword, data: keydata_auto_run }]
        action :create_if_missing
      end

      registry_key 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer' do
        Chef::Log.info('Disabling Drive Type AutoRun....')
        values [{ name: 'NoDriveTypeAutoRun', type: :dword, data: '255' }]
        recursive true
        action :create_if_missing
      end

      registry_key 'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\LSA' do
        Chef::Log.info('Forcing Audit....')
        values [{ name: 'SCENoApplyLegacyAuditPolicy', type: :dword, data: '1' }]
        recursive true
        action :create_if_missing
      end

      registry_key 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\EventLog\\Security' do
        Chef::Log.info('Retention....')
        values [{ name: 'Retention', type: :dword, data: '4294967295' }]
        recursive true
        action :create_if_missing
      end
    end
  end
end
