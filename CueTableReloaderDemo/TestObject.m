//
//  TestObject.m
//  CueTableReloader
//
//  Created by Aaron Sarazan on 6/29/13.
//  Copyright (c) 2013 Cue. All rights reserved.
//

#import "TestObject.h"

static const NSUInteger kMinHeight = 10;
static const NSUInteger kMaxHeight = 80;

@implementation UIColor (TableTesting)

+ (UIColor *)randomColor;
{
    float red = (float)arc4random() / (float)UINT32_MAX;
    float green = (float)arc4random() / (float)UINT32_MAX;
    float blue = (float)arc4random() / (float)UINT32_MAX;
    float alpha = 1.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (uint32_t)rgba;
{
    static const int red = 0;
    static const int green = 1;
    static const int blue = 2;
    static const int alpha = 3;
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    uint32_t r = (uint32_t)(components[red] * 255);
    uint32_t g = (uint32_t)(components[green] * 255);
    uint32_t b = (uint32_t)(components[blue] * 255);
    uint32_t a = (uint32_t)(components[alpha] * 255);
    
    uint32_t retval = 0;
    retval |= (r << 24);
    retval |= (g << 16);
    retval |= (b << 8);
    retval |= (a << 0);
    
    return retval;
}

@end

@implementation TestObject

- (id)init;
{
    return [self initWithColor:[UIColor randomColor] height:(arc4random() % (kMaxHeight - kMinHeight)) + kMinHeight];
}

- (id)initWithColor:(UIColor *)color height:(CGFloat)height;
{
    self = [super init];
    if (self) {
        _color = color;
        _height = height;
    }
    return self;
}

- (NSObject<NSCopying> *)tableItemKey;
{
    return [NSString stringWithFormat:@"%@_%f", _color, _height];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"[%.0f] 0x%xff", _height, _color.rgba];
}

@end
