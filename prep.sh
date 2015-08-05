cd ~;
mkdir xnat_install;
cd xnat_install;
mkdir jdk;
mkdir tc7;
mkdir xnat;
cd ..;

echo "hello world" >> log.txt;

ufw enable;
ufw allow 80;
ufw allow 8080;