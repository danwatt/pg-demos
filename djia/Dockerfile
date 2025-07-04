FROM postgres:17.5-alpine
ADD sql /docker-entrypoint-initdb.d
RUN mkdir /tmp/out
RUN chmod uga+w /tmp/out
CMD ["postgres"]