locals {
  layer_name        = "lambda_cognito_layer"
  description       = "Lambda layer that includes all the packages needed to link accounts in the web portal"
  source_dir        = "backend\\lambda_cognito_layer\\src"
  site_packages_dir = "${local.source_dir}\\python\\lib\\python3.13\\site-packages"
  exclude_venv      = fileset("${path.module}/src/", ".venv/**/*")
  exclude_pycache   = fileset("${path.module}/src/", "**/__pycache__/**/*")
  exclude_dist_info = fileset("${path.module}/src/", "**/*.dist-info/**/*")
  excludes = setunion(
    local.exclude_venv,
    local.exclude_pycache,
    local.exclude_dist_info,
    [
      ".gitignore",
    ]
  )
}

resource "terraform_data" "pip_install" {
  # Use this trigger if you need pip to run with EVERY terraform apply
  # triggers_replace = timestamp()
  # Use this trigger if you want pip to run only when requirements are changed 
  #   note: Change some of the whitespace in requirements.txt to trigger one time
  triggers_replace = filesha256("${path.module}/requirements.txt")

  provisioner "local-exec" {
    # This is so the archive_file will build on the first tf apply after cloning (source_dir doesn't exist yet)
    command = "if not exist ${local.source_dir} mkdir ${local.source_dir} & echo I'm so dumb > .gitkeep"
  }

  provisioner "local-exec" {
    command = "if exist ${local.source_dir}\\python\\ rmdir ${local.source_dir}\\python /S /Q"
  }

  provisioner "local-exec" {
    command = "pip install --platform manylinux2014_x86_64 --only-binary=:all: --no-binary=:none: --implementation cp --python-version 3.12 --upgrade -t ${local.site_packages_dir} -r ${path.module}\\requirements.txt"
  }
}

data "archive_file" "deployment_package" {
  type        = "zip"
  output_path = "${path.module}/deployment/package.zip"
  source_dir  = local.source_dir
  excludes    = local.excludes
  depends_on  = [terraform_data.pip_install]
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
  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64"]
}
