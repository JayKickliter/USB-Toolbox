//
//  CTAppDelegate.h
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/8/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#define CT_DISPLAY_HEX        0
#define CT_DISPLAY_PLAIN_TEXT 1

#import <Cocoa/Cocoa.h>
#include "libusb.h"

@interface CTAppDelegate : NSObject <NSApplicationDelegate> {

  IBOutlet NSWindow         *mainWindow;        
  IBOutlet NSTextView       *consoleTextView;
  IBOutlet NSTextView       *inputTextView;
  IBOutlet NSUserDefaultsController *userDefaultsController;

    
  libusb_device             **allUSBDevices;           // pointer to pointer of device, used to retrieve a list of devices
  libusb_device_handle      *USBDeviceHandle;
  libusb_device             *theUSBDevice;

  ssize_t                   numberOfUSBDevices;        // holds number of devices in list
  NSMutableAttributedString *outputTextStorage;        // a pointer to ouputTexView's textStorage
  NSMutableAttributedString *inputTextStorage;        // a pointer to inputTextView's textStorage
}

@property (readwrite) NSInteger displayHexOrPlainText;
@property (readwrite) NSInteger requestType;
@property (readwrite) NSInteger requestDestination;
@property (copy)      NSColor   *consoleErrorTextColor;
@property (copy)      NSColor   *consoleInformationTextColor;
@property (copy)      NSColor   *consoleDataTextColor;
@property (copy)      NSColor   *consoleBackgroundColor;
@property (copy)      NSString  *deviceVIDString;
@property (copy)      NSString  *devicePIDString;
@property (copy)      NSString  *controlTransferRequestString;
@property (copy)      NSString  *controlTransferValueString;
@property (copy)      NSString  *controlTransferIndexString;
@property (copy)      NSString  *controlTransferLengthString;


- (void) printString: (NSString *) theString;
- (void) printData: (unsigned char *) theData length: (int) theLength;
- (void) printHexFromData: (unsigned char *) theData length: (int) theLength;
- (void) printPlainTextFromData: (unsigned char *) theData length: (int) theLength;
- (void) printLibUSBError: (int) theError withOperation: (NSString *) theOperation;


- (IBAction) doUSBControlTransfer: (id) sender;
- (IBAction) listAllAttachedUSBDevices: (id)sender;
- (IBAction) clearConsole:(id)sender;


UInt8 convertNSStringToUInt8(NSString *theString);
UInt16 convertNSStringToUInt16( NSString *theString);

@end
