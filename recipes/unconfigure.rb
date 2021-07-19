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


# Domain
domain_integration = 'CLIENT.COM'
username_integration = 'username'
password_integration = 'password'

# Unjoining Domain
os_configuration_domain 'join_domain' do
  action [:unjoin]
  domain domain_integration
  username username_integration
  password password_integration
end
