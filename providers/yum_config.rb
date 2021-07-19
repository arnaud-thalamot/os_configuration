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

action :config do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
    else

      resource = @new_resource

      Chef::Log.info('Configuring yum repository....')
      # copy file /etc/yum.conf.distrib
      file '/etc/yum.conf.distrib' do
        owner 'root'
        group 'root'
        mode 0755
        content ::File.open('/etc/yum.conf').read
        action :create
      end

      # set parameters for /etc/yum.conf file
      template '/etc/yum.conf' do
        source 'yum.conf.erb'
        owner 'root'
        mode '0644'
        variables(
          CacheDir: resource.cachedir,
          KeepCache: resource.keepcache,
          DebugLevel: resource.debuglevel,
          LogFile: resource.logfile,
          DistroverPkg: resource.distroverpkg,
          Tolerant: resource.tolerant,
          ExactArch: resource.exactarch,
          Obsoletes: resource.obsoletes,
          GpgCheck: resource.gpgcheck,
          Plugins: resource.plugins,
          Exclude: resource.exclude,
          TsFlags: resource.tsflags,
          Metadata_Expire: resource.metadata_expire
        )
      end

      # create file /etc/yum.repos.d/redhatix4.repo
      template '/etc/yum.repos.d/redhatix4.repo' do
        source 'redhatix4.repo.erb'
        owner 'root'
        mode '0644'
        action :create
      end

      # create file /etc/yum.conf.forcekernelupdate
      template '/etc/yum.conf.forcekernelupdate' do
        source 'yum.conf.forcekernelupdate.erb'
        owner 'root'
        mode '0644'
        variables(
          CacheDir: resource.cachedir,
          KeepCache: resource.keepcache,
          DebugLevel: resource.debuglevel,
          LogFile: resource.logfile,
          DistroverPkg: resource.distroverpkg,
          Tolerant: resource.tolerant,
          ExactArch: resource.exactarch,
          Obsoletes: resource.obsoletes,
          GpgCheck: resource.gpgcheck,
          Plugins: resource.plugins,
          Exclude: resource.exclude,
          TsFlags: resource.tsflags,
          Metadata_Expire: resource.metadata_expire
        )
      end
    end
  end
end
