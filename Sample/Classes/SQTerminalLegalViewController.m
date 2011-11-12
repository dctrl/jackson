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

#import "SQTerminalLegalViewController.h"
#import "SQDonationModel.h"
#import "SQMoney.h"
#import "SQTerminalRequest.h"
#import <QuartzCore/QuartzCore.h>

@interface SQTerminalLegalViewController(private)

- (void)_load;

@end

@implementation SQTerminalLegalViewController

@synthesize scroller;
@synthesize formView;

@synthesize name;
@synthesize email;
@synthesize street;
@synthesize cityStateZip;
@synthesize employer;
@synthesize occupation;
@synthesize donationAmount;

#pragma mark - Init

- (void)releaseOutlets
{
    self.scroller = nil;
    self.formView = nil;
    
    self.name = nil;
    self.street = nil;
    self.cityStateZip = nil;
    self.employer = nil;
    self.occupation = nil;
    self.donationAmount = nil;
}

- (void)dealloc
{
    [self releaseOutlets];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.scroller.contentSize = CGSizeMake(self.formView.bounds.size.width, self.formView.bounds.size.height + 44);
    
    UIImage *patternImage = [UIImage imageNamed:@"bg.png"];
    self.scroller.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    UIView *legaleseView = [self.view viewWithTag:100];
    legaleseView.layer.cornerRadius = 6.0f;
    
    [self _load];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];    
    [self releaseOutlets];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Model/View binding

- (void)_load
{
    self.donationAmount.text = [[SQDonationModel theDonation].amount displayValue];
    self.name.text = [SQDonationModel theDonation].name;
    self.email.text = [SQDonationModel theDonation].email;
    self.street.text = [SQDonationModel theDonation].street;
    
    self.cityStateZip.text = [NSString stringWithFormat:@"%@, %@ %@",
                              [SQDonationModel theDonation].city,
                              [SQDonationModel theDonation].state,
                              [SQDonationModel theDonation].zip];
    
    self.employer.text = [SQDonationModel theDonation].employer;
    self.occupation.text = [SQDonationModel theDonation].occupation;
}

#pragma mark - Actions

-(IBAction)agreePressed:(id)sender
{
    SQTerminalRequest *terminalRequest = [SQDonationModel theDonation].terminalRequest;
    
    NSError *error = nil;
    if (![terminalRequest send:&error])
    {
        // show an alert upon failure
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error")
                                                            message:[error.userInfo objectForKey:NSLocalizedDescriptionKey]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel")
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

-(IBAction)disagreePressed:(id)sender
{
    //
    // Not much to say, go back!
    //
    [self.navigationController popViewControllerAnimated:YES];
}


@end
