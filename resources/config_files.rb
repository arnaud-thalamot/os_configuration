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

actions :configure

property :filename, String, required: true
property :separator, String, required: true
property :parameter, String, required: true
property :value, String, required: true
property :daemon, String, required: true
property :method, String, required: true

def initialize(*args)
  super
  @action = :configure
end
