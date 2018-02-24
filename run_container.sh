#! /bin/bash

set -ex

C=johnstrunk/osio-bench

docker build -t $C .
docker run -it --rm $C
