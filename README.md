#![USB Toolbox](https://raw.github.com/JayKickliter/USB-Toolbox/master/USB%20Toolbox/Images/mac.iconset/icon_32x32.png)  USB-Toolbox 

<a href="http://www.flickr.com/photos/jaykickliter/8102771234/" title="USBToolBox by Jay Kickliter, on Flickr"><img src="http://farm9.staticflickr.com/8464/8102771234_7d82f8f04e_z.jpg" width="640" height="414" alt="USBToolBox"></a>
  
## About

Simple Cocoa application to send Vendor Requests and Bulk Transfers (for now). It is still very early in development.

## Documentation

I just started learning Doxygen, so it's pretty sparse right now.  

## Prerequisites

Xcode project settings assume you have LibUSB installed and located at `/opt/local/lib/libusb-1.0.0.dylib`. However, the Xcode project set up to include the dylib in the application bundle, so the user doesn't need to have it installed.