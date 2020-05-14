## About

A simple script to take backups from postgres and upload them to an S3 bucket. After the upload is complete, checks how many dumps are stored and, if past a given limit, delete the older dumps.

This script takes 4 mandatory arguments:

- database name
- postgres user
- s3 bucket
- max dump count

The script assumes that the given user can log to the database without password (i.e. postgres).
