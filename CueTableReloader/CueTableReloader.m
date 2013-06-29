//
//  CueTableReloader.m
//  CueUI
//
//  Created by Aaron Sarazan on 6/12/13.
//  Copyright (c) 2013 Cue. All rights reserved.
//

#import "CueTableReloader.h"

@implementation CueTableReloader {
    UITableView *_tableView;
    NSArray *_oldSections;
}

- (id)initWithTableView:(UITableView *)tableView;
{
    self = [super init];
    if (self) {
        _tableView = tableView;
        _reloadUnchangedRows = YES;
        _animateClear = NO;
        _animatePopulate = NO;
    }
    return self;
}

- (NSArray *)oldSections;
{
    return _oldSections;
}

- (void)reloadData:(NSArray *)sections animated:(BOOL)animated;
{
    if (![NSThread isMainThread]) {
        [NSException raise:@"MainThreadError" format:@"reloadData:animated: must be called from main thread"];
    }
    BOOL shouldAnimate = animated;
    
    // Don't animate clear actions by default.
    shouldAnimate &= (_animateClear || (sections.count && [sections[0] count]));
    
    // Don't animate populate actions by default.
    shouldAnimate &= (_animatePopulate || (_oldSections.count && [_oldSections[0] count]));
    
    if (!shouldAnimate) {
        [_tableView reloadData];
    } else {        
        // Apply a simple algorithm to each section.
        // It's very good at handling new and deleted rows, not so much with reorderings.
        // It will not catch cross-section moves, and doesn't handle section count changes well.
        for (int i = 0; i < sections.count || i < _oldSections.count; ++i) {
            
            NSArray *section, *oldSection;
            
            if (i < sections.count) {
                section = sections[i];
            } else {
                [_tableView deleteSections:[NSIndexSet indexSetWithIndex:i]
                          withRowAnimation:UITableViewRowAnimationNone];
                if (i == 0) {
                    [_tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                              withRowAnimation:UITableViewRowAnimationNone];
                }
                continue;
            }
            
            if (i < _oldSections.count) {
                oldSection = _oldSections[i];
            } else if (i > 0) {
                [_tableView insertSections:[NSIndexSet indexSetWithIndex:i]
                          withRowAnimation:UITableViewRowAnimationFade];
            }
            
            NSMutableSet *keys = [NSMutableSet setWithCapacity:oldSection.count];
            for (NSObject<CueTableItem> *item in section) {
                [keys addObject:item.tableItemKey];
            }
            
            NSMutableArray *deletions = [@[] mutableCopy];
            NSMutableArray *insertions = [@[] mutableCopy];
            NSMutableArray *reloads = [@[] mutableCopy];
            int oldIndex = 0;
            int newIndex = 0;
            int insertionIndex = 0;
            @try {
                while (1) {
                    if (oldIndex == oldSection.count && newIndex == section.count) {
                        break;
                    }
                    
                    NSIndexPath *insertPath = [NSIndexPath indexPathForRow:insertionIndex inSection:i];
                    NSIndexPath *deletePath = [NSIndexPath indexPathForRow:oldIndex inSection:i];
                    NSIndexPath *reloadPath = [NSIndexPath indexPathForRow:insertionIndex inSection:i];
                    
                    NSObject<CueTableItem> *oldItem = nil;
                    if (oldIndex < oldSection.count) { // Delete
                        oldItem = oldSection[oldIndex];
                        if (![keys containsObject:oldItem.tableItemKey]) {
                            [deletions addObject:deletePath];
                            oldIndex++;
                            continue;
                        }
                    } else { // Insert
                        [insertions addObject:insertPath];
                        newIndex++;
                        insertionIndex++;
                        continue;
                    }
                    
                    NSObject<CueTableItem> *newItem = nil;
                    if (newIndex < section.count) {
                        newItem = section[newIndex];
                        if ([oldItem isEqual:newItem]) { // Unchanged. Reload.
                            [reloads addObject:reloadPath];
                            oldIndex++;
                            newIndex++;
                            insertionIndex++;
                            continue;
                        } else { // Insert
                            [insertions addObject:insertPath];
                            newIndex++;
                            insertionIndex++;
                            continue;
                        }
                    } else { // newEvents.contains should have caught this first.
                        [NSException raise:@"InvalidTableTransform" format:
                         @"Something went wrong! Check that you have unique keys for your cells!"];
                    }
                }
                [_tableView beginUpdates];
                [_tableView deleteRowsAtIndexPaths:deletions withRowAnimation:UITableViewRowAnimationNone];
                [_tableView insertRowsAtIndexPaths:insertions withRowAnimation:UITableViewRowAnimationFade];
                [_tableView endUpdates];
                if (_reloadUnchangedRows) {
                    [_tableView reloadRowsAtIndexPaths:reloads withRowAnimation:UITableViewRowAnimationNone];
                }
            } @catch (NSException *e) {
                [_tableView reloadData];
            }
        }
    } 
    _oldSections = [sections copy];
}

@end
