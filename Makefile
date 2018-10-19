
build:
	docker build -t construct-dev .

run:
	docker run --rm -d \
		-e DOMAIN_NAME=local.io \
		-p 8448:8448 \
		-v `pwd`/data:/app/var/ \
		--name construct construct-dev

shell:
	docker run -it \
		-p 8448:8448 \
		-v `pwd`/data:/app/var \
		construct-dev /bin/bash

stop:
	docker stop construct

push:
	docker tag construct-dev mujx/construct-dev:latest
	docker push mujx/construct-dev:latest
