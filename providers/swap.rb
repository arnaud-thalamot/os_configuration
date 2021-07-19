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

      Chef::Log.info('Configuring Swap of #{resource.size}GB.............')
      resource = @new_resource

      # Creates a new partition of given size on first disk and turn in into a swap partition
      # fdisk = shell_out("(echo n; echo p; echo ; echo ; echo +#{resource.size}G; echo w) | fdisk /dev/sda").stdout.chop

      execute 'fstab-fdisk' do
        command '(echo n; echo p; echo ; echo ; echo ; echo w) | fdisk /dev/sda'
        returns [0, 1]
        action :run
        not_if { shell_out('fdisk -l /dev/sda | grep /dev/sda3').stdout.chop != '' }
      end

      execute 'fstab-partprobe' do
        command 'partprobe'
        returns [0, 1]
        action :run
        not_if { shell_out('cat /proc/swaps | grep /dev/sda3').stdout.chop != '' }
      end

      execute 'fstab-vgextend' do
        command 'vgextend rootvg /dev/sda3'
        action :run
        not_if { shell_out('pvscan | grep /dev/sda3').stdout.chop != '' }
      end

      execute 'fstab-lvcreate' do
        command "lvcreate rootvg -n lvswap -L #{resource.size}G"
        action :run
        not_if { shell_out('lvs | grep lvswap').stdout.chop != '' }
      end

      execute 'fstab-mkswap' do
        command 'mkswap /dev/rootvg/lvswap'
        returns [0, 1]
        action :run
        not_if { shell_out('cat /etc/fstab |grep /dev/rootvg/lvswap').stdout.chop != '' }
      end

      execute 'fstab-lvswap' do
        command 'echo "/dev/rootvg/lvswap swap swap defaults 0 0" >> /etc/fstab'
        action :run
        not_if { shell_out('cat /etc/fstab |grep /dev/rootvg/lvswap').stdout.chop != '' }
      end

      execute 'fstab-swapon' do
        command 'swapon -va'
        action :run
        not_if { shell_out('cat /proc/swaps | grep /dev/sda3').stdout.chop != '' }
      end
    end
  end
end
