Docker PostgreSQL Container
===========================

This repository contains a [PostgreSQL](http://www.postgresql.org/) (9.3) container that can be used for local development purposes. Note that this container should **NOT** be used in production as it is not configured to be as secure as it otherwise could be (to make local development simpler).


## Basic Usage

Provided you have docker installed, running your Postgres container is simple. This repository contains a `Makefile` that allows you to get up and running quickly with a single command:

First you'll need to create a storage-only volume for storing data (persists across restarts/rebuilds of the main container).

```bash
$ make create-storage-container
```

Once those complete successfully you should be ready to go:

```bash
$ make run
```

This command will build a docker container using the `Dockerfile` provided, start the container in the background, and restore from backup if an appropriately named archive is present in the repository's root (`backup.tar.gz`).

To stop and remove the container, run:

```bash
$ make stop
```

This command will stop the running container, back up Postgres' data to the host system in a tar.gz archive, and finally remove the container entirely. The container is only removed when the backup is succesful, so this command should be safe to run, even if you require persistent data across container rebuilds.


## Interacting with the running database

To open an SQL shell and connect to the running container (it will be started if necessary), simply run:

```shell
$ make psql
```

You can change the username and database used like so (the user and database need to have been created previously):

```shell
$ make psql user=someuser db=somedb
```

## Backup and Restore

Backing up your data is easy. Simply stop your running database container (with ctrl-c or `make stop`) and run:

```shell
$ make backup
```

This will create a `backup.tar.gz` file in the root of the repository which contains a full database backup. Restoring is similarly simple, again, you first need to stop your running container and issue the command:

```shell
$ make restore
```

If you now run your container you should see all data restored from backup.


## It's just Docker!

Whilst the most common actions are automated via the makefile, it's just a straightforward Docker container underneath and you can run all of your usual Docker commands if you wish.  For more information, please refer to the [official docker documentation](https://docs.docker.com/).
