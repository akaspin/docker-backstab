job "backstab" {
  datacenters = ["testing"]

  update {
    stagger = "10s"
    max_parallel = 1
  }

  constraint {
    operator  = "distinct_hosts"
    value     = "true"
  }
  
  group "servers" {
    count = 3

    restart {
      attempts = 100
      delay = "30s"
      mode = "delay"
    }

    constraint {
      attribute = "${meta.groups}"
      set_contains = "any"
    }

    task "killer" {
      driver = "docker"
      env {
        // Both tasks runs in same allocation
        BACKSTAB_CONTAINER = "managed-${NOMAD_ALLOC_ID}"
        // Trigger: '{{ key "backstab-test" }}'
        BACKSTAB_TRIGGER = "'e3sga2V5ICJiYWNrc3RhYi10ZXN0IiB9fQo='"
        BACKSTAB_CONSUL_ADDRESS = "${meta.private_ipv4}"
      }
      config {
        image = "index.docker.io/akaspin/docker-backstab:latest"
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ]
      }
      resources {
        cpu    = 256
        memory = 512
        network {
          mbits = 1
        }
      }
    }
    
    task "managed" {
      driver = "docker"
      config {
        image = "library/alpine"
        command = "/bin/sh"
        args = [
          "-c",
          "echo start; ping -q google.com"
        ]
      }
      resources {
        cpu    = 256
        memory = 512
        network {
          mbits = 1
        }
      }
    }
  }
}
