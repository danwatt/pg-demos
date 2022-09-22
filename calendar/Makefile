image = calendar-pg-demo
clean:
	docker stop $(image) || true
	docker rm $(image) || true
	docker rmi $(image) || true
run: clean
	docker build -t $(image) .
	docker run -e POSTGRES_PASSWORD=password -p 5432:5432 --name $(image) $(image)