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

#import "SampleAppDelegate.h"
#import "NSURL-SQAdditions.h"
#import "SQDonation.h"
#import "SQDonationFormViewController.h"
#import "SquareKit.h"


@interface SampleAppDelegate ()

- (void)_handleTerminalResponse:(SQTerminalResponse *)terminalResponse;

@end

@implementation SampleAppDelegate

@synthesize window;
@synthesize navController;

#pragma mark - Initialization

- (void)dealloc;
{
    self.window = nil;
    self.navController = nil;
    
    [super dealloc];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{    
    SQDonationFormViewController *homeViewController = [[SQDonationFormViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    self.navController = navigationController;
    
    [navigationController release];
    [homeViewController release];
    
    self.navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window addSubview:self.navController.view];
    [self.window makeKeyAndVisible];
    
    // Pull the launch URL to begin creating the terminal response.
    NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (launchURL) {
        [self application:application handleOpenURL:launchURL];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
{
    // Create a terminalResponse from the calling URL.
    SQTerminalResponse *terminalResponse = [SQTerminalResponse terminallResponseWithOpenURL:url];
    if (terminalResponse) {
        [self _handleTerminalResponse:terminalResponse];
        return YES;
    }
    
    return NO;
}

#pragma mark Private Methods

- (void)_handleTerminalResponse:(SQTerminalResponse *)terminalResponse;
{
    if (!terminalResponse) {
        return;
    }
    
    NSString *alertTitle = nil;
    NSString *alertMessage = nil;
    
    switch (terminalResponse.status) {
        case SQTerminalResponseStatusSuccessful:
            alertTitle = NSLocalizedString(@"Thanks!", @"thanks");
            alertMessage = NSLocalizedString(@"Square payment completed successfully.", @"payment completed successfully");
            
            // Donation completed successfully-- clear out the app state except for the state, which is
            // likely to remain the same so treat it as a pre-fill. 
            [[SQDonation donation] clearExceptState];
            [self.navController popToRootViewControllerAnimated:NO];
            
            break;
            
        case SQTerminalResponseStatusError:
            if (!terminalResponse.errors.count) {
                alertTitle = NSLocalizedString(@"Error", @"error");
                alertMessage = @"";
            } else if (terminalResponse.errors.count == 1) {
                alertTitle = [[terminalResponse.errors objectAtIndex:0] localizedDescription];
                alertMessage = [[terminalResponse.errors objectAtIndex:0] localizedRecoverySuggestion];                
            } else {
                alertTitle = NSLocalizedString(@"Multiple Errors Occurred", @"multiple errors");
                alertMessage = [[terminalResponse.errors valueForKey:@"localizedRecoverySuggestion"] componentsJoinedByString:@"\n"];
            }
            break;
            
        case SQTerminalResponseStatusCancelled:
            // For cancelled transactions, we choose not to show an alert, but just leave the view as-is.
            // We can split hairs about whether it makes more sense to clear out the state
            // to prevent the next user from seeing personal information, or whether it makes sense
            // to keep it around in order to re-do after the cancel.
            break;
    }
    
    if (alertTitle && alertMessage) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles:nil] autorelease];
        [alertView show];
    }
}

@end
