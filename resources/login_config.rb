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

actions :apply

property :PASS_MAX_DAYS, Fixnum, required: true
property :PASS_MIN_LEN, Fixnum, required: true
property :UID_MIN, Fixnum, required: true
property :GID_MIN, Fixnum, required: true

def initialize(*args)
  super
  @action = :apply
end
