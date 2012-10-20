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

  IBOutlet NSWindow                 *mainWindow;        
  IBOutlet NSTextView               *consoleTextView;
  IBOutlet NSTextView               *inputTextView;
  IBOutlet NSUserDefaultsController *userDefaultsController;

    
  libusb_device                     **allUSBDevices;            // pointer to pointer of device, used to retrieve a list of devices
  libusb_device_handle              *USBDeviceHandle;
  libusb_device                     *theUSBDevice;
  ssize_t                           numberOfUSBDevices;         // holds number of devices in list

  NSMutableAttributedString         *outputTextStorage;         // a pointer to ouputTexView's textStorage
  NSMutableAttributedString         *inputTextStorage;          // a pointer to inputTextView's textStorage
}

@property (copy) NSColor  *consoleErrorTextColor;
@property (copy) NSColor  *consoleInformationTextColor;
@property (copy) NSColor  *consoleDataTextColor;
@property (copy) NSColor  *consoleBackgroundColor;

@property (copy) NSNumber *displayHexOrPlainText;
@property (copy) NSNumber *bulkTransferEndpoint;
@property (copy) NSNumber *bulkTransferDirection;
@property (copy) NSNumber *bulkTransferLength;
@property (copy) NSNumber *deviceVID;
@property (copy) NSNumber *devicePID;
@property (copy) NSNumber *requestType;
@property (copy) NSNumber *requestDestination;
@property (copy) NSNumber *controlTransferRequest;
@property (copy) NSNumber *controlTransferValue;
@property (copy) NSNumber *controlTransferIndex;
@property (copy) NSNumber *controlTransferLength;



- (void) printString:           (NSString *)      theString;
- (void) printData:             (unsigned char *) theData     length:       (int) theLength;
- (void) printHexFromData:      (unsigned char *) theData     length:       (int) theLength;
- (void) printPlainTextFromData:(unsigned char *) theData     length:       (int) theLength;
- (void) printLibUSBError:      (int)             theError    withOperation:(NSString *) theOperation;

/**
 Convers a hex formatted NSString to NSData.
 
 The string should have byte sized hex symbols speperated by spaces, with or without leading a `0x'. Leading zeros are optional.
 
 A valid example: `0xdE ad Fe ed 0xA 0xb c 0d'.

 @param theString
 @returns NSData
*/
- (NSData *) dataFromHexString: (NSString *) theString;


- (IBAction) doBulkTransfer:            (id) sender;
- (IBAction) doUSBControlTransfer:      (id) sender;
- (IBAction) listAllAttachedUSBDevices: (id) sender;
- (IBAction) clearConsole:              (id) sender;


UInt8 convertNSStringToUInt8(NSString *theString);
UInt16 convertNSStringToUInt16( NSString *theString);

@end
