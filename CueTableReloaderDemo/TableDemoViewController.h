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
#import "TestObject.h"
#import "CueTableReloader.h"

/**
 * Quick and dirty visual test for the lib
 */
@interface TableDemoViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

- (void)populate:(NSMutableArray *)objects;

- (void)mutate:(NSMutableArray *)objects;

- (NSUInteger)sections;

- (NSUInteger)rows;

@end
