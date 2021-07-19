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

action :create do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
    else
      Chef::Log.info('ISM Tools Disk .............')

      ruby_block 'create-ism-disk' do
        block do
          # Creates a new partition on second physical disk, then create an lvm taking all space
          # Purpose is to hold IBM ISM Tools files on a separate disk
          pvcreate = shell_out('pvcreate /dev/sdb').stdout.chop
          vgcreate = shell_out('vgcreate vgismtools /dev/sdb').stdout.chop
          lvcreate = shell_out('lvcreate -l 100%FREE -n lvismtools vgismtools').stdout.chop
          mkfs = shell_out('mke2fs -t ext4 /dev/mapper/vgismtools-lvismtools').stdout.chop
          Chef::Log.debug("pvcreate : #{pvcreate}")
          Chef::Log.debug("vgcreate : #{vgcreate}")
          Chef::Log.debug("lvcreate : #{lvcreate}")
          Chef::Log.debug("mkfs : #{mkfs}")
        end
        action :create
        not_if { shell_out('lvs | grep lvismtools').stdout.chop != '' }
      end
    end
  end
end
