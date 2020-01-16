output "Selenium-Grid" {
  value = "http://${kubernetes_service.selenium-hub-svc-external.load_balancer_ingress[0].ip}:4444/grid/console"
}