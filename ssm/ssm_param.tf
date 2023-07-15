resource "aws_ssm_parameter" "neo4j_uri" {
  name        = "/Prod/Neo4j/uri"
  description = "neo4j password"
  type        = "SecureString"
  value       = "TESTSTRING"
}

resource "aws_ssm_parameter" "neo4j_username" {
  name        = "/Prod/Neo4j/username"
  description = "neo4j username"
  type        = "SecureString"
  value       = "TESTSTRING"
}

resource "aws_ssm_parameter" "neo4j_password" {
  name        = "/Prod/Neo4j/password"
  description = "neo4j password"
  type        = "SecureString"
  value       = "TESTSTRING"
}

output "ssm_parameter_name" {
  value = aws_ssm_parameter.neo4j_uri.id
}