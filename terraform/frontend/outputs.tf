output "s3" {
  value = {
    objects_deployed = [
      for key, interface_build in aws_s3_object.interface_build : key
    ]
  }
}
