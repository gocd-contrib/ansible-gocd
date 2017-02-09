#!/bin/bash
BACKUP_HOME='/artifacts/serverBackups'
BACKUP_TMP=`mktemp -d`
WORKING_DIR=`pwd`/remote

cd "$WORKING_DIR"

cp /var/go/go_notify.conf go_notify.conf

# Start backup
curl 'https://{{ GOCD_SERVER_HOST }}:{{ GOCD_SERVER_SSL_PORT }}/go/api/backups' \
      --insecure \
      -u "$ADMIN_USER:$ADMIN_PASSWORD" \
      -H 'Confirm: true' \
      -H 'Accept: application/vnd.go.cd.v1+json' \
      -X POST
      
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
      git add config-dir.zip config-repo.zip db.zip version.txt go_notify.conf
      git commit -m "`basename \"$f\"`"
      rm -rf "$f"
   fi
done

git push
