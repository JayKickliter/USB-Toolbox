//
//  CTUSBDevice.h
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/21/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTUSBDevice : NSObject

@property (retain)  NSNumber  *bus;
@property (retain)  NSNumber  *address;
@property (retain)  NSNumber  *VID;
@property (retain)  NSNumber  *PID;
@property (copy)    NSString  *manufacturer;
@property (copy)    NSString  *device;

@end
