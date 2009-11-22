#!/bin/sh
if [ $# != "2" ]; then
	echo "Usage: $0 <service> <image name>";
	exit 1;
fi

SERVICE=$1
NAME=$2
IMAGE=$NAME.dmg

if [ -f $IMAHE ]; then
	rm $IMAGE;
fi

FOLDER=/tmp/$NAME
if [ -d $FOLDER ]; then
	rm -fr $FOLDER;
fi
mkdir -p $FOLDER;

cp -vr $SERVICE $FOLDER
hdiutil create -srcfolder $FOLDER -nospotlight -noanyowners -volname $NAME $IMAGE
hdiutil internet-enable -yes $IMAGE


