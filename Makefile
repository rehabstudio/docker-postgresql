help:
	@echo "run        - Run database container for local development."
	@echo "stop       - Stop and remove database container (data is not removed)."
	@echo ""
	@echo "backup     - Backup data volumes (logs, config, data)"
	@echo "restore    - Restore from backup (storage container must exist)."
	@echo ""
	@echo "psql       - run a postgresql shell against a running container."
	@echo "             The following arguments can be passed to this target:"
	@echo "             user=myusername; username used to connect to database"
	@echo "             db=mydb;         name of database to connect to"

create-storage-container:
	-docker run -t -i --name "postgresql-storage" postgres:9.3 echo "Creating storage-only container."

run:
	docker run -t -i --rm --volumes-from postgresql-storage --name postgresql-container postgres:9.3

stop:
	-docker stop postgresql-container
	-docker rm postgresql-container

backup:
	docker run -v $(CURDIR):/backup --volumes-from postgresql-storage ubuntu tar zcfp /backup/backup.tar.gz /var/lib/postgresql/data

restore:
	docker run -v $(CURDIR):/backup --volumes-from postgresql-storage ubuntu tar zxfp /backup/backup.tar.gz

# default args for psql
user = postgres
db = postgres
psql:
	docker exec -t -i postgresql-container psql -U $(user) -d $(db)
