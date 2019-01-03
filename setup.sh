#!/usr/bin/env bash

LOCALTIME=${LOCALTIME:='/etc/localtime'}
MARIADB_CLIENT_VERSION=${MARIADB_CLIENT_VERSION:=2.3.0}
CAMUNDA_VERSION=${CAMUNDA_VERSION:=7.10.0}
CAMUNDA_MAJOR_VERSION=$(echo $CAMUNDA_VERSION | awk 'BEGIN { FS="." }{ print $1 "." $2 }')

CAMUNDA_CONTAINER_DIR=${CAMUNDA_CONTAINER_DIR:=$PWD}

EXPOSED_PORT=${EXPOSED_PORT:='172.17.0.1:8080'}

DB_HOST=${DB_HOST:=172.17.0.1}
DB_PORT=${DB_PORT:=3306}
DB_NAME=${DB_NAME:=camunda}
DB_USER=${DB_USER:=test}
DB_PASS=${DB_PASS:=test}

CAMUNDA_WAR_URL=${CAMUNDA_WAR_URL:="https://camunda.org/release/camunda-bpm/tomcat/${CAMUNDA_MAJOR_VERSION}/camunda-webapp-tomcat-standalone-${CAMUNDA_VERSION}.war"}

MARIADB_CLIENT_URL=${MARIADB_CLIENT_URL:="https://downloads.mariadb.com/Connectors/java/connector-java-${MARIADB_CLIENT_VERSION}/mariadb-java-client-${MARIADB_CLIENT_VERSION}.jar"}

mkdir -p $CAMUNDA_CONTAINER_DIR

echo "\
camunda:
  container_name: camunda
  image: tomcat:alpine
  ports:
  - ${EXPOSED_PORT}:8080/tcp
  restart: always
  volumes:
  - ./lib/mariadb-java-client-${MARIADB_CLIENT_VERSION}.jar:/usr/local/tomcat/lib/mariadb-java-client-${MARIADB_CLIENT_VERSION}.jar
  - ./webapps:/usr/local/tomcat/webapps
  environment:
  - CATALINA_OPTS=\"-Duser.timezone=Asia/Shanghai\"
" > docker-compose.yml

mkdir -p $CAMUNDA_CONTAINER_DIR/webapps
mkdir -p $CAMUNDA_CONTAINER_DIR/lib

echo -n 'downloading MariaDB Client ... '
if [ $MARIADB_CLIENT_URL != '@'  ]; then
    curl -Lo $CAMUNDA_CONTAINER_DIR/lib/mariadb-java-client-${MARIADB_CLIENT_VERSION}.jar $MARIADB_CLIENT_URL
fi
echo -e "\e[32mdone\e[0m"

echo -n 'downloading BPM WAR File ... '
if [ $CAMUNDA_WAR_URL != '@' ]; then
    curl -Lo $CAMUNDA_CONTAINER_DIR/webapps/bpm.war ${CAMUNDA_WAR_URL}
fi
echo -e "\e[32mdone\e[0m"

echo -n 'extracting BPM WAR File ... '
mkdir -p $CAMUNDA_CONTAINER_DIR/webapps/bpm
cd $CAMUNDA_CONTAINER_DIR/webapps/bpm
fastjar -xf $CAMUNDA_CONTAINER_DIR/webapps/bpm.war
cd $CAMUNDA_CONTAINER_DIR
echo -e "\e[32mdone\e[0m"

echo 'Modifying applicationContext.xml ... '
mv $CAMUNDA_CONTAINER_DIR/webapps/bpm/WEB-INF/applicationContext.xml $CAMUNDA_CONTAINER_DIR/webapps/bpm/WEB-INF/applicationContext.orig.xml
cat $CAMUNDA_CONTAINER_DIR/webapps/bpm/WEB-INF/applicationContext.orig.xml \
    | xml ed -O -u '//_:bean[@id="dataSource"]/_:property[@name="targetDataSource"]//_:property[@name="driverClassName"]/@value' -v  'org.mariadb.jdbc.Driver' \
    | xml ed -O -u '//_:bean[@id="dataSource"]/_:property[@name="targetDataSource"]//_:property[@name="url"]/@value' -v  "jdbc:mariadb://${DB_HOST}:${DB_PORT}/${DB_NAME}" \
    | xml ed -O -u '//_:bean[@id="dataSource"]/_:property[@name="targetDataSource"]//_:property[@name="username"]/@value' -v  "${DB_USER}" \
    | xml ed -O -u '//_:bean[@id="dataSource"]/_:property[@name="targetDataSource"]//_:property[@name="password"]/@value' -v  "${DB_PASS}" \
    > $CAMUNDA_CONTAINER_DIR/webapps/bpm/WEB-INF/applicationContext.xml

echo ''
echo 'You are ready to go!'
echo 'Please run camunda container with docker-compose.'
echo ''
