output "django_secret_key_id" {
  value         = aws_secretsmanager_secret.django_secret_key.id
}
