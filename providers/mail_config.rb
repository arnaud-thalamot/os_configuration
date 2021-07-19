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
    end
    if platform_family?('aix')

      resource = @new_resource
      smtpname = resource.smtpname

      Chef::Log.info('Applying mail settings ...........')

      filen1 = '/home/root/.forward'
      resource = @new_resource

      directory '/home/root' do
        owner 'root'
        group 'system'
        mode 0755
      end

      Chef::Log.info('Configuring mail forward for #{resource.servername} ...........')
      # Configure mail forward with the given email
      execute 'mail-forward' do
        command "echo \"#{resource.servername}\" > #{filen1} 2>/dev/null"
        not_if "grep -q #{resource.servername} #{filen1}"
      end

      Chef::Log.info('Configuring smtp #{resource.smtpname}...........')
      # Configure smtp with the given server address
      ruby_block 'update sendmail SMTP relay' do
        block do
          tempfile = Chef::Util::FileEdit.new('/etc/mail/sendmail.cf')
          tempfile.search_file_replace_line('^DS', "DS#{smtpname}")
          tempfile.write_file
        end
        not_if "grep -q DS#{smtpname} /etc/mail/sendmail.cf"
      end

      ruby_block 'update sendmail sender name format' do
        block do
          OsConfiguration.save_config_file('/etc/mail/sendmail.cf')
          tempfile = Chef::Util::FileEdit.new('/etc/mail/sendmail.cf')
          tempfile.search_file_replace('mDFMuX', 'cDFMuX')
          tempfile.write_file
        end
        only_if "grep -q 'mDFMuX' /etc/mail/sendmail.cf"
      end
    end
    if platform_family?('rhel')
      Chef::Log.info('Applying mail settings ...........')

      filen1 = '/root/.forward'
      resource = @new_resource

      Chef::Log.info('Configuring mail forward for #{resource.servername} ...........')
      # Configure mail forward with the given email
      execute 'mail-forward' do
        command "echo \"#{resource.servername}\" > #{filen1}"
        action :run
      end

      Chef::Log.info('Configuring smtp #{resource.smtpname}...........')
      # Configure smtp with the given server address
      execute 'sendmail' do
        command "sed -i 's/^DS.*/DS#{resource.smtpname}/' /etc/mail/sendmail.cf"
        action :run
      end
    end
  end
end
