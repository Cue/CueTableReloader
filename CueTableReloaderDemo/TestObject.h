//
//  TestObject.h
//  CueTableReloader
//
//  Created by Aaron Sarazan on 6/29/13.
//  Copyright (c) 2013 Cue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CueTableReloader.h"

/**
 * Container that specifies a color and height
 */
@interface TestObject : NSObject <CueTableItem>

/**
 * Color
 */
@property (readonly) UIColor *color;

/**
 * Height
 */
@property (readonly) CGFloat height;

@end