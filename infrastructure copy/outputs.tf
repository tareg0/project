data "aws_availability_zones" "available" {
  state = "available"
}
output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "load_balancer_hostname" {
  value = kubernetes_service.wordpress.status.0.load_balancer.0.ingress.0.hostname
}