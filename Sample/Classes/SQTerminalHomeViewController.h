//
// Copyright 2011 Square Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>

@interface SQTerminalHomeViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIScrollView *scroller;
@property (nonatomic, retain) IBOutlet UIView       *formView;

@property (nonatomic, retain) IBOutlet UITextField  *donationAmount;
@property (nonatomic, retain) IBOutlet UITextField  *name;
@property (nonatomic, retain) IBOutlet UITextField  *email;
@property (nonatomic, retain) IBOutlet UITextField  *street;
@property (nonatomic, retain) IBOutlet UITextField  *city;
@property (nonatomic, retain) IBOutlet UITextField  *state;
@property (nonatomic, retain) IBOutlet UITextField  *zip;
@property (nonatomic, retain) IBOutlet UITextField  *employer;
@property (nonatomic, retain) IBOutlet UITextField  *occupation;

@property (nonatomic, retain) IBOutlet UIButton     *contributeButton;

-(IBAction)fieldDidBeginEditing:(id)sender;
-(IBAction)fieldDidChange:(id)sender;
-(IBAction)continuePressed:(id)sender;


@end
