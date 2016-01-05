### Abstract ###
_**Babelfish** is a simple translation service for OSX. As I have recently moved to France and not speaking much of French, I needed to have a quick way of translating texts from English to French and back. For this the OSX services seemed to be a great solution. I did a bit of a search for an existing solution, but found only a commercial tools (did not try that hard, though)._

_Well, since nowadays there are some great online translation services like google translate I've decided to give it a try and implement my own OSX service for text translate._

_This project can also serve as an example of how to implement an OSX service._

### Screenshots ###
|![http://babelfish.googlecode.com/files/Screenshot-1.png](http://babelfish.googlecode.com/files/Screenshot-1.png)|![http://babelfish.googlecode.com/files/Screenshot-2.png](http://babelfish.googlecode.com/files/Screenshot-2.png)|
|:----------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------|

### Installation ###
Download, open and place the service bundle into `~/Library/Services` or `/System/Library/Services`. In order to have it shown in the services menu you need to either log out or execute this command from terminal: `/System/Library/CoreServices/pbs` to force services menu to reload.

### Usage ###
This service works with a text (obviously) so just select a text you would like to translate and go to the application menu -> services -> and select the translation you would like to make.

By default it supports only English to French and vice-versa translations, but with you can AddAnotherLangugePair.