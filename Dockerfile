#
# Simple Dockerfile for running a Postgres server locally.
#
# This Dockerfile is derived from the example in the official Docker
# documentation at http://docs.docker.com/examples/postgresql_service/.
#
# NOTE: NEVER USE THIS CONTAINER IN A PRODUCTION ENVIRONMENT, IT'S NOT SECURE
#       TO DO SO.
#

FROM ubuntu:14.04
MAINTAINER patrick@rehabstudio.com

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Tell apt not to assume a TTY is available.
ENV DEBIAN_FRONTEND noninteractive

# Set PostgreSQL database name, user and password in the container
# environment so that they can be accessed from linked containers
ENV DB_NAME docker
ENV DB_USER docker
ENV DB_PASSWORD docker

# Update the Ubuntu and PostgreSQL repository indexes
RUN apt-get update

# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.3
RUN apt-get -y -q install python-software-properties software-properties-common
RUN apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

# Add psql script to the path and make it executable
ADD psql.sh /usr/local/bin/psql.sh
RUN chmod a+x /usr/local/bin/psql.sh

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role with password and then create a database owned by
# the new role.
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER $(echo $DB_USER) WITH SUPERUSER PASSWORD '$(echo $DB_PASSWORD)';" &&\
    createdb -O $(echo $DB_USER) $(echo $DB_NAME)

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
