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

actions :install, :uninstall

property :name, String, required: true, name_attribute: true
property :fileset, String, required: false
property :options, String, required: false
property :location, String, required: false
attr_accessor :installed

def initialize(*args)
  super
  @action = :install
end
