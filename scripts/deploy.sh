#!/bin/sh

NAME=Babelfish.service
BUILD=`dirname $0`/../src/build/Debug
SERVICE=$BUILD/$NAME
TARGET=$HOME/Library/Services

if [ -d $TARGET/$NAME ]; then
	rm -vr $TARGET/$NAME;
fi

cp -vr $SERVICE $TARGET

$BUILD/refreshservices
