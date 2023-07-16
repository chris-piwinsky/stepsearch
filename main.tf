data "template_file" "os_archive" {
  template = file("./files/osarchive.json")

  vars = {
    lambda_extract   = module.extract.lambda_arn
    lambda_transform = module.transform.lambda_arn
    lambda_load      = module.load.lambda_arn
  }
}

module "ssm_parameter" {
  source = "./ssm"
}

module "wrapper_layer" {
  source = "./wrapper_layer"
}

module "os_layer" {
  source = "./os_lambda_layer"
}

module "efs_mount" {
  source         = "./efs"
  subnet_id      = local.subnet_ids
  security_group = [local.security_group]
}

locals {
  subnet_ids     = slice(data.aws_subnets.private.ids, 0, 2)
  security_group = "sg-03cd1c2ab903862cb"

  extract_vars = {
    SSM_PARAMETER  = var.ssm_parameter_name
    OS_URI         = var.os_uri
    MASTER_USER    = var.os_master_user
    NEO4J_PARAMS   = module.ssm_parameter.ssm_parameter_name
    EFS_MOUNT_PATH = module.efs_mount.mount_path
  }

  transform_vars = {
    SSM_PARAMETER  = var.ssm_parameter_name
    OS_URI         = var.os_uri
    MASTER_USER    = var.os_master_user
    NEO4J_PARAMS   = module.ssm_parameter.ssm_parameter_name
    EFS_MOUNT_PATH = module.efs_mount.mount_path
  }

  load_vars = {
    SSM_PARAMETER  = var.ssm_parameter_name
    OS_URI         = var.os_uri
    MASTER_USER    = var.os_master_user
    NEO4J_PARAMS   = module.ssm_parameter.ssm_parameter_name
    EFS_MOUNT_PATH = module.efs_mount.mount_path
  }
}
module "extract" {
  source                = "./lambda"
  lambda_name           = "lambda_extract"
  subnet_ids            = local.subnet_ids
  security_group_ids    = [local.security_group]
  layers                = [module.os_layer.layer_arn, module.wrapper_layer.layer_arn]
  archive_file          = data.archive_file.extract
  efs_access_point      = module.efs_mount.efs_access_point
  environment_variables = local.extract_vars
}

module "transform" {
  source                = "./lambda"
  lambda_name           = "lambda_transform"
  subnet_ids            = local.subnet_ids
  security_group_ids    = [local.security_group]
  layers                = [module.os_layer.layer_arn, module.wrapper_layer.layer_arn]
  archive_file          = data.archive_file.transform
  efs_access_point      = module.efs_mount.efs_access_point
  environment_variables = local.transform_vars
}

module "load" {
  source                = "./lambda"
  lambda_name           = "lambda_load"
  subnet_ids            = local.subnet_ids
  security_group_ids    = [local.security_group]
  layers                = [module.os_layer.layer_arn, module.wrapper_layer.layer_arn]
  archive_file          = data.archive_file.load
  efs_access_point      = module.efs_mount.efs_access_point
  environment_variables = local.load_vars
}

module "os_archive" {
  source                   = "./stepfunction"
  step_name                = "osarchive"
  step_function_definition = data.template_file.os_archive.rendered
}

