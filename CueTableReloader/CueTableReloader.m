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

@interface CueTableReloader () {
    UITableView *_tableView;
    NSArray *_oldSections;
}

@end

@implementation CueTableReloader

- (id)initWithTableView:(UITableView *)tableView {
    self = [super init];
    
    if (self) {
        _tableView = tableView;
        _reloadUnchangedRows = YES;
        _animateClear = NO;
        _animatePopulate = NO;
        _insertAnimation = UITableViewRowAnimationRight;
        _deleteAnimation = UITableViewRowAnimationLeft;
        _updateAnimation = UITableViewRowAnimationNone;
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
                          withRowAnimation: _deleteAnimation];
                if (i == 0) {
                    [_tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                              withRowAnimation:_insertAnimation];
                }
                continue;
            }
            
            if (i < _oldSections.count) {
                oldSection = _oldSections[i];
            } else if (i > 0) {
                [_tableView insertSections:[NSIndexSet indexSetWithIndex:i]
                          withRowAnimation:_insertAnimation];
            }
            
            NSMutableDictionary *newIndexes = [NSMutableDictionary dictionaryWithCapacity:newSection.count];
            for (int i = 0; i < newSection.count; ++i) {
                NSObject<CueTableItem> *item = newSection[i];
                newIndexes[item.tableItemKey] = @(i);
            }
            
            NSMutableDictionary *oldIndexes = [NSMutableDictionary dictionaryWithCapacity:oldSection.count];
            for (int i = 0; i < oldSection.count; ++i) {
                NSObject<CueTableItem> *item = oldSection[i];
                oldIndexes[item.tableItemKey] = @(i);
            }
            
            NSMutableSet *deletions = [NSMutableSet set];
            NSMutableSet *insertions = [NSMutableSet set];
            NSMutableSet *reloads = [NSMutableSet set];
            NSMutableSet *moves = [NSMutableSet set];
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
                            if (oldIndexes[newItem.tableItemKey]) { // Move
                                NSInteger iOld = [oldIndexes[oldItem.tableItemKey] integerValue];
                                NSInteger iNew = [newIndexes[oldItem.tableItemKey] integerValue];
                                NSInteger diff = iNew - iOld;
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
                
                NSMutableSet *updatedReloads = [NSMutableSet set];
                
                // Find intersecting index paths in deletions
                for (id obj in deletions) {
                    if ([insertions containsObject: obj]) {
                        [updatedReloads addObject: obj];
                    }
                }
                
                // Find intersecting index paths in insertions
                for (id obj in insertions) {
                    if ([deletions containsObject: obj]) {
                        [updatedReloads addObject: obj];
                    }
                }
                
                NSMutableSet *deletionsCopy = [deletions mutableCopy];
                NSMutableSet *insertionsCopy = [insertions mutableCopy];
                [deletions minusSet: insertionsCopy];
                [insertions minusSet: deletionsCopy];
                deletionsCopy = nil;
                insertionsCopy = nil;
                
                [_tableView beginUpdates];
                [_tableView deleteRowsAtIndexPaths:[deletions allObjects]
                                  withRowAnimation:_deleteAnimation];
                [_tableView insertRowsAtIndexPaths:[insertions allObjects]
                                  withRowAnimation:_insertAnimation];
                for (NSArray *pair in moves) {
                    [_tableView moveRowAtIndexPath:pair[0] toIndexPath:pair[1]];
                }
                [_tableView endUpdates];
                if (_reloadUnchangedRows) {
                    [_tableView reloadRowsAtIndexPaths:[reloads allObjects]
                                      withRowAnimation:_updateAnimation];
                }
                
                // Reload updated index paths based on intersecting index paths above (if applicable)
                [_tableView reloadRowsAtIndexPaths:[updatedReloads allObjects] withRowAnimation: _updateAnimation];
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