//
//  CueTableReloader.h
//  CueUI
//
//  Created by Aaron Sarazan on 6/12/13.
//  Copyright (c) 2013 Cue. All rights reserved.
//

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
@property BOOL reloadUnchangedRows;

/**
 * Default: NO
 * By default, setting an empty array will not animate.
 */
@property BOOL animateClear;

/**
 * Default: NO
 * By default, setting data for the first time will not animate.
 */
@property BOOL animatePopulate;


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