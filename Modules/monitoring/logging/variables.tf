variable "log_analytics_workspaces" {
     type = map(object({
       location = string
       resource_group_name=string
     }))
   }