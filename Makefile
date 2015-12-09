up:
	docker-compose up

build:
	docker-compose build

clean:
	docker-compose rm -f

reload: clean build up
