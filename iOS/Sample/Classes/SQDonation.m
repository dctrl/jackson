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

#import "SQDonation.h"
#import "SQConstants.h"
#import "SQMoney.h"
#import "SQTerminalRequest.h"


@interface SQDonation () 

- (NSString *)_terminalRequestMetadata;
- (NSString *)_sanitizedValueForString:(NSString *)string;
    
@end

@implementation SQDonation

@synthesize isEmpty;
@synthesize amount;
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize street;
@synthesize street2;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize employer;
@synthesize occupation;

#pragma mark - Initialization

+(SQDonation *)donation;
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SQDonation alloc] init];
    });
    
    return sharedInstance;
}

-(id)init;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self clear];
    
    return self;
}

-(void)dealloc;
{
    self.amount = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.email = nil;
    self.street = nil;
    self.street2 = nil;
    self.city = nil;
    self.state = nil;
    self.zip = nil;
    self.employer = nil;
    self.occupation = nil;
    
    [super dealloc];
}

#pragma mark - Accessors

- (SQTerminalRequest *)terminalRequest;
{
    SQTerminalRequest *terminalRequest = [SQTerminalRequest request];
    
    terminalRequest.callbackURL = [NSURL URLWithString:@"sq-sample://callback"];
    terminalRequest.appID = SQTerminalAppID;
    terminalRequest.to = SQTerminalRecipientKey;
    terminalRequest.offerReceipt = YES;
    
    terminalRequest.amount = self.amount;
    terminalRequest.defaultEmail = self.email;
    terminalRequest.description = SQTerminalDescription;
    
    terminalRequest.metadata = [self _terminalRequestMetadata];
    
    return terminalRequest;
}

#pragma mark - Public methods

- (void)clear;
{
    [self clearExceptState];
    self.state = @"";
}

- (void)clearExceptState;
{
    self.amount = [SQMoney money];
    self.firstName = @"";
    self.lastName = @"";
    self.email = @"";
    self.employer = @"";
    self.street = @"";
    self.street2 = @"";
    self.city = @"";
    self.zip = @"";
    self.employer = @"";
    self.occupation = @"";
}

#pragma mark - Private methods

- (NSString *)_terminalRequestMetadata;
{
    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    [metadata setValue:[self _sanitizedValueForString:self.firstName] forKey:@"firstName"];
    [metadata setValue:[self _sanitizedValueForString:self.lastName] forKey:@"lastName"];
    [metadata setValue:[self _sanitizedValueForString:self.email] forKey:@"email"];
    
    NSMutableDictionary *address = [NSMutableDictionary dictionary];
    [address setValue:[self _sanitizedValueForString:self.street] forKey:@"street"];
    [address setValue:[self _sanitizedValueForString:self.street2] forKey:@"street2"];
    [address setValue:[self _sanitizedValueForString:self.city] forKey:@"city"];
    [address setValue:[self _sanitizedValueForString:self.state] forKey:@"state"];
    [address setValue:[self _sanitizedValueForString:self.zip] forKey:@"zip"];
    [metadata setValue:address forKey:@"address"];
    
    NSMutableDictionary *employment = [NSMutableDictionary dictionary];
    [employment setValue:[self _sanitizedValueForString:self.employer] forKey:@"employer"];
    [employment setValue:[self _sanitizedValueForString:self.occupation] forKey:@"occupation"];
    [metadata setValue:employment forKey:@"employment"];

    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:metadata options:0 error:&error];
    if (error) {
        NSLog(@"Error encoding metadata to JSON: %@", error);
        return nil;
    }
    
    return [[[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *)_sanitizedValueForString:(NSString *)string;
{
    if (string.length) {
        return string;
    }
    
    return @"";
}

@end
