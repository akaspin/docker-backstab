# docker-backstab 

Docker backstab uses consul-template to watch for defined template and restarts 
managed docker container under consul lock. This is not replacement for rolling 
updates but very useful if managed container depends on some other services.

## Dependencies

1. Docker
1. Running consul cluster


