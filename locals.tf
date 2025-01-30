locals {
  virtual_network_details =(flatten([
    for virtualnetwork_key,virtualnetwork in var.environment :
    {
        virtual_network_name=virtualnetwork_key
        virtual_network_address_space=virtualnetwork.virtual_network_address_space
        resource_group_name=virtualnetwork.resource_group_name
        location=virtualnetwork.location
    }
  ]))

subnet_details =(flatten([
    for virtualnetwork_key,virtualnetwork in var.environment :[
for subnet_key,subnets in virtualnetwork.subnets :
    {
      subnet_name= subnet_key
        virtual_network_name=virtualnetwork_key
        subnet_address_prefix=subnets.subnet_address_prefix
        resource_group_name=virtualnetwork.resource_group_name
        location= virtualnetwork.location
    }]
    
  ]))

  network_security_group_details=(flatten([
    for virtualnetwork_key, virtualnetwork in var.environment :[
    for subnet_key, subnets in virtualnetwork.subnets :
    {
      virtual_network_name=virtualnetwork_key
      subnet_name=subnet_key
      resource_group_name=virtualnetwork.resource_group_name
       location= virtualnetwork.location
        network_security_group_rules=subnets.network_security_group_rules
    }]
    ]))
}

