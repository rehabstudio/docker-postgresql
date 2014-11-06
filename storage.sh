#!/bin/bash
set -e

# ensure history file exists on storage volume
touch /var/lib/postgresql/.psql_history
chown -R postgres:postgres /var/lib/postgresql/.psql_history

echo "Storage container bootstrapped."
