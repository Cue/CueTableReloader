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

#import "IntroViewController.h"
#import "TableReorderViewController.h"
#import "TableRandomViewController.h"
#import "TableFullRandomViewController.h"

@implementation IntroViewController

- (IBAction)randomReplace:(id)sender;
{
    UIViewController *vc = [[TableRandomViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)basicReorder:(id)sender;
{
    UIViewController *vc = [[TableReorderViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];    
}

- (IBAction)jazzyRandom:(id)sender;
{
    UIViewController *vc = [[TableFullRandomViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];    
}

@end
