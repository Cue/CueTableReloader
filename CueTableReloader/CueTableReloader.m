/*
 * Copyright 2013 CueTableReloader Authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
            
            NSArray *newSection, *oldSection;
            
            if (i < sections.count) {
                newSection = sections[i];
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
            
            NSMutableDictionary *newIndexes = [NSMutableDictionary dictionaryWithCapacity:newSection.count];
            for (int i = 0; i < oldSection.count; ++i) {
                NSObject<CueTableItem> *item = newSection[i];
                newIndexes[item.tableItemKey] = @(i);
            }
            
            NSMutableDictionary *oldIndexes = [NSMutableDictionary dictionaryWithCapacity:oldSection.count];
            for (int i = 0; i < oldSection.count; ++i) {
                NSObject<CueTableItem> *item = oldSection[i];
                oldIndexes[item.tableItemKey] = @(i);
            }
                        
            NSMutableArray *deletions = [@[] mutableCopy];
            NSMutableArray *insertions = [@[] mutableCopy];
            NSMutableArray *reloads = [@[] mutableCopy];
            NSMutableArray *moves = [@[] mutableCopy];
            int oldIndex = 0;
            int newIndex = 0;
            int insertionIndex = 0;
            @try {
                while (1) {
                    if (oldIndex == oldSection.count && newIndex == newSection.count) {
                        break;
                    }
                    
                    NSIndexPath *insertPath = [NSIndexPath indexPathForRow:insertionIndex inSection:i];
                    NSIndexPath *deletePath = [NSIndexPath indexPathForRow:oldIndex inSection:i];
                    NSIndexPath *reloadPath = [NSIndexPath indexPathForRow:insertionIndex inSection:i];
                                        
                    NSObject<CueTableItem> *oldItem = nil;
                    if (oldIndex < oldSection.count) { // Delete
                        oldItem = oldSection[oldIndex];
                        if (!newIndexes[oldItem.tableItemKey]) {
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
                    if (newIndex < newSection.count) {
                        newItem = newSection[newIndex];
                        if ([oldItem isEqual:newItem]) { // Unchanged. Reload.
                            [reloads addObject:reloadPath];
                            oldIndex++;
                            newIndex++;
                            insertionIndex++;
                            continue;
                        } else {
                            NSNumber *mappedOldIndex = oldIndexes[oldItem.tableItemKey];
                            if (mappedOldIndex) { // Move
                                NSNumber *mappedNewIndex = newIndexes[oldItem.tableItemKey];
                                NSInteger diff = mappedNewIndex.integerValue - mappedOldIndex.integerValue;
                                NSIndexPath *from = [NSIndexPath indexPathForRow:oldIndex inSection:i];
                                NSIndexPath *to = [NSIndexPath indexPathForRow:oldIndex+diff inSection:i];
                                [moves addObject:@[ from, to ]];
                                oldIndex++;
                                newIndex++;
                            } else { // Insert
                                [insertions addObject:insertPath];
                                newIndex++;
                                insertionIndex++;
                            }
                            continue;
                        }
                    } else { // newEvents.contains should have caught this first.
                        [NSException raise:@"InvalidTableTransform" format:
                         @"Something went wrong! Check that you have unique keys for your cells, "
                         "and that the ordering is constant!"];
                    }
                }
                [_tableView beginUpdates];
                [_tableView deleteRowsAtIndexPaths:deletions
                                  withRowAnimation:UITableViewRowAnimationNone];
                [_tableView insertRowsAtIndexPaths:insertions
                                  withRowAnimation:UITableViewRowAnimationFade];
                for (NSArray *pair in moves) {
                    [_tableView moveRowAtIndexPath:pair[0] toIndexPath:pair[1]];
                }
                [_tableView endUpdates];
                if (_reloadUnchangedRows) {
                    [_tableView reloadRowsAtIndexPaths:reloads
                                      withRowAnimation:UITableViewRowAnimationNone];
                }
            } @catch (NSException *e) {
                [_tableView reloadData];
            }
        }
    }
    NSMutableArray *deepCopy = [NSMutableArray arrayWithCapacity:sections.count];
    for (NSArray *section in sections) {
        [deepCopy addObject:[section copy]];
    }
    _oldSections = deepCopy;
}

@end
