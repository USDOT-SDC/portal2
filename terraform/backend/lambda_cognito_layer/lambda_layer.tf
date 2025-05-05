locals {
  layer_name      = "lambda_cognito_layer"
  description     = "Lambda layer that includes all the packages needed to link accounts in the web portal"
  runtime_name    = "python"
  runtime_version = "3.13"
  runtime         = "${local.runtime_name}${local.runtime_version}"
  src_path        = "backend\\lambda_cognito_layer\\src"
  packages_path   = "${local.src_path}\\python\\lib\\${local.runtime}\\site-packages"
  last_rotation   = var.common.time.rotating.hours.12
  mark_path       = "${local.packages_path}\\.mark"
}

resource "terraform_data" "pip_install" {
  triggers_replace = {
    # Change whitespace in requirements.txt or delete site packages dir to trigger one time
    requirements = filesha256("${path.module}/requirements.txt")
    # If site packages does not exist, ensures it's built before trying to zip non-existent path
    mark_file_exists = fileexists(local.mark_path)
    # Ensures site packages are rebuilt and upgraded often
    last_rotation = local.last_rotation
  }

  provisioner "local-exec" {
    command = "if exist ${local.src_path}\\python\\ rmdir ${local.src_path}\\python /S /Q"
  }

  provisioner "local-exec" {
    command = "if not exist ${local.packages_path} mkdir ${local.packages_path} & echo ${timestamp()} > ${local.mark_path}"
  }

  provisioner "local-exec" {
    command = "pip install --platform manylinux2014_x86_64 --only-binary=:all: --no-binary=:none: --implementation cp --python-version ${local.runtime_version} --upgrade -t ${local.packages_path} -r ${path.module}\\requirements.txt"
  }
}

data "archive_file" "deployment_package" {
  type        = "zip"
  source_dir  = local.src_path
  output_path = "${path.module}/deployment/package.zip"
  excludes = setunion(
    fileset("${path.module}/src/", ".venv/**/*"),
    fileset("${path.module}/src/", "**/__pycache__/**/*"),
    fileset("${path.module}/src/", "**/*.dist-info/**/*"),
    fileset("${path.module}/src/", "**/.mark"),
  )
  depends_on = [terraform_data.pip_install]
}

resource "aws_s3_object" "deployment_package" {
  bucket      = var.common.terraform_bucket.bucket
  key         = "portal/deployment_packages/lambda_cognito_layer.zip"
  source      = data.archive_file.deployment_package.output_path
  source_hash = data.archive_file.deployment_package.output_base64sha256
  depends_on  = [data.archive_file.deployment_package]
  override_provider {
    default_tags {
      tags = {}
    }
  }
}

resource "aws_lambda_layer_version" "lambda_cognito_layer" {
  layer_name               = local.layer_name
  description              = local.description
  s3_bucket                = aws_s3_object.deployment_package.bucket
  s3_key                   = aws_s3_object.deployment_package.key
  s3_object_version        = aws_s3_object.deployment_package.version_id
  compatible_runtimes      = [local.runtime]
  compatible_architectures = ["x86_64"]
}
