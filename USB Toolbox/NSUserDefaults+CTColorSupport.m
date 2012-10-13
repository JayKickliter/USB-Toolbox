//
//  NSUserDefaults+CTColorSupport.m
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/11/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import "NSUserDefaults+CTColorSupport.h"

@implementation NSUserDefaults (CTColorSupport)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey
{
  NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
  [self setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey
{
  NSColor *theColor=nil;
  NSData *theData=[self dataForKey:aKey];
  if (theData != nil)
    theColor=(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
  return theColor;
}

@end
