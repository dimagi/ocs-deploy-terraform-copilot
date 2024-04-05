data "aws_secretsmanager_random_password" "django_secret_key" {
  password_length = 50
}

resource "aws_secretsmanager_secret" "django_secret_key" {
  name                    = "${var.application_name}-${var.environment}_django_secret_key"
  description             = "Django Secret Key"
}

resource "aws_secretsmanager_secret_version" "django_secret_key" {
  secret_id     = aws_secretsmanager_secret.django_secret_key.id
  secret_string = data.aws_secretsmanager_random_password.django_secret_key.random_password
}
