//
//  CTAppDelegate.m
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/8/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import "CTAppDelegate.h"
#import "CTNumberToHexStringTransformer.h"
#import "CTNumberToStringFormatter.h"

#pragma mark Defaults Keys
NSString * const CTDefault_ConsoleBackgroundColor_Key       = @"consoleBackgroundColor";
NSString * const CTDefault_ConsoleErrorTextColor_Key        = @"consoleErrorTextColor";
NSString * const CTDefault_ConsoleDataTextColor_Key         = @"consoleDataTextColor";
NSString * const CTDefault_ConsoleInformationTextColor_Key  = @"consoleInformationTextColor";
NSString * const CTDefault_DisplayHexOrPlainText_Key        = @"displayHexOrPlainText";
NSString * const CTDefault_VID_Key                          = @"deviceVID";
NSString * const CTDefault_PID_Key                          = @"devicePID";
NSString * const CTDefault_bmRequestType_Key                = @"requestType";
NSString * const CTDefault_bmRequestDestination_Key         = @"requestDestination";
NSString * const CTDefault_bRequest_Key                     = @"controlTransferRequest";
NSString * const CTDefault_wValue_Key                       = @"controlTransferValue";
NSString * const CTDefault_wIndex_Key                       = @"controlTransferIndex";
NSString * const CTDefault_wLength_Key                      = @"controlTransferLength";
NSString * const CTDefault_endpoint_Key                     = @"bulkTransferEndpoint";
NSString * const CTDefault_bulkTransferLength_Key           = @"bulkTransferLength";

@implementation CTAppDelegate


#pragma mark Syntesis
@synthesize deviceArray;
@synthesize displayHexOrPlainText;
@synthesize requestType;
@synthesize requestDestination;
@synthesize consoleErrorTextColor;
@synthesize consoleInformationTextColor;
@synthesize consoleDataTextColor;
@synthesize consoleBackgroundColor;
@synthesize deviceVID;
@synthesize devicePID;
@synthesize controlTransferRequest;
@synthesize controlTransferValue;
@synthesize controlTransferIndex;
@synthesize controlTransferLength;
@synthesize bulkTransferEndpoint;
@synthesize bulkTransferDirection;
@synthesize bulkTransferLength;

#pragma mark Startup Methods

+ (void) initialize
{
  // Register defaults. If the application has never been run,
  // these default values will be added to the application's preferences
  // proper list, stored in ~/Library/Preferences. If you have run the
  // application, it wont change anything.
  //
  NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSArchiver archivedDataWithRootObject: [ NSColor blackColor ]], CTDefault_ConsoleBackgroundColor_Key,
                                 [NSArchiver archivedDataWithRootObject: [ NSColor redColor   ]], CTDefault_ConsoleErrorTextColor_Key,
                                 [NSArchiver archivedDataWithRootObject: [ NSColor greenColor ]], CTDefault_ConsoleDataTextColor_Key,
                                 [NSArchiver archivedDataWithRootObject: [ NSColor grayColor  ]], CTDefault_ConsoleInformationTextColor_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_DisplayHexOrPlainText_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_VID_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_PID_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_bmRequestType_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_bmRequestDestination_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_bRequest_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_wValue_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_wIndex_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_wLength_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_endpoint_Key,
                                 [ NSNumber numberWithInt:0 ], CTDefault_bulkTransferLength_Key,
                                 nil ];

  [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];

  // Register value transformers
  //
  [ self initialiseValueTransformers ];
}



+ (void) initialiseValueTransformers
{
	CTNumberToHexStringTransformer * numberToHexStringFormatter = [[CTNumberToHexStringTransformer alloc] init];
	[CTNumberToHexStringTransformer setValueTransformer: numberToHexStringFormatter
                                              forName:@"NumberToHexStringFormatter"];
  CTNumberToStringFormatter * numberToStringFormatter = [[CTNumberToStringFormatter alloc] init];
	[CTNumberToHexStringTransformer setValueTransformer: numberToStringFormatter
                                              forName:@"NumberToStringFormatter"];
}




- (id) init
{
  self = [ super init ];
  if (self) {
    deviceArray = [ NSMutableArray new ];
  }

  return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Get a couple pointers to the textviews' texStorage. that way, we can call:
  //      [ outputTextStorage appendAttributedString: attrString ]
  // instead of:
  //      [[ consoleTextView textStorage ] appendAttributedString: attrString ]
  //
  outputTextStorage = [ consoleTextView textStorage ];
  inputTextStorage  = [ inputTextView textStorage ];

  // TODO: make sure this actually changes the font
  //
  [ inputTextView setFont: [ NSFont fontWithName:@"Monaco" size:13.0 ]];

  [ self setupBindings ];

  // let's initialize a library session now, instead of every time we send
  // a USB request/command.
  // TODO: also come up with a way to open the desired USB device as soon
  // as the user enters a valid VID and PID pair. It's pretty slow now to
  // to send a reuqest, since the methods to do so have to open a device and
  // close it before they return
  //
  // All LibUSB fucntions return an integer less zero for failure, and 0
  // for success or a positive integer for sucess and return value, such
  // as number of bytes transfered. There's a printLibUSBError method in this
  // file, but it doesn't work as well as it should. The programmer has to check
  // for an error. If there is one, then you call printLibUSBError. It would
  // be best if to have a totally encapsulated helper method that checks for
  // error, prints the error if there is one, and returns an int > 0 on sucess.
  //
  // TODO: write a complete checkLibUSBError
  int result = libusb_init(NULL);
  if(result < 0) {
    [ self printLibUSBError:result withOperation:@"libusb_init(NULL)"];
  }
  // it would be nice if this method also fillied the input and output textviews
  // the strings from the last session. I suppose they could be bound to the
  // defaults controller, but that seems like a bad idea, since they could be
  // pretty long strings. also, I doubt that attributes could be saved.
  //
  // TODO: have the application load previous session's NSTextView attributedStrings from file
}



- (void) setupBindings
{
  // I have everything bound to userDefaultsController. Most views in the GUI are also bound to
  // userDefaultsController. That seems a bit janky to me, but the UI textFields were't updating
  // properly when bound straigth to CTAppDelegate.
  //
  // TODO: figure out bindings
  //
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
//  [ self            bind: CTDefault_PID_Key
//                toObject: userDefaultsController
//             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_PID_Key ]
//                 options: nil ];
//  
//  [ self            bind: CTDefault_VID_Key
//                toObject: userDefaultsController
//             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_VID_Key ]
//                 options: nil ];
  
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
  [ self            bind: CTDefault_endpoint_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_endpoint_Key ]
                 options: nil ];
  [ self            bind: CTDefault_bulkTransferLength_Key
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_bulkTransferLength_Key ]
                 options: nil ];
}










#pragma mark USB Actions

- (IBAction) doControlTransfer: (id) sender
{
  // result is used to hold the return int from LibUSB calls, and either
  // use it to check the error code (if result < 0), or tell us
  // how many bytes were acually transferd, since it may be different
  // than what we requested.
  //
  int     error;

  // these are declared as UInt16's and UInt8's, since they will be used
  // to form USB packets, and need to have exact bitlengths
  //
  UInt16  VID       = [ deviceVID unsignedShortValue ];
  UInt16  PID       = [ devicePID unsignedShortValue ];
  UInt16  wIndex    = [ controlTransferIndex unsignedShortValue ];
  UInt16  wLength   = [ controlTransferLength unsignedShortValue ];
  UInt16  wValue    = [ controlTransferIndex unsignedShortValue ];
  UInt8   bRequest  = [ controlTransferRequest unsignedCharValue ];
  UInt8   bmRequest = [ requestType unsignedCharValue ] | [ requestDestination unsignedCharValue ];

  // I chose an arbitray length of 4096
  // TODO: figure out how big data[] should be
  //
  unsigned char data[4096];


  // self.requestType contains both the direction of the request, and
  // the type of request. It is bound to an NSMatrix via the defaults
  // controller. If bit 7 in self.requestType is a one, then it is
  // and IN request
  //
  if ( !( bmRequest & 0x80) ) { // is it an OUT (host -> device) request?    

    NSString      *inputHexString = [ inputTextStorage string ];                // TODO: create a method to encapulate this and the next line in one call
    NSData        *inputData      = [ NSData dataFromHexString: inputHexString ];
    NSUInteger    inputLength     = [ inputData length ];
    unsigned char *inputDataBytes = (unsigned char *) [ inputData bytes ];

    // What if we don't want to send all the hex bytes we have in the
    // input text view? Then we set the length in the Length textField.
    // What if our request length text field is larger than the number
    // hex bytes in the input text view? Then we just reduce the value
    // in the text field to match the number of bytes we actually have
    // available to send
    //
    if (  inputLength < wLength ) {                                             // TODO: i just noticed that this method might send all avalbe hex bytes, and not just the number requested
      [[ userDefaultsController values ] setValue: [ NSNumber numberWithUnsignedInteger: inputLength ] forKey: CTDefault_wLength_Key ];
      wLength = inputLength;
    }

    memcpy(data, inputDataBytes, [ controlTransferLength intValue ]);
  }

  // give some feed back of what transfer is about to take place
  //
  [self printString: [ NSString stringWithFormat:
                      @"Control transfer VID=%04x PID=%04x bmRequestType=%02x bRequest=%02x wValue=%04x wIndex=%04x wLength=%04x\n",
                      VID,
                      PID,
                      bmRequest,
                      bRequest,
                      wValue,
                      wIndex,
                      wLength ]
      withTextColor: [ self consoleInformationTextColor ]];

  // Open a device handle. This should happen earlier, since opening and closing
  // device handles is slow for some reason. Perhaps add a methid to open a device
  // handle as soon as a valid one is entered. Or maybe just put a click button.
  //
  // Also, the LibUSB documentation says that this function is only meant for
  // for a quick hack.
  //
//  USBDeviceHandle = libusb_open_device_with_vid_pid(NULL, VID, PID );            // TODO: use the proper fucntion to open device handles

  // the printLibUSBError method doesn't work with libusb_open_device_with_vid_pid
  // so we print a custom error method. This should be fixed.
  //
  if ( USBDeviceHandle == NULL ) {
    [ self printString: @"ERROR: " withTextColor: [ self consoleErrorTextColor ]];
    [ self printString: @"Invalid VID or PID\n\n"];
    return;
  }

  // libusb_control_transfer will return a negative number on error, or
  // the actual number of bytes transfered.
  //
  error = libusb_control_transfer( USBDeviceHandle,
                                   bmRequest,
                                   bRequest,
                                   wValue,
                                   wIndex,
                                   data,
                                   wLength,
                                   1000 );

  // check result for error or actual length transfered
  //
  if ( error < 0) {
    [ self printLibUSBError: error withOperation: @"libusb_control_transfer" ];
  } else {
    [self printData: data length: error];
  }
//  libusb_close( USBDeviceHandle );
}



- (IBAction) doBulkTransfer: (id) sender
{
  // unsigned char endpoint actually contains both the endpoint number in the lower bits,
  // and the direction in the uppermost bit
  //
  unsigned char endpoint  = [ bulkTransferDirection unsignedCharValue ] | [ bulkTransferEndpoint unsignedCharValue ];
  UInt16        wLength   = [ bulkTransferLength intValue ];
  int           actualLength;
  int           error;

  // I'm having problems with buffer overflow, so I bumped the size of data[]
  // quite considerable, but the problem won't go away
  //
  // TODO: figure out the problem with overflows
  //
  unsigned char data[16384];


  // See [ self doControlTransfer ] for an explanation of this, as
  // they are pretty similar.
  //
  if ( !( [ bulkTransferDirection unsignedCharValue ] & 0x80) ) {     // This is NOT an out transfer, therefor it's an IN transfer

    NSString      *inputString    = [ inputTextStorage string ];
    NSData        *inputData      = [ NSData dataFromHexString: inputString ];
    NSUInteger    inputLength     = [ inputData length ];
    unsigned char *inputDataBytes = (unsigned char *) [ inputData bytes ];

    if (  inputLength < wLength ) {
      wLength = (int) inputLength;
      [[ userDefaultsController values ] setValue: [ NSNumber numberWithUnsignedInteger: inputLength ] forKey: CTDefault_bulkTransferLength_Key ];
    }
    // copy the data into a local (to this method) buffer. Can't remember why I did this,
    // and it might not be necessary.
    //
    memcpy(data, inputDataBytes, wLength);
  }

  // Give some feedback before the transfer.
  //
  [self printString: [ NSString stringWithFormat:
                      @"Bulk transfer VID=%04x PID=%4@ Endpoint=%02x Length=%d...\n",
                      [deviceVID unsignedIntValue],
                      devicePID,
                      endpoint,
                      wLength ]
      withTextColor: [ self consoleInformationTextColor ]];

  // See [ self doControlTransfer ] for an explanation of why this is stupid.
  //
  USBDeviceHandle = libusb_open_device_with_vid_pid(NULL, [deviceVID unsignedIntValue], [ devicePID unsignedIntValue ]);

  if ( USBDeviceHandle == NULL ) {
    [ self printString: @"ERROR: " withTextColor: [ self consoleErrorTextColor ]];
    [ self printString: @"Invalid VID or PID\n\n"];
    return;
  }

  // Check for error.
  //
  error = libusb_claim_interface( USBDeviceHandle, 0 );
  if ( error != 0) {
    [ self printLibUSBError: error withOperation: @"libusb_claim_interface" ];
  }

  // Do the bulk transfer.
  //
  error = libusb_bulk_transfer	(USBDeviceHandle,
                                 endpoint,
                                 data,
                                 wLength,
                                 &actualLength,
                                 1000 );

  // Check for error, or display feedback on success before printing the acual data.
  //
  if ( error < 0) {
    [ self printLibUSBError: error withOperation: @"libusb_bulk_transfer" ];
  } else {
    [ self printString: [ NSString stringWithFormat: @"...actual transfer length: %d\n", actualLength ] withTextColor: [ self consoleInformationTextColor ]];
    [self printData: data length: actualLength];
  }

  // Release the interface.
  //
  // TODO: read more on interfaces
  //
  error = libusb_release_interface(USBDeviceHandle, 0);
  // CHeck for error.
  //
  if ( error < 0) {
    [ self printLibUSBError: error withOperation: @"libusb_release_interface" ];
  }

  // Close the handle.
  //
//  libusb_close( USBDeviceHandle );
}



- ( IBAction) listAllAttachedUSBDevices:(id)sender
{
  rebuildingDeviceList = TRUE;
  
  
  if ( USBDeviceHandle != NULL ) {
    
    libusb_close( USBDeviceHandle );
  }
  
  // clear the deviceList
  NSRange range = NSMakeRange(0, [[deviceArrayController arrangedObjects] count]);
  [ deviceArrayController removeObjectsAtArrangedObjectIndexes: [ NSIndexSet indexSetWithIndexesInRange: range ]];

  UInt8   theBus;
  UInt8   theAddress;
  int     i;
  int     result;
  struct  libusb_device_descriptor  deviceDescriptor;
  struct  libusb_device_handle      *deviceHandle;
  struct  libusb_device             *theUSBDevice;

  // libusb_get_string_descriptor_ascii requires buffers to store
  // the string descriptor.
  const     int   stringDesciptorBufferLength = 64;
  unsigned  char  theManufacturerStringDescriptorBuffer [stringDesciptorBufferLength];
  unsigned  char  theDeviceStringDescriptorBuffer       [stringDesciptorBufferLength];

  NSString        *theManufacturer;
  NSString        *theDeviceName;

  // Get a list of all USB devices. Also, libusb_get_device_list
  // returns the total number of devices.
  //
  numberOfUSBDevices = libusb_get_device_list(NULL, &allUSBDevices);

  // Iterate through the list and print them to the console.
  //
  for ( i = 0; i < numberOfUSBDevices; i++ ) {
    theUSBDevice  = allUSBDevices[i];
    theBus        = libusb_get_bus_number(theUSBDevice);
    theAddress    = libusb_get_device_address(theUSBDevice);

    result = libusb_open( theUSBDevice,
                         &deviceHandle );
    if ( result == 0 ) {
      result = libusb_get_string_descriptor_ascii	( deviceHandle,
                                                   1,
                                                   theManufacturerStringDescriptorBuffer,
                                                   stringDesciptorBufferLength );
      if ( result >= 0 ) {
        // result >= 0, so not an error
        //
        // set last byte of the c string to 0 to make a correct null terminated string
        //
        theManufacturerStringDescriptorBuffer[result] = 0;
        theManufacturer = [ NSString stringWithCString: (const char *) theManufacturerStringDescriptorBuffer encoding:NSASCIIStringEncoding ];
      } else {
        // we got an error, and weren't able to get the string descriptor
        //
        theManufacturer = @"Unknown";
      }
      result = libusb_get_string_descriptor_ascii	( deviceHandle,
                                                   2,
                                                   theDeviceStringDescriptorBuffer,
                                                   stringDesciptorBufferLength );
      if ( result >= 0) {
        theDeviceName = [ NSString stringWithCString: (const char *) theDeviceStringDescriptorBuffer encoding:NSASCIIStringEncoding ];
      } else {
        theDeviceName = @"Unknown";
      }
      libusb_close( deviceHandle );
    }

    result = libusb_get_device_descriptor(theUSBDevice, &deviceDescriptor);
    if ( result >= 0) {
      CTUSBDevice *newUSBDevice = [ CTUSBDevice new ];
      [ newUSBDevice setDevice: theUSBDevice ];
      [ newUSBDevice setBus: [ NSNumber numberWithUnsignedChar: theBus ]];
      [ newUSBDevice setAddress: [ NSNumber numberWithUnsignedChar: theAddress ]];
      [ newUSBDevice setVID: [ NSNumber numberWithUnsignedInt: deviceDescriptor.idVendor ]];
      [ newUSBDevice setPID: [NSNumber numberWithUnsignedInt: deviceDescriptor.idProduct ]];
      [ newUSBDevice setManufacturerString: theManufacturer ];
      [ newUSBDevice setDeviceString: theDeviceName ];
      [ deviceArrayController addObject: newUSBDevice ];
    }
  }
  
  [ self printNewLine: 1 ];
  rebuildingDeviceList = FALSE;
}



- (void) tableViewSelectionDidChange: (NSNotification *) aNotification
{
  if ( rebuildingDeviceList)  {
    return;
  }
  NSLog(@"tableViewSelectionDidChange");
  NSInteger i = [ deviceTable selectedRow ];
  if ( i == -1) {
    [ self setDeviceVID: [ NSNumber numberWithInt: 0 ]];
    [ self setDevicePID: [ NSNumber numberWithInt: 0 ]];
    return;
  }
//  if ( USBDeviceHandle != NULL ) {
//    libusb_close( USBDeviceHandle );
//  }
  CTUSBDevice *selectedDevice = [ deviceArray objectAtIndex: i ];
  [ self setDeviceVID: [ selectedDevice VID ]];
  [ self setDevicePID: [ selectedDevice PID ]];
  USBDeviceHandle = libusb_open_device_with_vid_pid(NULL,
                                                    [ deviceVID unsignedIntValue ],
                                                    [ devicePID unsignedIntValue ] );
//  USBDeviceHandle = [ selectedDevice handle ];
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
    textColor = [ self consoleDataTextColor ];
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
  switch ( [ displayHexOrPlainText integerValue ] ) {
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
  [ self printString: @"ERROR: " withTextColor: [ self consoleErrorTextColor ]];
  [ self printString: @"LibUSB function " ];
  [ self printString: theOperation withTextColor: [ self consoleInformationTextColor ]];
  [ self printString: @" returned " ];
  [ self printString: [NSString stringWithCString: libusb_error_name(theError) encoding: NSUTF8StringEncoding ] withTextColor: [ self consoleInformationTextColor ]];
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






#pragma mark Shutdown

- (void) applicationWillTerminate:(NSNotification *)notification
{
  if ( USBDeviceHandle ) {
    libusb_close( USBDeviceHandle );
  }
  libusb_free_device_list(allUSBDevices, 1);    //free the list, unref the devices in it
  libusb_exit(NULL);                            //close the session
}




#pragma mark Delegates

- (BOOL) applicationShouldHandleReopen: (NSApplication *) theApplication
                     hasVisibleWindows: (BOOL) flag
{
  if( flag == NO){
		[mainWindow makeKeyAndOrderFront:self];
	}
	return YES;
}






@end