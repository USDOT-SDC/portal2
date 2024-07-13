# # === Users ===
# resource "aws_dynamodb_table" "users" {
#   name         = "portal_users"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "username"

#   attribute {
#     name = "username"
#     type = "S"
#   }
# }

# resource "aws_dynamodb_table_item" "user_acme" {
#   table_name = aws_dynamodb_table.users.name
#   hash_key   = aws_dynamodb_table.users.hash_key

#   item = jsonencode(
#     {
#       "username" : {
#         "S" : "auser"
#       },
#       "name" : {
#         "S" : "Acme User"
#       },
#       "teams" : {
#         "L" : [
#           {
#             "S" : "acme-research-team"
#           }
#         ]
#       },
#       "instances" : {
#         "L" : [
#           {
#             "S" : "i-04f8d40a4006d240c"
#           },
#           {
#             "S" : "i-0e4102bcee6179f1e"
#           }
#         ]
#       }
#     }
#   )
# }

# # === Teams ===
# resource "aws_dynamodb_table" "teams" {
#   name         = "portal_teams"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "team_slug"

#   attribute {
#     name = "team_slug"
#     type = "S"
#   }
# }

# resource "aws_dynamodb_table_item" "team_acme" {
#   table_name = aws_dynamodb_table.teams.name
#   hash_key   = aws_dynamodb_table.teams.hash_key

#   item = jsonencode(
#     {
#       "team_slug" : {
#         "S" : "acme-research-team"
#       },
#       "team_name" : {
#         "S" : "Acme Research Team"
#       },
#       "upload_locations" : {
#         "L" : [
#           {
#             "S" : "${var.common.environment}.sdc.dot.gov.team.acme-research-team/uploads"
#           }
#         ]
#       },
#       "team_bucket" : {
#         "S" : "${var.common.environment}.sdc.dot.gov.team.acme-research-team"
#       }
#     }
#   )
# }

# # === Instances ===
# resource "aws_dynamodb_table" "instances" {
#   name         = "portal_instances"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "instance_id"

#   attribute {
#     name = "instance_id"
#     type = "S"
#   }
# }

# resource "aws_dynamodb_table_item" "instance_acme1" {
#   table_name = aws_dynamodb_table.instances.name
#   hash_key   = aws_dynamodb_table.instances.hash_key

#   item = jsonencode(
#     {
#       "instance_id" : {
#         "S" : "i-04f8d40a4006d240c"
#       },
#       "instance_data" : {
#         "M" : {
#           "name" : {
#             "S" : "ECS_WART01"
#           },
#           "description" : {
#             "S" : "Windows Workstation, Acme Research Team, Acme User"
#           },
#           "default_type" : {
#             "S" : "t3a.large"
#           },
#           "allow_type_change" : {
#             "BOOL" : true
#           }
#         }
#       }
#     }
#   )
# }

# resource "aws_dynamodb_table_item" "instance_acme2" {
#   table_name = aws_dynamodb_table.instances.name
#   hash_key   = aws_dynamodb_table.instances.hash_key

#   item = jsonencode(
#     {
#       "instance_id" : {
#         "S" : "i-0e4102bcee6179f1e"
#       },
#       "instance_data" : {
#         "M" : {
#           "name" : {
#             "S" : "ECS_WART02"
#           },
#           "description" : {
#             "S" : "Windows Workstation, Acme Research Team, Acme User"
#           },
#           "default_type" : {
#             "S" : "t3a.large"
#           },
#           "allow_type_change" : {
#             "BOOL" : true
#           }
#         }
#       }
#     }
#   )
# }
