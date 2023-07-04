data "aws_route53_zone" "my_zone" {
  name = "tromanovskiy.lol"
}

data "aws_elb_hosted_zone_id" "zone_of_application_ingress" {
    depends_on = [kubernetes_ingress_v1.wordpress_ingress]
}

resource "aws_route53_record" "record_wordpress_tromanovskiy_lol" {
depends_on = [kubernetes_ingress_v1.wordpress_ingress]
  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = "wordpress.tromanovskiy.lol"
  type    = "A"

  alias {
    name                   = kubernetes_ingress_v1.wordpress_ingress.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.zone_of_application_ingress.id
    evaluate_target_health = true
  }
}