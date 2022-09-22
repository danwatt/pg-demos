clean:
	docker stop covid-act-now || true
	docker rm covid-act-now || true
	docker rmi covid-act-now || true
run: clean
	docker build -t covid-act-now .
	docker run -e POSTGRES_PASSWORD=password -p 5432:5432 --name covid-act-now covid-act-now