clean:
	docker stop string-fks-demo
	docker rm string-fks-demo
	docker rmi string-fks-demo
run:
	docker build -t string-fks-demo .
	docker run -p 5432:5432 --name string-fks-demo string-fks-demo