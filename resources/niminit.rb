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

property :nimserver, String, required: true
property :protocol, String, required: false, default: 'nimsh'
property :nimclient, String, required: true
property :adapter, String, required: true
property :force, [true, false], required: false, default: false

actions :configure

def initialize(*args)
  super
  @action = :configure
end
