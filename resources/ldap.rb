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

property :sslkeypath, String, required: false
property :sslkeypwd, String, required: false
property :servers, String, required: false
property :basedn, String, required: false
property :binddn, String, required: false
property :pwd, String, required: false
property :port, String, required: false
property :heartbeatinterval, String, required: false
property :cachetimeout, String, required: false
property :certdir, String, required: false
property :certificates, Array, required: false

def initialize(*args)
  super
  @action = :configure
end
