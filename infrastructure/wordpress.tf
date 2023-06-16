resource "kubernetes_service" "wordpress" {
  depends_on = [ kubernetes_stateful_set.mariadb_sts ]
  metadata {
    name = "wordpress"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
      node_port   = 31000
    }

    selector = {
      app = "wordpress"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "wordpress_deployment" {
  metadata {
    name = "wordpress-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "wordpress"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = "wordpress:latest"

          port {
            container_port = 80
          }

          env {
            name  = "WORDPRESS_DB_HOST"
            value = "mariadb-sts-0.mariadb-service"
          }

          env {
            name = "WORDPRESS_DB_PASSWORD"

            value_from {
              secret_key_ref {
                name = "mariadb-secret"
                key  = "mariadb-root-password"
              }
            }
          }

          env {
            name  = "WORDPRESS_DB_USER"
            value = "root"
          }

          env {
            name  = "WORDPRESS_DEBUG"
            value = "1"
          }
        }
      }
    }
  }
}

