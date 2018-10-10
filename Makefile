
build:
	docker build -t construct-dev .

run:
	docker run --rm -e DOMAIN_NAME=local.io -p 8448:8448 --name construct construct-dev
