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
      Chef::Log.info('Tuning FC prtocol devices.............')
      dvlist = shell_out('lsdev -C -c driver | grep fscsi').stdout.lines
      dvlist.each do |fscsi|
        f = fscsi.split
        dyn = shell_out("lsattr -El #{f[0]} -a dyntrk | awk '{print $2}'").stdout.chomp.to_s
        fcerr = shell_out("lsattr -El #{f[0]} -a fc_err_recov | awk '{print $2}'").stdout.chomp.to_s
        ruby_block "#{f[0]} tuning" do
          block do
            shell_out("chdev -l #{f[0]} -a dyntrk=yes -a fc_err_recov=fast_fail -P")
          end
          only_if { dyn != 'yes' || fcerr != 'fast_fail' }
        end
      end
    end
  end
end
