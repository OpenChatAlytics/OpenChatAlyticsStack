#!/bin/sh
set -e

if [ "$#" -ne 1 ]
then
    echo "You haven't specified the configuration file"
    exit 1
fi

config_file=$1

echo "Starting the database"
su -c '${POSTGRESDIR}pg_ctl --pgdata ${DATABASEDIR}chatalytics --log ${DATABASEDIR}chatalytics/db-logfile -w restart' postgres
echo "Finished starting the database"

cd chatalytics

echo "Starting compute server with configuration: $config_file..."

nohup java\
    -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation\
    -XX:NumberOfGCLogFiles=1 -XX:GCLogFileSize=10M -Xloggc:chatalytics_compute-gc.log -XX:+UseSerialGC\
    -cp chatalytics-compute-0.3-with-dependencies.jar:config\
    -Dlogback.configurationFile=config/compute/logback.xml com.chatalytics.compute.ChatAlyticsEngineMain\
    -c $config_file 2>&1 > /dev/null &

sleep_time_secs=15
echo "Sleeping for $sleep_time_secs waiting for compute to start up"
sleep $sleep_time_secs

echo "Starting web server with configuration: $config_file..."

nohup java\
    -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation\
    -XX:NumberOfGCLogFiles=1 -XX:GCLogFileSize=10M -Xloggc:chatalytics_web-gc.log -XX:+UseSerialGC\
    -cp chatalytics-web-0.3-with-dependencies.jar:config\
    -Dlogback.configurationFile=config/web/logback.xml com.chatalytics.web.ServerMain\
    -c $config_file 2>&1 > /dev/null &

sleep_time_secs=5
echo "Sleeping for $sleep_time_secs waiting for the web server to start up"
sleep $sleep_time_secs

cd ../chatalyticsui
npm run start
