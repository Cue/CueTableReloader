
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

#import <UIKit/UIKit.h>

/**
 * A really handy logic object that automatically figures out
 * insertions, deletions, and reloads in UITableView based on unique item keys.
 */
@interface CueTableReloader : NSObject

/**
 * Preferred method of initialization.
 */
- (id)initWithTableView:(UITableView *)tableView;

/**
 * Reload with new data. It will automatically store this array to compare in the next reloadData: call.
 * @param sections This is a two-level array. The top level is sections, each of which is an array of rows.
 */
- (void)reloadData:(NSArray *)sections animated:(BOOL)animated;

/**
 * Copy of the sections list from the last time you reloaded.
 */
- (NSArray *)oldSections;

/**
 * Default: YES
 * If you know that pre-existing rows aren't subject to change, set this to NO and skip reloading them.
 */
@property (nonatomic, assign) BOOL reloadUnchangedRows;

/**
 * Default: NO
 * By default, setting an empty array will not animate.
 */
@property (nonatomic, assign) BOOL animateClear;

/**
 * Default: NO
 * By default, setting data for the first time will not animate.
 */
@property (nonatomic, assign) BOOL animatePopulate;

/**
 * Default: UITableViewRowAnimationLeft
 * Animation for a table row insert.
 */
@property (nonatomic, assign) UITableViewRowAnimation insertAnimation;

/**
 * Default: UITableViewRowAnimationRight
 * Animation for a table row delete.
 */
@property (nonatomic, assign) UITableViewRowAnimation deleteAnimation;

/**
 * Default: UITableViewRowAnimationFade
 * Animation for a table row update.
 */
@property (nonatomic, assign) UITableViewRowAnimation updateAnimation;

@end


/**
 * Every row object must implement this protocol.
 */
@protocol CueTableItem <NSObject>
@required

/**
 * Key must not change over the life of the object.
 */
- (NSObject<NSCopying> *)tableItemKey;

@end