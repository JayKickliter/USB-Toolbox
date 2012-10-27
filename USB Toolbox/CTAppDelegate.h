//
//  CTAppDelegate.h
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/8/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#define CT_DISPLAY_HEX        0
#define CT_DISPLAY_PLAIN_TEXT 1

#import   <Cocoa/Cocoa.h>
#include  "libusb.h"
#include  "NSData+CTDataExtensions.h"
#import   "CTUSBDevice.h"


@interface CTAppDelegate : NSObject <NSApplicationDelegate> {

  IBOutlet NSUserDefaultsController *userDefaultsController;

  IBOutlet NSWindow                 *mainWindow;
  IBOutlet NSTextView               *consoleTextView;
  IBOutlet NSTextView               *inputTextView;
  IBOutlet NSTableView              *deviceListTableView;
  IBOutlet NSArrayController        *deviceListArrayController;
  IBOutlet NSButton                 *displayDeviceListButton;
  IBOutlet NSPopover                *deviceListPopover;
  IBOutlet NSMenuItem               *displayHexMenuItem;
  IBOutlet NSMenuItem               *displayASCIIMenuItem;
  
  BOOL                              isRebuildingDeviceList;

    
  libusb_device                     **allUSBDevices;            // pointer to pointer of device, used to retrieve a list of devices
  libusb_device_handle              *USBDeviceHandle;
  libusb_device                     *USBDevice;
  ssize_t                           numberOfUSBDevices;         // holds number of devices in list

  NSMutableAttributedString         *outputTextStorage;         // a pointer to ouputTexView's textStorage
  NSMutableAttributedString         *inputTextStorage;          // a pointer to inputTextView's textStorage
}



@property (copy) NSMutableArray *deviceArray;

@property (copy) NSColor  *consoleErrorTextColor;
@property (copy) NSColor  *consoleInformationTextColor;
@property (copy) NSColor  *consoleDataTextColor;
@property (copy) NSColor  *consoleBackgroundColor;

@property (copy) NSNumber *displayHexOrPlainText;
@property (copy) NSNumber *endpointIn;
@property (copy) NSNumber *endpointOut;
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
@property (copy) NSFont   *fixedWidthFont;

@property (readonly)  BOOL displayHex;
@property (readonly)  BOOL displayASCII;
@property (readwrite) BOOL isConnected;



- (void) printString:           (NSString *)      theString;
- (void) printData:             (unsigned char *) theData            length: (int) theLength;
- (void) printHexFromData:      (unsigned char *) theData            length: (int) theLength;
- (void) printPlainTextFromData:(unsigned char *) theData            length: (int) theLength;
- (void) printLibUSBError:      (int)             theError    withOperation: (NSString *) theOperation;

- (IBAction) doBulkTransfer:    (id) sender;
- (IBAction) doControlTransfer: (id) sender;
- (IBAction) clearConsole:      (id) sender;
- (IBAction) showDeviceList:    (id) sender;


@end