//
//  CTAppDelegate.m
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/8/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import "CTAppDelegate.h"

NSString * const CTDefault_VID_Key      = @"userVID";
NSString * const CTDefault_PID_Key      = @"userPID";
NSString * const CTDefault_VID_String   = @"userVID";
NSString * const CTDefault_bRequest_Key = @"controlTransferRequest";
NSString * const CTDefault_wValue_Key   = @"controlTransferValue";
NSString * const CTDefault_wIndex_Key   = @"controlTransferIndex";
NSString * const CTDefault_wLength_Key  = @"controlTransferLength";

@implementation CTAppDelegate

@synthesize displayHexOrPlainText;
@synthesize requestType;
@synthesize requestDestinationAndType;
@synthesize consoleErrorTextColor;
@synthesize consoleInformationTextColor;
@synthesize consoleDataTextColor;
@synthesize consoleBackgroundColor;
@synthesize deviceVIDString;
@synthesize devicePIDString;
@synthesize controlTransferRequestString;
@synthesize controlTransferValueString;
@synthesize controlTransferIndexString;
@synthesize controlTransferLengthString;


#pragma mark Startup Methohos


+ (void) initialize
{
  NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys: [NSArchiver archivedDataWithRootObject: [ NSColor blackColor ]] ,   @"consoleBackgroundColor",
                                 [NSArchiver archivedDataWithRootObject: [ NSColor redColor ] ], @"consoleErrorTextColor",
                                 [NSArchiver archivedDataWithRootObject: [ NSColor greenColor ] ] , @"consoleDataTextColor",
                                 [NSArchiver archivedDataWithRootObject: [ NSColor grayColor ] ], @"consoleInformationTextColor",
                                 @"0000", CTDefault_VID_Key,
                                 @"0000", CTDefault_PID_Key,
                                 @"00",   CTDefault_bRequest_Key,
                                 @"0000", CTDefault_wValue_Key,
                                 @"0000", CTDefault_wIndex_Key,
                                 @"0000", CTDefault_wLength_Key,
                                 nil ];

  [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}






- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  outputTextStorage = [ consoleTextView textStorage ];

  [ self setupBindings ];

  int result = libusb_init(NULL);                 //initialize a library session
  if(result < 0) {
    [ self printLibUSBError:result withOperation:@"libusb_init(NULL)"];
  }
}






- (void) setupBindings
{
  [ consoleTextView bind:@"backgroundColor"
                toObject: userDefaultsController
             withKeyPath: @"values.consoleBackgroundColor"
                 options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ] ];
  [ self            bind:@"consoleErrorTextColor"
                toObject: userDefaultsController
             withKeyPath: @"values.consoleErrorTextColor"
                 options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ]  ];
  [ self            bind: @"consoleDataTextColor"
                toObject: userDefaultsController
             withKeyPath: @"values.consoleDataTextColor"
                 options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ] ];
  [ self            bind: @"consoleInformationTextColor"
                toObject: userDefaultsController
             withKeyPath: @"values.consoleInformationTextColor"
                 options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ] ];
  [ self            bind: @"devicePIDString"
                toObject: userDefaultsController
             withKeyPath: @"values.userPID"
                 options: nil ];
  [ self            bind: @"deviceVIDString"
                toObject: userDefaultsController
             withKeyPath: @"values.userVID"
                 options: nil ];
  [ self            bind: @"controlTransferRequestString"
                toObject: userDefaultsController
             withKeyPath: @"values.controlTransferRequest"
                 options: nil ];
  [ self            bind: @"controlTransferValueString"
                toObject: userDefaultsController
             withKeyPath: @"values.controlTransferValue"
                 options: nil ];
  [ self            bind: @"controlTransferIndexString"
                toObject: userDefaultsController
             withKeyPath: @"values.controlTransferIndex"
                 options: nil ];
  [ self            bind: @"controlTransferLengthString"
                toObject: userDefaultsController
             withKeyPath: @"values.controlTransferLength"
                 options: nil ];
}






- (IBAction) doUSBControlTransfer: (id) sender
{
  UInt16  deviceVID, devicePID, wIndex, wLength, wValue;
  UInt8   bRequest, bmRequestType;
  int     result;

  static unsigned char data[4096];

  deviceVID     = convertNSStringToUInt16( deviceVIDString );
  devicePID     = convertNSStringToUInt16( devicePIDString );
  bRequest      = convertNSStringToUInt8( controlTransferRequestString );
  wIndex        = convertNSStringToUInt16( controlTransferIndexString );
  wLength       = [ controlTransferLengthString intValue ];
  wValue        = convertNSStringToUInt8( controlTransferValueString );
  bmRequestType = (UInt8) requestType | requestDestinationAndType;
  


  [self printString: [ NSString stringWithFormat: @"Control transfer VID=%04x PID=%04x bmRequestType=%02x bRequest=%02x wValue=%04x wIndex=%04x wLength=%04x\n", deviceVID, devicePID, bmRequestType, bRequest, wValue, wIndex, wLength ] withTextColor: self.consoleInformationTextColor ];

  USBDeviceHandle = libusb_open_device_with_vid_pid(NULL, deviceVID, devicePID);

  if ( USBDeviceHandle == NULL ) {
    [ self printString: @"ERROR: " withTextColor: self.consoleErrorTextColor ];
    [ self printString: @"Invalid VID or PID\n\n"];
    return;
  }

  result = libusb_control_transfer( USBDeviceHandle,
                                   bmRequestType,
                                   bRequest,
                                   wValue,
                                   wIndex,
                                   data,
                                   wLength,
                                   1000 );

  if ( result < 0) {
    [ self printLibUSBError: result withOperation: @"libusb_control_transfer" ];
  } else {
    [self printData: data length: result];
  }
  libusb_close( USBDeviceHandle );
}






- (IBAction) listAllAttachedUSBDevices: (id)sender
{
  int i, result;
  struct libusb_device_descriptor deviceDescriptor;
  
  NSMutableString *output = [ NSMutableString new];
  numberOfUSBDevices = libusb_get_device_list(NULL, &allUSBDevices);                           //gets the list of devices;
  for ( i = 0; i < numberOfUSBDevices; i++ ) {
    [ output appendFormat: @"%2d: ", i ];
    theUSBDevice = allUSBDevices[i];
    result = libusb_get_device_descriptor(theUSBDevice, &deviceDescriptor);
    if ( result < 0) {
      [output appendString: @"failed to get device descriptor\n" ];
    } else {
      [ output appendFormat:@"VID: %04x  PID: %04x\n", deviceDescriptor.idVendor, deviceDescriptor.idProduct];
    }
  }
  [ self printString: output ];
  [ self printNewLine: 1 ];
}









#pragma mark Printing Methods

- (void) printString: (NSString *) theString
{
  [self printString: theString withTextColor: nil ];
}






- (void) printString: (NSString *) theString withTextColor: (NSColor *) theColor
{
  NSColor *textColor;
  if ( theColor == nil ) {
    textColor = self.consoleDataTextColor;
  } else {
    textColor = theColor;
  }
  NSFont *font = [NSFont fontWithName:@"Monaco" size:13.0];
  NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, textColor, NSForegroundColorAttributeName, nil];
  NSAttributedString *attrString =  [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@", theString]
                                                                    attributes:attrsDictionary];
  [ outputTextStorage appendAttributedString: attrString ];
  NSRange range;
  range = NSMakeRange ([outputTextStorage length], 0);

  [consoleTextView scrollRangeToVisible: range];
}






- (void) printData: (unsigned char *) theData length: (int) theLength
{
  switch ( displayHexOrPlainText ) {
    case CT_DISPLAY_HEX:
      [ self printHexFromData: theData length: theLength ];
      break;

    case CT_DISPLAY_PLAIN_TEXT:
      [ self printStringFromData: theData length: theLength ];
      break;

    default:
      break;
  }
}






- (void) printHexFromData: (unsigned char *) theData length: (int) theLength
{
  UInt16  i;
  UInt16 address = 0;
  
  NSMutableString *hexString = [NSMutableString new];

  for (i=0; i<theLength; i++) {
    switch ( i & 0x000F ) {
      case 0x0000:
        [ hexString appendFormat: @"%04X: %02X",  address, theData[i]];
        break;
      case 0x000F:
        [ hexString appendFormat:@" %02X\n", theData[i] ];
        address += 0x10;
        break;
      default:
        [ hexString appendFormat:@" %02X", theData[i] ];
        break;
    }
  }
  [ self printString: hexString ];
  [ self printNewLine: 2 ];
}






- (void) printStringFromData: (unsigned char *) theData length: (int) theLength
{
  int i;
  char dataString[theLength+1];
  char currentCharacter;
  memset(dataString, 0, theLength+1);
  for (i=0; i<theLength; i++) {
    currentCharacter = theData[i];
    if ( currentCharacter == 0 ) {
      dataString[i] = '.';
    } else if ( isascii(currentCharacter) ) {
      dataString[i] = currentCharacter;
    } else {
      dataString[i] = '.';
    }
  }

  [ self printString: [NSString stringWithCString: dataString encoding: NSASCIIStringEncoding ]];
  [ self printNewLine: 2 ];
}






- (void) printLibUSBError: (int) theError withOperation: (NSString *) theOperation
{
  [ self printString: @"ERROR: " withTextColor: self.consoleErrorTextColor ];
  [ self printString: @"LibUSB function " ];
  [ self printString: theOperation withTextColor: self.consoleInformationTextColor ];
  [ self printString: @" returned " ];
  [ self printString: [NSString stringWithCString: libusb_error_name(theError) encoding: NSUTF8StringEncoding ] withTextColor: self.consoleInformationTextColor ];
  [ self printNewLine: 2 ];
}






- (void) printNewLine: (int) numberOfNewLines
{
  int i = numberOfNewLines > 0 ? numberOfNewLines : 1;
  for ( i = 0 ; i < numberOfNewLines; i++ ) {
    [[ outputTextStorage mutableString ] appendString: @"\n" ];
  }

}






- (IBAction) clearConsole: (id) sender
{
  [[ outputTextStorage mutableString ] setString: @"" ];
}






#pragma mark Helper Functions

UInt8 convertNSStringToUInt8(NSString *theString)
{
  unsigned int theResult;
  sscanf([theString cStringUsingEncoding:NSUTF8StringEncoding], "%x", &theResult);
  return theResult & 0xFF;
}



UInt16 convertNSStringToUInt16( NSString *theString )
{
  unsigned int theResult;
  sscanf([theString cStringUsingEncoding:NSUTF8StringEncoding], "%x", &theResult);
  return theResult & 0xFFFF;
}





#pragma mark Shutdown

- (void) applicationWillTerminate:(NSNotification *)notification
{
  libusb_free_device_list(allUSBDevices, 1);    //free the list, unref the devices in it
  libusb_exit(NULL);                            //close the session
}









@end
