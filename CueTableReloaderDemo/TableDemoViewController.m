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
#import "TestObject.h"

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
    [self populate:_objects];
    [_reloader reloadData:_objects animated:YES];    
    [self performSelector:@selector(_mutate) withObject:nil afterDelay:1.0f];
}

- (void)_mutate;
{
    [self mutate:_objects];
    [_reloader reloadData:_objects animated:YES];
    [self performSelector:@selector(_mutate) withObject:nil afterDelay:1.0f];
}

- (void)populate:(NSMutableArray *)objects;
{
    [objects removeAllObjects];
    for (int i = 0; i < [self sections]; ++i) {
        NSMutableArray *section = [@[] mutableCopy];
        for (int j = 0; j < [self rows]; ++j) {
            [section addObject:[[TestObject alloc] init]];
        }
        [objects addObject:section];
    }
}

- (void)mutate:(NSMutableArray *)objects;
{
    // Subclass
}

- (NSUInteger)sections;
{
    return 0; // Subclass
}

- (NSUInteger)rows;
{
    return 0; // Subclass
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
