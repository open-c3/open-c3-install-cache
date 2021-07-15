#!/bin/bash

set -e 

DIR=$( dirname $0 )

cd "$DIR/.." || exit 1

if [ ! -d "data" ]; then
    mkdir data
fi


# sync perl

if [ -d "data/perl" ]; then
    echo "pull perl"

    cd data/perl && git pull && cd ../.. 
else
    echo "clone perl"
    cd data && git clone https://github.com/MYDan/perl.git && cd ..
fi


# sync mayi

if [ ! -d "data/mayi/data" ]; then
    mkdir -p data/mayi/data
fi

if [ "X$SYNC_MYDan_VERSION" = "X" ];then
    VERSIONURL='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'
    VVVV=$(curl -k -s $VERSIONURL)
else
    VVVV=$SYNC_MYDan_VERSION
fi

version=$(echo $VVVV|awk -F: '{print $1}')
md5=$(echo $VVVV|awk -F: '{print $2}')

if [[ $version =~ ^[0-9]{14}$ ]];then
    echo "mayi version: $version"
else
    echo "get version fail"
    exit 1
fi

MAYIPATH="data/mayi/data/mayi.$version.tar.gz"
if [ -f "$MAYIPATH" ];then
    fmd5=$(md5sum $MAYIPATH|awk '{print $1}')
    if [ "X$md5" != "X$fmd5" ];then
        rm -f "data/mayi/mayi.$version.tar.gz"
    else
        echo $VVVV > data/mayi/data/version
        exit 0;
    fi
fi

TEMPNAME=$(mktemp /tmp/mayi.XXXXXX )
chmod a+r $TEMPNAME
wget --no-check-certificate -O "$TEMPNAME" "https://github.com/MYDan/mayi/archive/mayi.$version.tar.gz" || exit 1

if [ -f "$TEMPNAME" ];then
    mv $TEMPNAME $MAYIPATH
else
    exit 1
fi

echo $VVVV > data/mayi/data/version

exit 0
