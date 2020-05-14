#!/usr/bin/env bash

[ -z $1 ] && echo "db_name missing" && exit 1
[ -z $2 ] && echo "pg_user missing" && exit 1
[ -z $3 ] && echo "s3_bucket missing" && exit 1
[ -z $4 ] && echo "dump_count missing" && exit 1

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
timestamp=$(date +%s)
sudo -u $2 pg_dump $1 > $tmp_dir/$timestamp.sql
aws s3 cp $tmp_dir/$timestamp.sql s3://$3/$timestamp.sql

counter=1
for i in $(aws s3 ls $3 | awk '{print $4}' | tac); do
    if [[ "$counter" -gt $4 ]]; then
        aws s3 rm s3://$3/$i
    fi 
    counter=$((counter+1))
done

exit 0
