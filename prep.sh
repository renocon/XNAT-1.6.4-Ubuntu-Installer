echo "Beginning XNAT setup. Everything will be installed into ~/xnat-install."
echo "This script will install apache tomcat7, oracle jdk7, postgresql 9.4.4 and xnat"
echo "Press ctrl+c to quit at any time."


echo "Initializing Directories..."
loc="$PWD";
echo $loc

cd ~;
mkdir xnat_install
cd xnat_install


echo "Concatenating xnat archive"
cat $loc/xnat-1.6.4.zip* > xnat-1.6.4.zip;

echo "unzipping xnat"
unzip xnat-1.6.4.zip;
rm xnat-1.6.4.zip;
cp xnat-1.6.4 xnat;
rm x-R xnat-1.6.4;

echo "preparing maven cache";
unzip $loc/xnat-maven.zip ~/.maven;	



if test "$JAVA_HOME" != $PWD/jdk
then 
	echo 'building jdk7 archive';
	cat $loc/jdk-7u79-linux-x64.gz* > jdk-7u79-linux-x64.tar.gz;
	echo "unzipping oracle jdk"
	tar -xzf jdk-7u79-linux-x64.tar.gz;
	rm jdk-7u79-linux-x64.tar.gz;
	cp jdk-7u79-linux-x64 jdk;
	rm -R jdk-7u79-linux-x64;
	
	echo "export JAVA_HOME=$PWD/jdk" >> ~/.bashrc;
	echo "export PATH=$PATH:$JAVA_HOME/bin";
	export JAVA_HOME=$PWD/jdk;
	export PATH=$PATH:$JAVA_HOME/bin;
	update-alternatives --install "/usr/bin/java" "java" "$JAVA_HOME/bin/java" 1;
	update-alternatives --install "/usr/bin/javac" "javac" "$JAVA_HOME/bin/javac" 1;
	update-alternatives --config java;
	update-alternatives --config javac;
	
fi

if test "$XNAT_HOME" != $PWD/xnat
then 
	echo "export XNAT_HOME=$PWD/xnat" >> ~/.bashrc;
	echo "export PATH=$PATH:$XNAT_HOME/bin" >> ~/.bashrc;
	export XNAT_HOME=$PWD/xnat;
	export PATH=$PATH:$XNAT_HOME/bin;
fi

if test "$CATALINA_HOME" != $PWD/tc7
then 
	echo "unzipping tomcat 7"
	unzip $loc/apache-tomcat-7.0.63.zip ./tc7;
	echo "export CATALINA_HOME=$PWD/tc7" >> ~/.bashrc;
	export CATALINA_HOME=$PWD/tc7
fi




#replace hba_conf

if test "$POSTGRES_HOME" != $PWD/pg944
then 
	echo "installing postgresql 9.4.4";	
	tar -xzf $loc/postgresql-9.4.4-3-linux-x64-binaries.tar.gz;
	cp -R $loc/postgresql-9.4.4-3-linux-x64-binaries $PWD/pg944;
	rm -R $loc/postgresql-9.4.4-3-linux-x64-binaries;
	echo "export POSTGRES_HOME=$PWD/pg944" >> ~/.bashrc;
	echo "export PATH=$PATH:$POSTGRES_HOME/bin" >> ~/.bashrc;
	export POSTGRES_HOME=$PWD/pg944;
	export PATH=$PATH:$POSTGRES_HOME/bin;
	mkdir $PWD/pg944/data;
	echo "export PGDATA=$PWD/pg944/data" >> ~/.bashrc;
	export PGDATA=$PWD/pg944/data;
	pg_ctl initdb;
	rm $PGDATA/pg_hba.conf;
	cp $loc/pgconf/main/pg_hba.conf $PGDATA/pg_hba.conf;

	rm $PGDATA/postgresql.conf;
	cp $loc/pgconf/main/pg_hba.conf $PGDATA/postgresql.conf;
	sed -i 's/PG_DATA_PLACE/new/$PGDATA' $PGDATA/postgresql.conf;
	#pg_ctl start;
fi

pg_ctl start

echo "Preparing database credentials.";
echo "Enter XNAT database username: ";
read dbuser;
createuser -U postgres -S -D -R -P $dbuser;

echo "Enter XNAT database name: ";
read dbname;
createdb -U postgres -O $dbuser $dbname;

rm build.properties;
touch build.properties;
echo "Preparing build.properties";
echo "#xnat build properties generated from script" >> build.properties;
echo "maven.appserver.home = $PWD/tc7" >> build.properties;
echo "xdat.project.name=ROOT" >> build.properties;


echo "xdat.project.db.name=$dbname" >> build.properties;
echo "xdat.project.db.driver=org.postgresql.Driver" >> build.properties;
echo "xdat.project.db.connection.string=jdbc:postgresql://localhost:5432/$dbname" >> build.properties;


echo "xdat.project.db.user=$dbuser" >> build.properties;


echo "Enter XNAT database password: ";
read dbpw;
echo "xdat.project.db.password=$dbpw" >> build.properties;

echo "xdat.archive.location=$PWD/data/archive" >> build.properties;
echo "xdat.prearchive.location=$PWD/data/prearchive" >> build.properties;
echo "xdat.cache.location=$PWD/data/cache" >> build.properties;
echo "xdat.ftp.location=$PWD/data/ftp" >> build.properties;
echo "xdat.build.location=$PWD/data/build" >> build.properties;
echo "xdat.pipeline.location=$PWD/data/pipeline" >> build.properties;
echo "xdat.mail.server=mail.server" >> build.properties;
echo "xdat.mail.port=25" >> build.properties;
echo "xdat.mail.server=smtp" >> build.properties;

echo "xdat.mail.username=" >> build.properties;
echo "xdat.mail.password=" >> build.properties;
echo "xdat.mail.admin=administrator@xnat.org" >> build.properties;
echo "xdat.mail.prefix=XNAT" >> build.properties;

echo "Where will XNAT be hosted? (eg. http://myxnat.com or http://localhost) Do not put the port as it will appended automatically."
read url;
echo "xdat.url=$url:8080" >> build.properties;
echo "xdat.require_login=true" >> build.properties;
echo "xdat.enable_new_registrations=false" >> build.properties;
echo "xdat.security.channel=any" >> build.properties;
echo "xdat.enable_csrf_token=true" >> build.properties;

cp build.properties ./xnat/build.properties;


echo "Setting up xnat: expected fail";
cd xnat;
./bin/setup.sh;
rm -R ./deployments/ROOT;

cp -R ~/.maven/repository $PWD/plugin-resources/repository;
echo "Setting up xnat: expected success";
./bin/setup.sh -Ddeploy=true;

echo "Populating Database Schema";
cd deployments/ROOT
psql -d $dbname -f sql/ROOT.sql -U $dbuser;

echo "Creating default user admin";
StoreXML -l security/security.xml -allowDataDeletion true;
StoreXML -dir ./work/field_groups -u admin -p admin -allowDataDeletion true;


echo "enabling tomcat ports in firewall"
ufw allow 8080

echo "starting tomcat"
$CATALINA_HOME/bin/startup.sh;