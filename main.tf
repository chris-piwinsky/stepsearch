data "template_file" "os_archive" {
  template = file("./files/osarchive.json")

  vars = {
    lambda_extract   = module.extract.lambda_arn
    lambda_transform = module.transform.lambda_arn
    lambda_load      = module.load.lambda_arn
  }
}


module "wrapper_layer" {
  source = "./wrapper_layer"
}

module "os_layer" {
  source = "./os_lambda_layer"
}

module "extract" {
  source             = "./lambda"
  lambda_name        = "lambda_extract"
  layers             = [module.os_layer.layer_arn, module.wrapper_layer.layer_arn]
  archive_file       = data.archive_file.extract
  ssm_parameter_name = var.ssm_parameter_name
  os_uri             = var.os_uri
  master_user        = var.os_master_user
}

module "transform" {
  source             = "./lambda"
  lambda_name        = "lambda_transform"
  layers             = [module.os_layer.layer_arn, module.wrapper_layer.layer_arn]
  archive_file       = data.archive_file.transform
  ssm_parameter_name = var.ssm_parameter_name
  os_uri             = var.os_uri
  master_user        = var.os_master_user
}

module "load" {
  source             = "./lambda"
  lambda_name        = "lambda_load"
  layers             = [module.os_layer.layer_arn, module.wrapper_layer.layer_arn]
  archive_file       = data.archive_file.load
  ssm_parameter_name = var.ssm_parameter_name
  os_uri             = var.os_uri
  master_user        = var.os_master_user
}

module "os_archive" {
  source                   = "./stepfunction"
  step_name                = "osarchive"
  step_function_definition = data.template_file.os_archive.rendered
}

