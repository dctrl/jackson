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


@interface SQDonationConfirmationViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *formView;
@property (nonatomic, retain) IBOutlet UIView *legaleseView;

@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *email;
@property (nonatomic, retain) IBOutlet UILabel *street;
@property (nonatomic, retain) IBOutlet UILabel *cityStateZip;
@property (nonatomic, retain) IBOutlet UILabel *employer;
@property (nonatomic, retain) IBOutlet UILabel *occupation;
@property (nonatomic, retain) IBOutlet UILabel *donationAmount;

-(IBAction)agree:(id)sender;
-(IBAction)disagree:(id)sender;

@end
