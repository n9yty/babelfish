# Adding a new Language Pair #
The distribution itself contains only translations from English to French and vice-versa. You can, however, with some effort put another language pair (which is supported by google translate).

Some basic knowledge of objective-c (xcode) is necessary or at least to be careful with copy and paste.

This is an example how to add English to Czech translation:

  1. check which language pairs are [supported](http://code.google.com/apis/ajaxlanguage/documentation/#SupportedPairs)
  1. get the sources
  1. open `Translator.h` and add new method:
```
-(void)translateEnglishToCzech:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;
```
  1. open `Translator.m` and add new method:
```
-(void)translateEnglishToCzech:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
	[self doTranslate:pboard userData:userData error:error from:@"en" to:@"cz"];
}
```
  1. open `BabelfishService-Info.plist` and add a new `NSService` entry
```
<dict>
	<key>NSMenuItem</key>
	<dict>
		<key>default</key>
		<string>Translate from English to Czech</string>
	</dict>
	<key>NSMessage</key>
	<string>translateEnglishToCzech</string>
	<key>NSPortName</key>
	<string>BabelfishTranslator</string>
	<key>NSReturnTypes</key>
	<array>
		<string>NSStringPboardType</string>
	</array>
	<key>NSSendTypes</key>
	<array>
		<string>NSStringPboardType</string>
	</array>
</dict>
```
  1. rebuild
  1. reinstall

More information about the OSX services can be found in [Services Implementation Guide](http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/SysServices/index.html).