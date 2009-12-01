BEGIN {
	printf "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist SYSTEM \"file://localhost/System/Library/DTDs/PropertyList.dtd\">\n<plist version=\"1.0\">\n\t<array>\n";
	}

{
	gsub(/ */,"",$1);
	gsub(/ */,"",$2);
	printf "\t\t<dict>\n\t\t\t<key>Code</key>\n\t\t\t<string>%s</string>\n\t\t\t<key>Name</key>\n\t\t\t<string>%s</string>\n\t\t</dict>\n",$2,$1;
}

END {
	printf "\t</array></plist>";
}
