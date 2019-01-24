#!/bin/bash
# rpm based systems only

yum install wget -y > /dev/null 2>&1

echo "check to see if AL agent is installed"

service al-agent status > /dev/null 2>&1

if [ $? -ne 0 ]
then
	echo "no al-agent service found, lets get the agent and do a fresh install"
	wget https://scc.alertlogic.net/software/al-agent-LATEST-1.x86_64.rpm
	rpm -U al-agent-LATEST-1.x86_64.rpm

fi
service al-agent stop 2>&1

rm -vrf /var/alertlogic/etc/host*.pem

/etc/init.d/al-agent configure --key $1 2>&1
service al-agent start 2>&1

sleep 5

echo "Confirm that new host keys have been created... if none found exit with error status..."

find /var/alertlogic/etc/host_* -mmin -2 -ls | grep host

exit $?
