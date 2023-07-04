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

output "OIDC_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "OIDC_provider_url" {
value = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}"
}


output "Ingress-URL-output" {
  depends_on = [kubernetes_ingress_v1.wordpress_ingress]
value = kubernetes_ingress_v1.wordpress_ingress.status.0.load_balancer.0.ingress.0.hostname
}