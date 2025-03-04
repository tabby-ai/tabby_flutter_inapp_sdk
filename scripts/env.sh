#!/usr/bin/env bash

rm -rf .secure_files
mkdir .secure_files
cd .secure_files
gcloud secrets versions access latest --secret="AuthKey_6WK27WDACV_p8" > "AuthKey_6WK27WDACV.p8"
cd ..