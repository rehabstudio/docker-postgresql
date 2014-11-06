help:
	@echo "run        - Run database container for local development."
	@echo "stop       - Stop and remove database container (data is not removed)."
	@echo ""
	@echo "backup     - Backup data volumes (logs, config, data)"
	@echo "restore    - Restore from backup (storage container must exist)."
	@echo ""
	@echo "psql       - run a postgresql shell against a running container."
	@echo "logs       - tail the running container's postgresql log"

build:
	docker build -t rehabstudio/postgresql .

create-storage-container:
	-docker run -t -i --name "postgresql-storage" rehabstudio/postgresql echo "Creating storage-only container."

run:
	docker run -t -i --rm -p 127.0.0.1:5432:5432 --volumes-from postgresql-storage --name postgresql-container rehabstudio/postgresql

stop:
	-docker stop postgresql-container
	-docker rm postgresql-container

backup:
	docker run --volumes-from postgresql-storage busybox tar zcfp /backup/backup.tar.gz /etc/postgresql /var/lib/postgresql /var/log/postgresql

restore:
	docker run --volumes-from postgresql-storage busybox tar zxfp /backup/backup.tar.gz

psql:
	docker run --rm -t -i --volumes-from postgresql-storage --link postgresql-container:pg rehabstudio/postgresql psql.sh

logs:
	docker logs -f postgresql-container
