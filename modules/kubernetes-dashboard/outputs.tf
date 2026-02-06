output "kubernetes_dashboard_admin_user_token_base64" {
  value     = kubernetes_secret.kubernetes_dashboard_admin_user_token.data["token"]
  sensitive = true
}