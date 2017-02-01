# docker-backstab 

Docker backstab uses consul-template to watch for defined template and restarts 
managed docker container under consul lock. This is not replacement for rolling 
updates but very useful if managed container depends on some other services.

## Dependencies

1. Docker
1. Running consul cluster

## Usage

`docker-backstab` was designed to use with orchestrator like Nomad or Docker 
Swarm and can be configured with next environment variables:
 
`BACKSTAB_CONSUL_ADDRESS` (127.0.0.1:8500) Address of Consul node. Usually 
based on is host local IPv4.

`BACKSTAB_CONSUL_LOCK` (backstab) Consul lock prefix.

`BACKSTAB_TRIGGER` ('Cg==') Base64-encoded consul template. `docker-backstab` 
reacts to template result changes. On start `docker-backstab` renders trigger 
template and then runs watch routine.

`BACKSTAB_WINDOW` (60s:120s) Wait window

`BACKSTAB_TIMEOUT` (10m) Restart command timeout.

`BACKSTAB_CONTAINER` (sibling) Managed container name or ID.

`BACKSTAB_COMMAND` (restart) Command to apply

`BACKSTAB_DELAY` (0) Delay after command apply.

### Docker health check

If managed container has internal healthcheck use `BACKSTAB_CHECK_*` to wait 
for container is healthy before release consul lock.

`BACKSTAB_CHECK_HEALTH` (false) Use "true" to activate.

`BACKSTAB_CHECK_RETRIES` (120) Retries before give up.

`BACKSTAB_CHECK_BACKOFF` (5) Time to sleep before each check.

## Example (Nomad)

> You need to provide Consul agent IP!

`nomad-config.hcl`:

    ...
    client {
      ...
      meta {
        private_ipv4 = "${COREOS_PRIVATE_IPV4}"
        ...
      }
      ...
    }

`backstab.hcl`:

    job "backstab" {
      datacenters = ["dc1"]
    
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
        }
      }
    }
