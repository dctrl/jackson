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

#import "SQDonationConfirmationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SQDonation.h"
#import "SQMoney.h"
#import "SQTerminalRequest.h"


@interface SQDonationConfirmationViewController ()

- (void)_updateUIFromModel;
- (void)_releaseOutlets;

@end

@implementation SQDonationConfirmationViewController

@synthesize scrollView;
@synthesize formView;
@synthesize legaleseView;

@synthesize name;
@synthesize email;
@synthesize street;
@synthesize cityStateZip;
@synthesize employer;
@synthesize occupation;
@synthesize donationAmount;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)dealloc;
{
    [self _releaseOutlets];
    
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    const CGFloat verticalHeightOffset = 44.0f;
    self.scrollView.contentSize = CGSizeMake(self.formView.bounds.size.width, self.formView.bounds.size.height + verticalHeightOffset);
    
    // Don't scale the background texture on 2x screens.
    UIImage *patternImage = [UIImage imageNamed:@"Background.png"];
    patternImage = [UIImage imageWithCGImage:[patternImage CGImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    self.legaleseView.layer.cornerRadius = 6.0f;
    
    [self _updateUIFromModel];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidUnload;
{
    [super viewDidUnload];
    
    [self _releaseOutlets];
}

#pragma mark - Actions

-(IBAction)agree:(id)sender;
{
    SQTerminalRequest *terminalRequest = [SQDonation donation].terminalRequest;
    
    NSError *error = nil;
    if (![terminalRequest send:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error") message:[error.userInfo objectForKey:NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel") otherButtonTitles:nil];        
        [alertView show];
        [alertView release];
    }
}

-(IBAction)disagree:(id)sender;
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Methods

- (void)_releaseOutlets;
{
    self.scrollView = nil;
    self.formView = nil;
    self.legaleseView = nil;
    
    self.name = nil;
    self.email = nil;
    self.street = nil;
    self.cityStateZip = nil;
    self.employer = nil;
    self.occupation = nil;
    self.donationAmount = nil;
}

- (void)_updateUIFromModel;
{
    SQDonation *donation = [SQDonation donation];
    
    self.donationAmount.text = [donation.amount displayValue];
    self.name.text = [NSString stringWithFormat:@"%@ %@", donation.firstName, donation.lastName.length ? donation.lastName : @""];
    self.email.text = donation.email;
    self.street.text = donation.street;
    self.cityStateZip.text = [NSString stringWithFormat:@"%@, %@ %@", donation.city, donation.state, donation.zip];
    self.employer.text = donation.employer;
    self.occupation.text = donation.occupation;
}

@end
