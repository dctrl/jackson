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

#import "SQTerminalHomeViewController.h"
#import "SQDonationModel.h"
#import "SQMoney.h"
#import "SQTerminalLegalViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SQTerminalHomeViewController(private)

- (void)_load;
- (void)_save;

- (void)_validateFields;
- (BOOL)_fieldsValid;

- (void)_scootToFirstResponderAnimated:(BOOL)animated;
- (void)_scootToField:(UITextField *)textField animated:(BOOL)animated;

@end

@implementation SQTerminalHomeViewController

@synthesize scroller;
@synthesize formView;

@synthesize donationAmount;
@synthesize name;
@synthesize email;
@synthesize street;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize employer;
@synthesize occupation;

@synthesize contributeButton;

#pragma mark - Init

- (void)releaseOutlets
{
    self.scroller = nil;
    self.formView = nil;
    
    self.donationAmount = nil;
    self.name = nil;
    self.email = nil;
    self.street = nil;
    self.city = nil;
    self.state = nil;
    self.zip = nil;
    self.employer = nil;
    self.occupation = nil;
    
    self.contributeButton = nil;
}

- (void)addKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)dealloc
{
    [self removeKeyboardObservers];
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
    
    self.navigationItem.title = @"Donate";
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.scroller.contentSize = self.formView.bounds.size;
    
    UIImage *patternImage = [UIImage imageNamed:@"bg.png"];
    self.scroller.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    NSArray *subViews = self.formView.subviews;
    for (UIView *subView in subViews)
    {
        if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *) subView;
            
            textField.borderStyle = UITextBorderStyleRoundedRect;
        }
    }
    
    UIView *legaleseView = [self.view viewWithTag:100];
    legaleseView.layer.cornerRadius = 6.0f;
    
    [self _load];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self _load];
    
    if ([[SQDonationModel theDonation].amount isZero])
    {
        // If we are about to display with a zero donation amount, treat this as a clean form--
        // scroll up to to show the logo, resign all first responders to drop the keyboard.
        
        NSArray *subViews = self.formView.subviews;
        for (UIView *subView in subViews)
        {
            if ([subView isKindOfClass:[UITextField class]])
            {
                UITextField *textField = (UITextField *) subView;
                
                [textField resignFirstResponder];
            }
        }
        
        self.scroller.contentOffset = CGPointZero;
    }
    else
    {
        [self _scootToFirstResponderAnimated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self addKeyboardObservers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeKeyboardObservers];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self _save];
    
    [self removeKeyboardObservers];
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
    self.city.text = [SQDonationModel theDonation].city;
    self.state.text = [SQDonationModel theDonation].state;
    self.zip.text = [SQDonationModel theDonation].zip;
    self.employer.text = [SQDonationModel theDonation].employer;
    self.occupation.text = [SQDonationModel theDonation].occupation;
    
    [self _validateFields];
}

- (void)_save
{
    // Amount is kept up to date as the user types because SQMoney doesn't parse display strings.
    [SQDonationModel theDonation].name = [self.name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SQDonationModel theDonation].email = [self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SQDonationModel theDonation].street = [self.street.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SQDonationModel theDonation].city = [self.city.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SQDonationModel theDonation].state = [self.state.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SQDonationModel theDonation].zip = [self.zip.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SQDonationModel theDonation].employer = [self.employer.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SQDonationModel theDonation].occupation = [self.occupation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Field editing magic

-(IBAction)fieldDidBeginEditing:(id)sender
{
    [self _scootToField:sender animated:YES];
}

-(IBAction)fieldDidChange:(id)sender
{
    // On any edits, revalidate fields.
    [self _validateFields];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != self.donationAmount)
    {
        // Allow free edits to all fields other than the donation amount, or any edit where
        // the replacement string is empty.
        return YES;
    }
    else
    {
        SQMoney *amount = [SQDonationModel theDonation].amount;
        NSString *centsString = [amount cents];
        
        if ([string length] == 1)
        {
            // Someone typed a digit, append that to the number of cents and stuff it back in.
            amount = [SQMoney moneyWithCents:[centsString stringByAppendingString:string] currency:[SQMoney defaultCurrency]];
        }
        
        if ([string length] == 0)
        {
            // Someone wants to remove a digit, kill the last digit of the cents and stuff it back in.
            amount = [SQMoney moneyWithCents:[centsString substringToIndex:[centsString length] - 1] currency:[SQMoney defaultCurrency]];        
        }
        
        // Save back the amount to the model immediately.
        [SQDonationModel theDonation].amount = amount;
        self.donationAmount.text = [amount displayValue];
        
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder)
    {
        [nextResponder becomeFirstResponder];
    }
    else if ([self _fieldsValid])
    {
        [self continuePressed:nil];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return NO; // We do not want UITextField to insert line-breaks.
}

#pragma mark - Keyboarding

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    //
    // Reduce the scroller at the same rate as the keyboard is coming up.
    //
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                            CGRect scrollerFrame = self.scroller.frame;
                            scrollerFrame.size.height -= kbSize.height;
                            self.scroller.frame = scrollerFrame;
                        }
                     completion:nil];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect scrollerFrame = self.scroller.frame;
    scrollerFrame.size.height += kbSize.height;
    self.scroller.frame = scrollerFrame;
}

#pragma mark - Actions

-(IBAction)continuePressed:(id)sender
{
    [self _save];
    
    SQTerminalLegalViewController *legalViewController = [[[SQTerminalLegalViewController alloc] init] autorelease];
    
    [self.navigationController pushViewController:legalViewController animated:YES];
}

#pragma mark - Privates

- (void)_validateFields
{    
    self.contributeButton.enabled = [self _fieldsValid];
}

- (BOOL)_fieldsValid
{
    // We need a positive contribution amount and all fields must be populated.
    
    BOOL isValid = YES;
    
    NSArray *subViews = self.formView.subviews;
    for (UIView *subView in subViews)
    {
        if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *) subView;
            
            if ([textField.text length] == 0)
            {
                isValid = NO;
            }
        }
    }
    
    if ([[SQDonationModel theDonation].amount isZero])
    {
        isValid = NO;
    }
    
    return isValid;
}

- (void)_scootToFirstResponderAnimated:(BOOL)animated
{
    NSArray *subViews = self.formView.subviews;
    for (UIView *subView in subViews)
    {
        if ([subView isFirstResponder] && [subView isKindOfClass:[UITextField class]])
        {
            [self _scootToField:(UITextField *)subView animated:NO];
        }
    }
}

- (void)_scootToField:(UITextField *)textField animated:(BOOL)animated
{
    CGFloat contentHeight = MIN(textField.frame.origin.y - 80, self.scroller.contentSize.height - self.scroller.bounds.size.height);
    
    [self.scroller setContentOffset:CGPointMake(0, contentHeight) animated:animated];
}


@end
