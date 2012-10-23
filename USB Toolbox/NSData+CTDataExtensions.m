//
//  NSData+CTDataExtensions.m
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/22/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import "NSData+CTDataExtensions.h"

@implementation NSData (CTDataExtensions)

+ (NSData *) dataFromHexString: (NSString *) theString
{
  unsigned int i;
  NSScanner     *scanner    = [ NSScanner scannerWithString: theString ];
  NSMutableData *returnData = [ NSMutableData new ];

	while ([scanner isAtEnd] == NO)
	{
		if([scanner scanHexInt: &i] && i <= 255 )
		{
			[ returnData appendBytes: &i length: 1 ];
		}
		else
			return nil;
	}
  return returnData;
}

@end
