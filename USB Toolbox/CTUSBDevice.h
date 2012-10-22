//
//  CTUSBDevice.h
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/21/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libusb.h"

@interface CTUSBDevice : NSObject

@property (readwrite) libusb_device_handle  *handle;
@property (readwrite) libusb_device         *device;
@property (retain)    NSNumber              *bus;
@property (retain)    NSNumber              *address;
@property (retain)    NSNumber              *VID;
@property (retain)    NSNumber              *PID;
@property (copy)      NSString              *manufacturerString;
@property (copy)      NSString              *deviceString;

@end
