#!/usr/bin/env bash

echo "Building Android 🛠️"

fvm use
make pg

cd example

fvm flutter build apk --release