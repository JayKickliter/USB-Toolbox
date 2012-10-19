//
//  CTNumberToHexStringTransformer.m
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/17/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import "CTNumberToHexStringTransformer.h"

@implementation CTNumberToHexStringTransformer

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
  unsigned long long theInt;
  NSScanner* scanner = [ NSScanner scannerWithString: value ];

  [ scanner scanHexLongLong: &theInt ];

  return [ NSNumber numberWithUnsignedLongLong: theInt];
}

- (id)transformedValue:(id)value {
	if(value == nil ) return nil;

  NSNumber *number = value;

  NSString *returnString = [ NSString stringWithFormat: @"%llx", [ number longLongValue ]];

  return returnString;
}


@end
