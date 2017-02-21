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

      aws s3 cp config-dir.zip s3://aws-composer-gocd-prod/backup/
      aws s3 cp config-repo.zip s3://aws-composer-gocd-prod/backup/
      aws s3 cp db.zip s3://aws-composer-gocd-prod/backup/
      aws s3 cp version.txt s3://aws-composer-gocd-prod/backup/
      aws s3 cp go_notify.conf s3://aws-composer-gocd-prod/backup/

      git commit -m "`basename \"$f\"`"

      rm -rf "$f"

   fi
done

git push

git clone --depth 1 git@github.com:Financial-Times/aws-composer-gocd-backup.git $BACKUP_HOME/verify
cd $BACKUP_HOME/verify

if [ $((( $(date +%s) - $(git log -1 --format=%at) ))) -gt 60 ];
then
    echo "ERROR! latest remote git commit timestamp is not recent (past minute)"
    EXIT=1
else
    echo "Backup verified! latest remote git commit timestamp is recent (past minute)"
    EXIT=0
fi

rm -rf $BACKUP_HOME/verify

exit $EXIT
