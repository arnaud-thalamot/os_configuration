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

actions :create, :delete

property :name, String, required: true, name_attribute: true
property :fsname, String, required: false
property :lvname, String, required: false
property :fstype, String, required: false
property :vgname, String, required: false
property :size, Integer, required: false
attr_accessor :lvexist
attr_accessor :fsexist
attr_accessor :mountexist

def initialize(*args)
  super
  @action = :create
end
