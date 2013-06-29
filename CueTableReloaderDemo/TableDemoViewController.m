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

#import "TableDemoViewController.h"
#import "CueTableReloader.h"

@implementation UIColor (TableTesting)

+ (UIColor *)randomColor;
{
    float red = (float)rand() / (float)INT32_MAX;
    float green = (float)rand() / (float)INT32_MAX;
    float blue = (float)rand() / (float)INT32_MAX;
    float alpha = 1.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSObject<NSCopying> *)tableItemKey;
{
    return self;
}

@end

/**
 * Container that specifies a color and height
 */
@interface TestObject : NSObject <CueTableItem>

/**
 * Color
 */
@property (readonly) UIColor *color;

/**
 * Height
 */
@property (readonly) CGFloat height;

@end

static const NSUInteger kMinHeight = 10;
static const NSUInteger kMaxHeight = 80;

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

@end

static const int kNumSections = 3;
static const int kNumRows = 5; // per section

@implementation TableDemoViewController {
    NSMutableArray *_objects;
    CueTableReloader *_reloader;
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    _objects = [@[] mutableCopy];

    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    tableView.frame = self.view.bounds;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _reloader = [[CueTableReloader alloc] initWithTableView:tableView];
    
    [self _populate];
    
    [self performSelector:@selector(_mutateSlightly) withObject:nil afterDelay:1.0f];
}

- (void)_populate;
{
    [_objects removeAllObjects];
    for (int i = 0; i < kNumSections; ++i) {
        NSMutableArray *section = [@[] mutableCopy];
        for (int j = 0; j < kNumRows; ++j) {
            [section addObject:[[TestObject alloc] init]];
        }
        [_objects addObject:section];
    }
    [_reloader reloadData:_objects animated:YES];
}

- (void)_mutateSlightly;
{
    NSInteger numberToModify = 3;
    int i = 0;
    while (i++ < numberToModify) {
        NSUInteger section = arc4random() % kNumSections;
        NSUInteger row = arc4random() % kNumRows;
        NSMutableArray *sectionArray = _objects[section];
        [sectionArray replaceObjectAtIndex:row withObject:[[TestObject alloc] init]];
    }
    [_reloader reloadData:_objects animated:YES];
    [self performSelector:@selector(_mutateSlightly) withObject:nil afterDelay:1.0f];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *retval = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!retval) {
        retval = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    retval.contentView.backgroundColor = [_objects[indexPath.section][indexPath.row] color];
    return retval;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return _objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [_objects[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    return [NSString stringWithFormat:@"%d", section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [_objects[indexPath.section][indexPath.row] height];
}

@end
