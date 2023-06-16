resource "kubernetes_config_map" "mariadb_configmap" {
  depends_on = [ aws_eks_cluster.this ]
  metadata {
    name = "mariadb-configmap"
  }

  data = {
    "primary.cnf" = "[mariadb]\nlog-bin                         # enable binary logging\nlog-basename=my-mariadb         # used to be independent of hostname changes (otherwise is in datadir/mysql)\n"

    "primary.sql" = "CREATE USER 'repluser'@'%' IDENTIFIED BY 'replsecret';\nGRANT REPLICATION REPLICA ON *.* TO 'repluser'@'%';\nCREATE DATABASE wordpress;\n"

    "replica.cnf" = "[mariadb]\nlog-basename=my-mariadb         # used to be independent of hostname changes (otherwise is in datadir/mysql)\n"

    "secondary.sql" = "# We have to know name of sts (`mariadb-sts`) and \n# service `mariadb-service` in advance as an FQDN.\n# No need to use master_port\nCHANGE MASTER TO \nMASTER_HOST='mariadb-sts-0.mariadb-service.default.svc.cluster.local',\nMASTER_USER='repluser',\nMASTER_PASSWORD='replsecret',\nMASTER_CONNECT_RETRY=10;\n"
  }
}

resource "kubernetes_secret" "mariadb_secret" {
  metadata {
    name = "mariadb-secret"
  }

  data = {
    mariadb-root-password = "secret"
  }

  type = "Opaque"
}

resource "kubernetes_service" "mariadb_service" {
  metadata {
    name = "mariadb-service"

    labels = {
      app = "mariadb"
    }
  }

  spec {
    port {
      name = "mariadb-port"
      port = 3306
    }

    selector = {
      app = "mariadb"
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_stateful_set" "mariadb_sts" {
  metadata {
    name = "mariadb-sts"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "mariadb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mariadb"
        }
      }

      spec {
        volume {
          name = "mariadb-config-map"

          config_map {
            name = "mariadb-configmap"
          }
        }

        volume {
          name      = "mariadb-config"
          empty_dir = {}
        }

        volume {
          name      = "initdb"
          empty_dir = {}
        }

        init_container {
          name    = "init-mariadb"
          image   = "mariadb"
          command = ["bash", "-c", "set -ex\necho 'Starting init-mariadb';\n# Check config map to directory that already exists \n# (but must be used as a volume for main container)\nls /mnt/config-map\n# Statefulset has sticky identity, number should be last\n[[ `hostname` =~ -([0-9]+)$ ]] || exit 1\nordinal=$${BASH_REMATCH[1]}\n# Copy appropriate conf.d files from config-map to \n# mariadb-config volume (emptyDir) depending on pod number\nif [[ $ordinal -eq 0 ]]; then\n  # This file holds SQL for connecting to primary\n  cp /mnt/config-map/primary.cnf /etc/mysql/conf.d/server-id.cnf\n  # Create the users needed for replication on primary on a volume\n  # initdb (emptyDir)\n  cp /mnt/config-map/primary.sql /docker-entrypoint-initdb.d\nelse\n  # This file holds SQL for connecting to secondary\n  cp /mnt/config-map/replica.cnf /etc/mysql/conf.d/server-id.cnf\n  # On replicas use secondary configuration on initdb volume\n  cp /mnt/config-map/secondary.sql /docker-entrypoint-initdb.d\nfi\n# Add an offset to avoid reserved server-id=0 value.\necho server-id=$((3000 + $ordinal)) >> etc/mysql/conf.d/server-id.cnf\nls /etc/mysql/conf.d/\ncat /etc/mysql/conf.d/server-id.cnf\n"]

          volume_mount {
            name       = "mariadb-config-map"
            mount_path = "/mnt/config-map"
          }

          volume_mount {
            name       = "mariadb-config"
            mount_path = "/etc/mysql/conf.d/"
          }

          volume_mount {
            name       = "initdb"
            mount_path = "/docker-entrypoint-initdb.d"
          }

          image_pull_policy = "Always"
        }

        container {
          name  = "mariadb"
          image = "mariadb"

          port {
            name           = "mariadb-port"
            container_port = 3306
          }

          env {
            name = "MARIADB_ROOT_PASSWORD"

            value_from {
              secret_key_ref {
                name = "mariadb-secret"
                key  = "mariadb-root-password"
              }
            }
          }

          env {
            name  = "MYSQL_INITDB_SKIP_TZINFO"
            value = "1"
          }

          volume_mount {
            name       = "datadir"
            mount_path = "/var/lib/mysql/"
          }

          volume_mount {
            name       = "mariadb-config"
            mount_path = "/etc/mysql/conf.d/"
          }

          volume_mount {
            name       = "initdb"
            mount_path = "/docker-entrypoint-initdb.d"
          }
        }

        restart_policy = "Always"
      }
    }

    volume_claim_template {
      metadata {
        name = "datadir"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }

    service_name = "mariadb-service"
  }
}

