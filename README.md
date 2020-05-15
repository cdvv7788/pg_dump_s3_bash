## About

A simple script to take backups from postgres and upload them to an S3 bucket. After the upload is complete, checks how many dumps are stored and, if past a given limit, delete the older dumps.
For simplicity, a text format dump is created. Use `psql` to restore the dumps.

This script takes 4 mandatory arguments:

- database name
- postgres user
- s3 bucket
- max dump count

The script assumes that the given user can log to the database without password (peer). Also, the user that invokes it must be a sudoer.
The server where this command is being run must have `aws cli` configured.

There is another optional argument: The AWS Secrets Manager name of a secret containing the password for the database of the given user.
If this argument is passed, the user that runs the cron job does not need to be a sudoer, and password authentication will be used instead
of peer authentication.

### Examples

Sudoer user running the script to generate backups for `database_name` with user `postgres` and store them in `s3_bucket`. If there are more than 100 dumps after this one is uploaded, clear the oldest ones.

```
./script.sh database_name postgres s3_bucket 100
```

Any user running the script to generate backups for `database_name` with user `test` and store them in `s3_bucket`. If there are more than 100 dump after this one is uploaded, clear the oldest ones. Pick the database password from AWS SecretsManager using `secret_name` as name.

```
./script.sh database_name postgres s3_bucket 100 secret_name
```
