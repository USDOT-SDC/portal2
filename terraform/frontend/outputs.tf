output "s3" {
  value = {
    deployed_objects = [
      for key, interface_build in aws_s3_object.interface_build : key
    ]
  }
}
