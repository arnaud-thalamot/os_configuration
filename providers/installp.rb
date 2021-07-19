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

action :install do
  if @location.nil?
    Chef::Log.error('location parameter is required for :install action')
    raise
  end
  cmd = 'installp -d ' + @location + ' ' + @options + ' ' + @fileset
  installp = ::Mixlib::ShellOut.new(cmd)
  if @current_resource.installed
    Chef::Log.info("#{@fileset} is already installed")
  else
    converge_by("installing #{@fileset}") do
      installp.run_command
      if installp.error?
        Chef::Log.error('the command ' + cmd + ' failed')
        Chef::Log.error("\n" + installp.stderr)
        raise
      end
    end
  end
end

action :uninstall do
  cmd = 'installp -u ' + @options + ' ' + @fileset
  installp = ::Mixlib::ShellOut.new(cmd)
  if @current_resource.installed
    converge_by("uninstalling #{@fileset}") do
      installp.run_command
      if installp.error?
        Chef::Log.error('the command ' + cmd + ' failed')
        Chef::Log.error("\n" + installp.stderr)
        raise
      end
    end
  else
    Chef::Log.info("#{@fileset} is not installed")
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OsConfigurationInstallp.new(@new_resource.name)
  @name = @new_resource.name
  @fileset = @new_resource.fileset
  @fileset = @name if @fileset.nil?
  unless shell_out("lslpp -l | grep #{@fileset}").stdout.empty?
    @current_resource.installed = true
  end
  @location = @new_resource.location
  @options = @new_resource.options
end
