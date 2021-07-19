########################################################################################################################
#                                                                                                                      #
#                                  Attributes for osconfiguration Cookbook 					                           #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 09/08/2016                                                                                   #
#   Date Last Update    : 09/09/2016                                                                                   #
#   Version             : 1.0                                                                                          #
#   Author              : Arnaud Thalamot                                                                              #
#                                                                                                                      #
########################################################################################################################

# OS configuration cookbook execution status
node.default['os_configuration']['status'] = 'failure'
# OS configuragtion cookbook flag to know if domain has been added
node.default['os_configuration']['domain_added'] = false