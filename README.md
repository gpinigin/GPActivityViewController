GPActivityViewController
========================

Alternative to UIActivityViewController compatible with iOS5.0

###Supported activities
* Facebook
* Twitter
* Vkontakte
* Odnoklassniki
* Mail
* Messages
* Copy


###Requirements
* XCode 4.4+
* Deployment Target iOS5.0+
* ARC

##Social networks integration
###Facebook
* Set up **FacebookAppID** property in your info.plist file, i.e.  FacebookAppID = 12345678
* Set up URL scheme for facebook redirect: fb<FacebookAppID> , where <FacebookAppID> - Facebook application ID

###Odnoklassniki
* Set up properties **OdnoklassnikiAppID**, **OdnoklassnikiSecretKey**, **OdnoklassnikiAppKey** in your info.plist file.
* Set up URL scheme for redirect: ok<OdnoklassnikiAppID> , where <OdnoklassnikiAppID> - Odnoklassniki application ID

###Vkontakte
* Set up **VKontakteAppID** property in your info.plist file
