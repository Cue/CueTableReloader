//
//  TableRandomViewController.m
//  CueTableReloader
//
//  Created by Aaron Sarazan on 6/29/13.
//  Copyright (c) 2013 Cue. All rights reserved.
//

#import "TableRandomViewController.h"

@implementation TableRandomViewController

- (NSUInteger)sections;
{
    return 3;
}

- (NSUInteger)rows;
{
    return 5;
}

- (void)mutate:(NSMutableArray *)objects;
{
    NSInteger numberToModify = 5;
    int i = 0;
    while (i++ < numberToModify) {
        NSUInteger section = arc4random() % [self sections];
        NSUInteger row = arc4random() % [self rows];
        NSMutableArray *sectionArray = objects[section];
        [sectionArray replaceObjectAtIndex:row withObject:[[TestObject alloc] init]];
    }
}
@end
