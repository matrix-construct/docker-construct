docker-construct
---

### Bootstrap

First we need to start a shell into the container to create a listener

```bash
$ docker run -it \
    -p 8448:8448 \
    -v `pwd`/data:/app/var/db \
    --name construct mujx/construct-dev:latest
```

```bash
$ /app/bin/construct <your_domain_name>

# CTRL-C to enter the construct console

# Follow the instructions from https://github.com/matrix-construct/construct to
# configure the server.

# e.g net listen matrix 0.0.0.0 8448 <your_domain_name>.crt <your_domain_name>.crt.key
```

### Start-up

Once the initial configuration is done we can start up the server as a normal
container.

```
$ docker run --rm -d \
    -e DOMAIN_NAME=<your_domain_name> \
    -p 8448:8448 \
    -v `pwd`/data:/app/var/db \
    --name construct mujx/construct-dev:latest
```
