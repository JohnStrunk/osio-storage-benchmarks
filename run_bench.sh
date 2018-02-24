#! /bin/bash
# vim: set ts=4 sw=4 et :

##############################
# Assumes that the SUT is mounted in $BASE_DIR

set -ex

BASE_DIR=/target
CLONE_REPO=https://github.com/gluster/glusterfs.git

function clone_test {
    #-- git clone
    time git clone ${CLONE_REPO} "${BASE_DIR}/repo"
    time sync

    #-- remove cloned repo
    time rm -rf "${BASE_DIR}/repo"
    time sync
}

function maven_test {
    #-- Maven build
    export HOME="${BASE_DIR}/h"
    mkdir ${HOME}

    echo "FIRST BUILD (empty cache)"
    time git clone https://github.com/jfctest1/benchapp2.git "${BASE_DIR}/repo"
    cd "${BASE_DIR}/repo"
    time mvn clean -B -e -U compile -Dmaven.test.skip=false -P openshift
    cd
    time rm -rf "${BASE_DIR}/repo"

    echo "SECOND BUILD (cached artifacts)"
    time git clone https://github.com/jfctest1/benchapp2.git "${BASE_DIR}/repo"
    cd "${BASE_DIR}/repo"
    time mvn clean -B -e -U compile -Dmaven.test.skip=false -P openshift
    echo "THIRD BUILD (rebuild)"
    time mvn clean -B -e -U compile -Dmaven.test.skip=false -P openshift
    cd
    time rm -rf "${BASE_DIR}/repo"
}

function fio_test {
    #-- fio
    FILE="${BASE_DIR}/testfile"
    fio --filesize=500M --runtime=120s --ioengine=libaio --direct=1 --time_based --stonewall --filename="$FILE" \
        --name=rr4k@qd1 --description="e2e latency via 4k random reads @ qd=1" --iodepth=1 --bs=4k --rw=randread \
        --name=rw4k@qd1 --description="e2e latency via 4k random writes @ qd=1" --iodepth=1 --bs=4k --rw=randwrite \
        --name=rr4k@qd32 --description="IOPS via 4k random reads @ qd=32" --iodepth=32 --bs=4k --rw=randread \
        --name=rw4k@qd32 --description="IOPS via 4k random writes @ qd=32" --iodepth=32 --bs=4k --rw=randwrite \
        --name=sr1m@qd32 --description="Bandwidth via 1MB sequential reads @ qd=32" --iodepth=32 --bs=1m --rw=read \
        --name=sw1m@qd32 --description="Bandwidth via 1MB sequential writes @ qd=32" --iodepth=32 --bs=1m --rw=write
    #rm -f "$FILE"
}

echo "Starting run at: $(date)"
#clone_test
maven_test
#fio_test
echo "Finished run at: $(date)"
