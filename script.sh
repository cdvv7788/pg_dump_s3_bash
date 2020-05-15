#!/usr/bin/env bash

[ -z $1 ] && echo "db_name missing" && exit 1
[ -z $2 ] && echo "pg_user missing" && exit 1
[ -z $3 ] && echo "s3_bucket missing" && exit 1
[ -z $4 ] && echo "dump_count missing" && exit 1

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
timestamp=$(date +%s)
if [ -z $5 ]
then
    sudo -u $2 pg_dump $1 > $tmp_dir/$timestamp.sql || { echo 'unable to create backup' ; exit 1; }
else
    pass=$(aws secretsmanager get-secret-value --secret-id="$5" | grep "SecretString" | awk -F'["]' '{print $4}')
    PGPASSWORD="$pass" pg_dump -U $2 -w $1 > $tmp_dir/$timestamp.sql || { echo 'unable to create backup' ; exit 1; }
fi
aws s3 cp $tmp_dir/$timestamp.sql s3://$3/$timestamp.sql

counter=1
for i in $(aws s3 ls $3 | awk '{print $4}' | tac); do
    if [[ "$counter" -gt $4 ]]; then
        aws s3 rm s3://$3/$i
    fi 
    counter=$((counter+1))
done

exit 0
