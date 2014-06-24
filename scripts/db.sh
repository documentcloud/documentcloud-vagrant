# verify that postgres is loaded properly

test $USERNAME || { USERNAME=vagrant; }

test -e /etc/postgresql/9.3/main/pg_hba.conf || { echo "Can't find the PostgreSQL 9.3 Client Authentication Configuration File (/etc/postgresql/9.3/main/pg_hba.conf)" >&2; exit 1; }

cd /home/$USERNAME/documentcloud

# setup dummy postgres environment so that you can verify rails is working
cp config/server/files/postgres/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
/etc/init.d/postgresql reload

# verify that databases don't already exist

sudo -u postgres createuser -s $USERNAME
sudo -u postgres createuser -s documentcloud
test $DB_PASSWORD || DB_PASSWORD='documentcloudVirtualMachine'
echo "alter user documentcloud password '$DB_PASSWORD' " | sudo -u postgres psql

test $RAILS_ENV || { RAILS_ENV=development; }

# create dcloud_#{env} and dcloud_analytics_#{env}
sudo -u postgres createdb dcloud_$RAILS_ENV
sudo -u postgres createdb dcloud_analytics_$RAILS_ENV

# install hstore for dcloud_#{env}
echo "CREATE EXTENSION hstore;" | sudo -u postgres psql dcloud_$RAILS_ENV

# import development schema to dcloud_#{env} and analytics schema to dcloud_analytics_#{env}
#sudo -u postgres psql -f db/development_structure.sql dcloud_$RAILS_ENV 2>&1|grep ERROR
sudo -u postgres psql -f db/structure.sql dcloud_$RAILS_ENV 2>&1|grep ERROR
sudo -u postgres psql -f db/analytics_structure.sql dcloud_analytics_$RAILS_ENV 2>&1|grep ERROR

rake db:migrate
