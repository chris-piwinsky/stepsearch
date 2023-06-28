data "archive_file" "extract" {
  type        = "zip"
  source_dir  = "./files/extract"
  output_path = "./files/extract_function.zip"
}


data "archive_file" "transform" {
  type        = "zip"
  source_dir  = "./files/transform"
  output_path = "./files/transform_function.zip"
}

data "archive_file" "load" {
  type        = "zip"
  source_dir  = "./files/load"
  output_path = "./files/load_function.zip"
}