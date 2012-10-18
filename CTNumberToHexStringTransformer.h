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
- (id)    transformedValue:       (id) value;
- (id)    reverseTransformedValue:  (id) value;

@end
