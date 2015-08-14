#!/bin/bash
# My XNAT 1.6.4 Ubuntu Installer

clear


echo "Beginning XNAT setup. Everything will be installed into ~/xnat-install."
echo "This script will install apache tomcat7, oracle jdk7, postgresql 9.4.4 and xnat"
echo "Press ctrl+c to quit at any time."

echo "Preparing database credentials."
echo "Enter XNAT database username: "
#read dbuser;
export dbuser=xnat01

echo "Enter XNAT database name: "
#read dbname;
export dbname=xnat

echo "Enter XNAT database password: "
#read dbpw;
export dbpw=xnat

echo "Enter XNAT database port: "
#read dbpw;
export port=5432

echo "Where will XNAT be hosted? (eg. http://myxnat.com or http://localhost) Do not put the port as it will appended automatically."
#read url;
export url=http://localhost

echo "Initializing Directories..."
loc="$PWD"
echo $loc
cd ~
touch ~/.bashrc
mkdir xnat_install
sudo chmod 777 xnat_install
cd xnat_install
sudo chmod -R 777 ~/.maven
echo "preparing maven cache"
sudo chmod -R 777 ~/.maven
#rm -R ~/.maven
unzip $loc/xnat-maven.zip -d ~/	



if [ ! -d $PWD/jdk ]; 
then 
	echo 'building jdk7 archive'
	cat $loc/jdk-7u79-linux-x64.gz* > jdk-7u79-linux-x64.tar.gz
	echo "unzipping oracle jdk"
	tar -xzf jdk-7u79-linux-x64.tar.gz
	rm jdk-7u79-linux-x64.tar.gz
	cp -R jdk1.7.0_79 jdk
	sudo chmod -R 777 jdk
	sudo sudo chmod -R 777 jdk1.7.0_79
	sudo rm -R jdk1.7.0_79
	
	echo "export JAVA_HOME=$PWD/jdk" >> ~/.bashrc
	echo "export PATH=$PATH:$JAVA_HOME/bin" >> ~/.bashrc
	export JAVA_HOME=$PWD/jdk
	export PATH=$PATH:$JAVA_HOME/bin
	sudo touch /usr/bin/java;
	sudo touch /usr/bin/javac;
	sudo update-alternatives --install "/usr/bin/java" "java" "$JAVA_HOME/bin/java" 1
	sudo update-alternatives --install "/usr/bin/javac" "javac" "$JAVA_HOME/bin/javac" 1
	sudo update-alternatives --config java
	sudo update-alternatives --config javac
	
fi

if [ ! -d $PWD/xnat ]; 
then 
	echo "Concatenating xnat archive"
	cat $loc/xnat-1.6.4.zip* > xnat-1.6.4.zip

	echo "unzipping xnat"
	unzip xnat-1.6.4.zip
	rm xnat-1.6.4.zip
	cp -R xnat-1.6.4 xnat
	sudo chmod -R 777 xnat
	rm -R xnat-1.6.4
	sudo echo "export XNAT_HOME=$PWD/xnat" >> ~/.bashrc
	sudo echo "export PATH=$PATH:$XNAT_HOME/bin" >> ~/.bashrc
	export XNAT_HOME=$PWD/xnat
	export PATH=$PATH:$XNAT_HOME/bin
fi

if [ ! -d $PWD/tc7 ]; 
then 
	echo "unzipping tomcat 7"
	unzip $loc/apache-tomcat-7.0.63.zip -d ./
	cp -R apache-tomcat-7.0.63 tc7
	sudo chmod -R 777 tc7
	rm -R apache-tomcat-7.0.63
	sudo rm -R ./tc7/webapps/*
	echo "export CATALINA_HOME=$PWD/tc7" >> ~/.bashrc
	export CATALINA_HOME=$PWD/tc7
fi


if [! -f /usr/bin/psql];
then
	sudo apt-get install postgres postgres-contrib pgadmin3


fi
#replace hba_conf

#if test "$POSTGRES_HOME" != $PWD/pg944
#then 
#	echo "installing postgresql 9.4.4";	
#	tar -xzf $loc/postgresql-9.4.4-3-linux-x64-binaries.tar.gz;
#	cp -R pgsql pg944;
#	sudo chmod -R 777 pgsql;
#	rm -R pgsql;
#	echo "export POSTGRES_HOME=$PWD/pg944" >> ~/.bashrc;
#	echo "export PATH=$PATH:$POSTGRES_HOME/bin" >> ~/.bashrc;
#	export POSTGRES_HOME=$PWD/pg944;
#	export PATH=$PATH:$POSTGRES_HOME/bin;
#	mkdir $PWD/pg944/data;
#	echo "export PGDATA=$PWD/pg944/data" >> ~/.bashrc;
#	export PGDATA=$PWD/pg944/data;
#	pg_ctl initdb;
#	rm $PGDATA/pg_hba.conf;
#	cp $loc/pgconf/main/pg_hba.conf $PGDATA/pg_hba.conf;

#	rm $PGDATA/postgresql.conf;
#	cp $loc/pgconf/main/postgresql.conf $PGDATA/postgresql.conf;


#	javac $loc/PgRep.java;
#	sudo chmod 777 $loc/PgRep.class;
#	cp $loc/PgRep.class ./PgRep.class;
#	java PgRep;
#	rm PgRep.class;

#fi

#pg_ctl start
#sudo -i -u postgres
#createuser -U postgres -S -D -R -P $dbuser
#createdb -U postgres -O $dbuser $dbname



#exit

rm build.properties
touch build.properties
echo "Preparing build.properties"
echo "#xnat build properties generated from script" >> build.properties
echo "maven.appserver.home = $PWD/tc7" >> build.properties
echo "xdat.project.name=xnat" >> build.properties


echo "xdat.project.db.name=$dbname" >> build.properties
echo "xdat.project.db.driver=org.postgresql.Driver" >> build.properties
echo "xdat.project.db.connection.string=jdbc:postgresql://localhost:$port/$dbname" >> build.properties


echo "xdat.project.db.user=$dbuser" >> build.properties



echo "xdat.project.db.password=$dbpw" >> build.properties

echo "xdat.archive.location=$PWD/data/archive" >> build.properties
echo "xdat.prearchive.location=$PWD/data/prearchive" >> build.properties
echo "xdat.cache.location=$PWD/data/cache" >> build.properties
echo "xdat.ftp.location=$PWD/data/ftp" >> build.properties
echo "xdat.build.location=$PWD/data/build" >> build.properties
echo "xdat.pipeline.location=$PWD/data/pipeline" >> build.properties
echo "xdat.mail.server=mail.server" >> build.properties
echo "xdat.mail.port=25" >> build.properties
echo "xdat.mail.protocol=smtp" >> build.properties



echo "xdat.mail.username=" >> build.properties
echo "xdat.mail.password=" >> build.properties
echo "xdat.mail.admin=administrator@xnat.org" >> build.properties
echo "xdat.mail.prefix=XNAT" >> build.properties


echo "xdat.url=$url:8080" >> build.properties
echo "xdat.require_login=true" >> build.properties
echo "xdat.enable_new_registrations=false" >> build.properties
echo "xdat.security.channel=any" >> build.properties
echo "xdat.enable_csrf_token=true" >> build.properties

cp build.properties ./xnat/build.properties

sudo chmod -R 777 ~/.maven
echo "Setting up xnat: expected fail"
cd xnat
sudo chmod -R 777 ./plugin-resources
sudo chmod -R 777 ./bin
sudo chmod -R 777 ..
bash ./bin/setup.sh
rm -R ./deployments/*
sudo chmod -R 777 ~/.maven


rm -R ~/.maven/repository
rm -R $PWD/plugin-resources/repository
cp -R $loc/repository $PWD/plugin-resources/repository
cp -R $loc/repository ~/.maven/repository

#unzip $loc/xnat-maven.zip -d ~/	
sudo chmod -R 777 ~/.maven
sudo chmod -R 777 $loc/repository
sudo chmod -R 777 ..
echo "Setting up xnat: expected success"
bash ./bin/setup.sh -Ddeploy=true

echo "Populating Database Schema"
cd deployments/xnat
psql -d $dbname -f sql/xnat.sql -U $dbuser

echo "Creating default user admin"
~/xnat_install/xnat/bin/StoreXML -l security/security.xml -allowDataDeletion true
~/xnat_install/xnat/bin/StoreXML -dir ./work/field_groups -u admin -p admin -allowDataDeletion true


echo "enabling tomcat ports in firewall"
ufw allow 8080

echo "starting tomcat"
bash $CATALINA_HOME/bin/shutdown.sh
bash $CATALINA_HOME/bin/startup.sh

echo "Setup Complete. See xnat at $url:8080 and login with username:admin password:admin"

