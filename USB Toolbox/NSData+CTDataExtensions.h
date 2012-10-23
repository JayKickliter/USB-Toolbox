//
//  NSData+CTDataExtensions.h
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/22/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CTDataExtensions)


/**
 Convers a hex formatted NSString to NSData.

 The string should have byte sized hex symbols speperated by spaces, with or without leading a `0x'. Leading zeros are optional.

 A valid example: `0xdE ad Fe ed 0xA 0xb c 0d`.

 @param theString
 @returns NSData
*/

+ (NSData *) dataFromHexString: (NSString *) theString;




@end
