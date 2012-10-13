//
//  NSUserDefaults+CTColorSupport.h
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/11/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (CTColorSupport)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;

- (NSColor *)colorForKey:(NSString *)aKey;

@end
