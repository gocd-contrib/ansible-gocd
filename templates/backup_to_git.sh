#!/bin/bash
BACKUP_HOME='/var/lib/go-server/artifacts/serverBackups'
BACKUP_TMP=`mktemp -d`
WORKING_DIR=`pwd`/remote

if [ -z "$ADMIN_USER" -o -z "$ADMIN_PASSWORD" ]
then
   echo Admin user or password not specified. No authentication will be attempted.
   echo To specify credentials set environment variables ADMIN_USER and ADMIN_PASSWORD - use a secure variable for the latter.
   CREDENTIALS=""
else
   CREDENTIALS="--anyauth --user $ADMIN_USER:$ADMIN_PASSWORD"
fi

echo curl $CREDENTIALS --no-progress-bar -d 'null' http://{{ GOCD_SERVER_HOST }}:{{ GOCD_SERVER_PORT }}/go/api/admin/start_backup

curl $CREDENTIALS --no-progress-bar -d 'null' http://{{ GOCD_SERVER_HOST }}:{{ GOCD_SERVER_PORT }}/go/api/admin/start_backup

cd "$WORKING_DIR"

# Initial Git configuration
git config push.default simple
git config user.email "{{ GOCD_ADMIN_EMAIL }}"
git config user.name "Go Server on {{ ansible_hostname }}"

for f in $BACKUP_HOME/*
do
   if [ -d "$f" ]
   then
      echo Processing backup "$f"
      mv -f "$f"/* .
      git add config-dir.zip config-repo.zip db.zip version.txt
      git commit -m "`basename \"$f\"`" 
      rm -rf "$f"
   fi
done

git push

