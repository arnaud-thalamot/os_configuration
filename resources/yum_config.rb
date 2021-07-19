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

actions :config

property :cachedir, String, required: true
property :keepcache, Fixnum, required: true
property :debuglevel, Fixnum, required: true
property :logfile, String, required: true
property :distroverpkg, String, required: true
property :tolerant, Fixnum, required: true
property :exactarch, Fixnum, required: true
property :obsoletes, Fixnum, required: true
property :gpgcheck, Fixnum, required: true
property :plugins, Fixnum, required: true
property :exclude, String, required: true
property :tsflags, String, required: true
property :metadata_expire, String, required: true

def initialize(*args)
  super
  @action = :config
end
