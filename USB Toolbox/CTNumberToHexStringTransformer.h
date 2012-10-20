//
//  CTNumberToHexStringTransformer.h
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/17/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTNumberToHexStringTransformer : NSValueTransformer

+ (Class) transformedValueClass;
+ (BOOL)  allowsReverseTransformation;

/**
 Transforms a number into a hex string without the 0x, and no leading zeros.
 @param value, an number
 @returns a hex formatted NSString
 */
- (id) transformedValue: (id) value;

/**
 Transforms a hex formatted NSString into an NSNumber.
 @param value a hex formatted NSString
 @returns an NSNumber
 */
- (id) reverseTransformedValue: (id) value;

@end
