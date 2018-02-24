#! /bin/bash

set -ex

C=johnstrunk/osio-bench

docker build -t $C .
docker push $C
