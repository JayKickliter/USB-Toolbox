//
//  CTAppDelegate.m
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/8/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import "CTAppDelegate.h"

#pragma mark Defaults Keys
NSString * const CTDefault_ConsoleBackgroundColor_Key       = @"consoleBackgroundColor";
NSString * const CTDefault_ConsoleErrorTextColor_Key        = @"consoleErrorTextColor";
NSString * const CTDefault_ConsoleDataTextColor_Key         = @"consoleDataTextColor";
NSString * const CTDefault_ConsoleInformationTextColor_Key  = @"consoleInformationTextColor";
NSString * const CTDefault_DisplayHexOrPlainText_Key        = @"displayHexOrPlainText";
NSString * const CTDefault_VID_Key                          = @"deviceVIDString";
NSString * const CTDefault_PID_Key                          = @"devicePIDString";
NSString * const CTDefault_bmRequestType_Key                = @"requestType";
NSString * const CTDefault_bmRequestDestination_Key         = @"requestDestination";
NSString * const CTDefault_bRequest_Key                     = @"controlTransferRequestString";
NSString * const CTDefault_wValue_Key                       = @"controlTransferValueString";
NSString * const CTDefault_wIndex_Key                       = @"controlTransferIndexString";
NSString * const CTDefault_wLength_Key                      = @"controlTransferLengthString";

@implementation CTAppDelegate


#pragma mark Syntesis
@synthesize displayHexOrPlainText;
@synthesize requestType;
@synthesize requestDestination;
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


#pragma mark Startup Methods

+ (void) initialize
{
  NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArchiver archivedDataWithRootObject: [ NSColor blackColor ]], CTDefault_ConsoleBackgroundColor_Key,
                                 [NSArchiver archivedDataWithRootObject: [ NSColor redColor   ]], CTDefault_ConsoleErrorTextColor_Key,
                                 [NSArchiver archivedDataWithRootObject: [ NSColor greenColor ]], CTDefault_ConsoleDataTextColor_Key,
                                 [NSArchiver archivedDataWithRootObject: [ NSColor grayColor  ]], CTDefault_ConsoleInformationTextColor_Key,
                                 @"0",    CTDefault_DisplayHexOrPlainText_Key,
                                 @"0000", CTDefault_VID_Key,
                                 @"0000", CTDefault_PID_Key,
                                 @"0",  CTDefault_bmRequestType_Key,
                                 @"0",    CTDefault_bmRequestDestination_Key,
                                 @"00"  , CTDefault_bRequest_Key,
                                 @"0000", CTDefault_wValue_Key,
                                 @"0000", CTDefault_wIndex_Key,
                                 @"0000", CTDefault_wLength_Key,
                                 nil ];

  [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  outputTextStorage = [ consoleTextView textStorage ];
  inputTextStorage  = [ inputTextView textStorage ];

  [ inputTextView setFont: [ NSFont fontWithName:@"Monaco" size:13.0 ]];

  [ self setupBindings ];

  int result = libusb_init(NULL);                 //initialize a library session
  if(result < 0) {
    [ self printLibUSBError:result withOperation:@"libusb_init(NULL)"];
  }
}



- (void) setupBindings
{
  [ consoleTextView bind: @"backgroundColor"
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_ConsoleBackgroundColor_Key ]
                 options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ] ];
  [ inputTextView bind: @"backgroundColor"
              toObject: userDefaultsController
           withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_ConsoleBackgroundColor_Key ]
              options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ] ];

  [ inputTextView bind: @"insertionPointColor"
              toObject: userDefaultsController
           withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_ConsoleDataTextColor_Key ]
               options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                    forKey: NSValueTransformerNameBindingOption ] ];

  [ inputTextView bind: @"textColor"
              toObject: userDefaultsController
           withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_ConsoleDataTextColor_Key ]
               options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                    forKey: NSValueTransformerNameBindingOption ] ];

  [ self            bind: CTDefault_ConsoleErrorTextColor_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_ConsoleErrorTextColor_Key ]
                 options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ]  ];
  [ self            bind: CTDefault_ConsoleDataTextColor_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_ConsoleDataTextColor_Key ]
                 options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ] ];
  [ self            bind: CTDefault_ConsoleInformationTextColor_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_ConsoleInformationTextColor_Key ]
                 options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ] ];
  [ self            bind: CTDefault_PID_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_PID_Key ]
                 options: nil ];
  
  [ self            bind: CTDefault_VID_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_VID_Key ]
                 options: nil ];
  
  [ self            bind: CTDefault_bRequest_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_bRequest_Key ]
                 options: nil ];
  
  [ self            bind: CTDefault_wValue_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_wValue_Key ]
                 options: nil ];
  
  [ self            bind: CTDefault_wIndex_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_wIndex_Key ]
                 options: nil ];
  
  [ self            bind: CTDefault_wLength_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_wLength_Key ]
                 options: nil ];
  
  [ self            bind: CTDefault_DisplayHexOrPlainText_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_DisplayHexOrPlainText_Key ]
                 options: nil ];
  
  [ self            bind: CTDefault_bmRequestType_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_bmRequestType_Key ]
                 options: nil ];
  
  [ self            bind: CTDefault_bmRequestDestination_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_bmRequestDestination_Key ]
                 options: nil ];
}










#pragma mark USB Actions

- (IBAction) doUSBControlTransfer: (id) sender
{
  UInt16  deviceVID, devicePID, wIndex, wLength, wValue;
  UInt8   bRequest, bmRequestType;
  int     result;

  deviceVID     = convertNSStringToUInt16( deviceVIDString );
  devicePID     = convertNSStringToUInt16( devicePIDString );
  bRequest      = convertNSStringToUInt8( controlTransferRequestString );
  wIndex        = convertNSStringToUInt16( controlTransferIndexString );
  wLength       = [ controlTransferLengthString intValue ];
  wValue        = convertNSStringToUInt8( controlTransferValueString );
  bmRequestType = (UInt8) requestType | requestDestination;


  unsigned char data[4096];


  if ( !(self.requestType & 0x80) ) { // is it host -> device request?    

    NSString      *inputString    = [ inputTextStorage string ];
    NSData        *inputData      = [ self dataFromHexString: inputString ];
    NSUInteger    inputLength       = [ inputData length ];
    unsigned char *inputDataBytes = (unsigned char *) [ inputData bytes ];

    if (  inputLength < wLength ) {
      wLength = inputLength;
      [self setControlTransferLengthString: [ NSString stringWithFormat: @"%d", wLength ]];
    }

    memcpy(data, inputDataBytes, wLength);
  }


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
      [ self printPlainTextFromData: theData length: theLength ];
      break;

    default:
      break;
  }
}



- (void) printHexFromData: (unsigned char *) theData length: (int) theLength
{
  UInt16  i;
  UInt16 address = 0;

  for (i=0; i<theLength; i++) {
    switch ( i & 0x000F ) {

      case 0x0000:
        [ self printString: [ NSString stringWithFormat: @"%04X: %02X",  address, theData[i] ]];
        break;

      case 0x000F:
        [ self printString: [ NSString stringWithFormat: @" %02X    %@\n", theData[i], [ self plainTextStringFromData: &theData[i-15] length: 16 breakNewLines: FALSE ] ]];
        address += 0x10;
        break;

      default:
        [ self printString: [ NSString stringWithFormat: @" %02X", theData[i] ]];
        break;
        
    }
  }
  [ self printNewLine: 2 ];
}



- (NSString *) plainTextStringFromData: (unsigned char *) theData length: (int) theLength breakNewLines: (BOOL) doNewLines
{
  int i;
  char theCString[theLength];
  NSString   *theReturnedString;

  for ( i = 0 ; i < theLength ; i++ ) {
    if ( theData[i] < 0x7F && theData[i] > 0x1F ) { // is the byte a a visible ascii character?
      theCString[i] = theData[i];
    } else if ( theData[i] == '\r' && doNewLines == TRUE ) {
      theCString[i] = theData[i];
    } else {
      theCString[i] = '.';
    }
  }
  theCString[theLength] = 0;

  theReturnedString = [ NSString stringWithCString: theCString encoding: NSASCIIStringEncoding ];

  return theReturnedString;

}



- (void) printPlainTextFromData: (unsigned char *) theData length: (int) theLength
{
  NSString *theOuputString = [ self plainTextStringFromData: theData
                                                     length: theLength
                                              breakNewLines: TRUE ];
  [ self printString: theOuputString ];
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










#pragma mark Helper Functions/Methods

UInt8 convertNSStringToUInt8( NSString *theString )
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



- (NSData *) dataFromHexString: (NSString *) theString
{
  unsigned int i;
//  int bytesScanned = 0;

  NSScanner* scanner = [NSScanner scannerWithString: theString ];
	[scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString: @" "]];

  NSMutableData *returnData = [ NSMutableData new ];
  


	while ([scanner isAtEnd] == NO)
	{
		if([scanner scanHexInt: &i] && i <= 255 )
		{
			[ returnData appendBytes: &i length: 1 ];
//			bytesScanned++;
		}
		else
			return nil;
	}
  return returnData;
}






#pragma mark Shutdown

- (void) applicationWillTerminate:(NSNotification *)notification
{
  libusb_free_device_list(allUSBDevices, 1);    //free the list, unref the devices in it
  libusb_exit(NULL);                            //close the session
}










@end