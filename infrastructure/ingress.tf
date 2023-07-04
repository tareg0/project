resource "kubernetes_ingress_v1" "wordpress_ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "wordpress-ingress"

    annotations = {
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:eu-central-1:780130876558:certificate/9ae4043e-bc7e-4eba-8b2e-b31ba6f09e8f"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"

      "alb.ingress.kubernetes.io/scheme" = "internet-facing"

      "alb.ingress.kubernetes.io/ssl-redirect" = "443"

      "alb.ingress.kubernetes.io/target-group-attributes" = "stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=60"

      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "wordpress.tromanovskiy.lol"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "wordpress"

              port {
                number = 80
              }
            }
          }
        }
      }
    }
    tls {
      hosts = ["wordpress.tromanovskiy.lol"]
    }
  }
  depends_on = [kubernetes_config_map.mariadb_configmap, 
  kubernetes_secret.mariadb_secret, 
  kubernetes_service.wordpress, 
  kubernetes_service.mariadb_service,
  kubernetes_deployment.wordpress_deployment, 
  helm_release.loadbalancer_controller, 
  kubernetes_stateful_set.mariadb_sts, 
  aws_iam_role_policy_attachment.lbc_iam_role_policy_attach, 
  aws_route_table_association.internet_access[0],
  aws_security_group_rule.nodes, 
  aws_security_group_rule.nodes_internal, 
  aws_security_group_rule.control_plane_outbound, 
  aws_security_group_rule.sg_egress_public, 
  aws_eks_node_group.this, 
  aws_eks_addon.csi_driver, 
  aws_security_group_rule.cluster_outbound, 
  aws_internet_gateway.this, 
  aws_eks_node_group.this,
  aws_nat_gateway.main,
  aws_iam_openid_connect_provider.eks, 
  aws_iam_role.eks_ebs_csi_driver,
  aws_eks_addon.csi_driver,
  aws_iam_role.lbc_iam_role,
  aws_security_group.data_plane_sg,
  aws_security_group.public_sg,
  aws_iam_policy.lbc_iam_policy, 
  aws_iam_role_policy_attachment.amazon_ebs_csi_driver, 
  aws_security_group_rule.cluster_inbound, 
  aws_security_group_rule.node_outbound, 
  aws_security_group_rule.sg_ingress_public_80, 
  aws_security_group_rule.sg_ingress_public_443, 
  aws_security_group_rule.nodes_inbound, 
  aws_route.main, 
  aws_security_group_rule.control_plane_inbound,  
  aws_security_group_rule.nodes_cluster_inbound]
}

