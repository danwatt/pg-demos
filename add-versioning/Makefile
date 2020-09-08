clean:
	docker stop add-versioning
	docker rm add-versioning
	docker rmi add-versioning
run: clean
	docker build -t add-versioning .
	docker run -e POSTGRES_PASSWORD=password -p 5432:5432 --name add-versioning add-versioning