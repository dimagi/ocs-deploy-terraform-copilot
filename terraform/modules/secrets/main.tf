data "aws_secretsmanager_random_password" "django_secret_key" {
  password_length = 50
}
