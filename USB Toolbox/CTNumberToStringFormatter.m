//
//  CTNumberToStringFormatter.m
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/17/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import "CTNumberToStringFormatter.h"

@implementation CTNumberToStringFormatter

+ (Class)transformedValueClass
{
	return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)reverseTransformedValue:(id)value {
  if(value == nil ) return nil;

  return [ NSNumber numberWithLongLong: [ (NSString *) value longLongValue]];
}

- (id)transformedValue:(id)value {
	if(value == nil ) return nil;

  return [ NSString stringWithFormat: @"%@", value ];
}

@end
