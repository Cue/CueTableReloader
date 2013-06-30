//
//  TableFullRandomViewController.m
//  CueTableReloader
//
//  Created by Aaron Sarazan on 6/29/13.
//  Copyright (c) 2013 Cue. All rights reserved.
//

#import "TableFullRandomViewController.h"

@implementation TableFullRandomViewController

- (NSUInteger)sections;
{
    return 1;
}

- (NSUInteger)rows;
{
    return 7;
}

- (void)mutate:(NSMutableArray *)objects;
{
    int from = arc4random_uniform([objects[0] count]);
    int to = arc4random_uniform([objects[0] count]);
    
    id move = objects[0][from];
    [objects[0] removeObjectAtIndex:from];
    [objects[0] insertObject:move atIndex:to];
}
@end
