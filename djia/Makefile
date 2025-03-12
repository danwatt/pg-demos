image = djia
clean:
	docker stop $(image) || true
	docker rm $(image) || true
	docker rmi $(image) || true
serve: clean
	docker build -t $(image) .
	docker run -e POSTGRES_PASSWORD=password -p 5432:5432 --volume ./plots/data/:/tmp/out/ --name $(image) $(image)
run: clean
	docker build -t $(image) .
	docker run -d -e POSTGRES_PASSWORD=password -p 5432:5432 --volume ./plots/data/:/tmp/out/ --name $(image) $(image)
