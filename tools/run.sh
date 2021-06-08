#!/bin/bash -x

# Prepares the artifacts.
source /home/runner/tools/prepare.sh $1

# Make sure the first argument will not be passed down to exec if it is a artifact location.
if [[ $location == *s3://* ]]; then
  shift
fi

# Ensure that assigned uid has entry in /etc/passwd.
if [ `id -u` -ge 10000 ]; then
    echo "Patching /etc/passwd to make ${RUNNER_USER} -> builder and `id -u` -> ${RUNNER_USER}"
    cat /etc/passwd | sed -e "s/${RUNNER_USER}/builder/g" > /tmp/passwd
    echo "${RUNNER_USER}:x:`id -u`:`id -g`:,,,:/home/${RUNNER_USER}:/bin/bash" >> /tmp/passwd
    cat /tmp/passwd > /etc/passwd
    rm /tmp/passwd
fi

if [ -f "/home/runner/artifacts/RUNNING_PID" ]
then
   rm /home/runner/artifacts/RUNNING_PID
fi

export EXTERNAL_IP=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

echo "Got external ip [$EXTERNAL_IP]."

echo "Environment start"
env
echo "Environment start"

echo "/etc/hosts start"
cat /etc/hosts
echo "/etc/hosts end"

# Set the timezone if TZ is set
if [ ! -z "$TZ" ]; then
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" >  /etc/timezone && \
    echo "Container timezone set to: $TZ"
fi

exec "/home/runner/artifacts/bin/dist" "-J-XX:+ExitOnOutOfMemoryError" "-Dconfig.resource=combined.conf" "-Dplay.evolutions.db.default.autoApply=true" "-DapplyEvolutions.default=true" "$@"
