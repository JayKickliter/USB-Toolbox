//
//  CTUSBDevice.m
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/21/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import "CTUSBDevice.h"

@implementation CTUSBDevice

@synthesize bus;
@synthesize address;
@synthesize VID;
@synthesize PID;
@synthesize manufacturer;
@synthesize device;


- (id) init
{
  self = [ super init ];
  return self;
}

@end
