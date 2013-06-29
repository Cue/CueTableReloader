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
    return 3;
}

- (void)mutate:(NSMutableArray *)objects;
{
    int removeFrom = [objects[0] count] - 2;
    id last = objects[0][removeFrom];
    [objects[0] removeObjectAtIndex:removeFrom];
    [objects[0] insertObject:last atIndex:0];
}

@end
