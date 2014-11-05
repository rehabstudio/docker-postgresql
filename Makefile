BACKUP_EXISTS = $(shell ls -1 | grep -c backup.tar.gz)
EXISTS = $(shell docker ps -a | grep -c postgresql-container)
RUNNING = $(shell docker ps | grep -c postgresql-container)

help:
	@echo "start - Run database container for local development and restore from backup (if present)"
	@echo "stop - Backup, stop and delete database container."
	@echo ""
	@echo "backup - backup this container's volumes (logs, config, data)"
	@echo "restore - restore backup onto a running container's volumes"
	@echo ""
	@echo "psql - run a postgresql shell against a running container."
	@echo "logs - tail the running container's postgresql log"

build:
	docker build -t="rehabstudio/postgresql-dev" .

start:
ifeq ($(RUNNING),1)
	@echo "Postgres container already running, try 'make restart' if you want to rebuild and restart it."
else ifeq ($(EXISTS),1)
	@echo "Stopped Postgres container found, starting..."
	docker start postgresql-container
else
	@echo "Postgres not found, starting new container..."
	$(MAKE) build
	docker run -P -d --name="postgresql-container" rehabstudio/postgresql-dev
	$(MAKE) restore
endif

stop:
ifeq ($(RUNNING),1)
	@echo "Stopping Postgres container."
	docker stop postgresql-container
endif
ifeq ($(EXISTS),1)
	$(MAKE) backup
	@echo "Removing container."
	docker rm postgresql-container
else
	@echo "Postgres container not found, nothing to stop."
endif

backup:
ifeq ($(EXISTS),1)
	@echo "Backing up container's volumes (logs, config, data)."
	docker run --volumes-from postgresql-container -v $(CURDIR):/backup ubuntu tar zcfp /backup/backup.tar.gz /etc/postgresql /var/lib/postgresql /var/log/postgresql
	chmod a+rw backup.tar.gz
else
	@echo "Postgres container not found, nothing to back up."
endif

restore:
ifeq ($(BACKUP_EXISTS),1)
	@echo "Restoring data from backup."
	docker stop postgresql-container
	docker run --volumes-from postgresql-container -v $(CURDIR):/backup ubuntu tar zxfp /backup/backup.tar.gz
	docker start postgresql-container
else
	@echo "Backup not found, nothing to restore."
endif

psql: start
	docker run --rm -t -i -v $(CURDIR)/scripts:/scripts --link postgresql-container:pg rehabstudio/postgresql-dev bash /scripts/psql.sh

logs:
ifeq ($(EXISTS),0)
	@echo "Postgres container not found, logs not available."
else
	docker logs -f postgresql-container
endif
