//
//  TableReorderViewController.m
//  CueTableReloader
//
//  Created by Aaron Sarazan on 6/29/13.
//  Copyright (c) 2013 Cue. All rights reserved.
//

#import "TableReorderViewController.h"

@implementation TableReorderViewController

- (NSUInteger)sections;
{
    return 1;
}

- (NSUInteger)rows;
{
    return 5;
}

- (void)mutate:(NSMutableArray *)objects;
{
    int from = [objects[0] count] - 2;
    int to = 1;
    
    id move = objects[0][from];
    [objects[0] removeObjectAtIndex:from];
    [objects[0] insertObject:move atIndex:to];
}

@end
