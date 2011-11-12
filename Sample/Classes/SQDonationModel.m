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

#import "SQDonationModel.h"
#import "SQMoney.h"
#import "SQTerminalConstants.h"
#import "JSONKit.h"
#import "SQTerminalRequest.h"

//
// Simple: Let there just be a single global model that tracks the entire donation start to finish.
//
static SQDonationModel *theModel;


@implementation SQDonationModel

@synthesize isEmpty;
@synthesize amount;
@synthesize name;
@synthesize email;
@synthesize street;
@synthesize street2;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize employer;
@synthesize occupation;

-(id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    [self clear];
    
    return self;
}

-(void)dealloc
{
    self.amount = nil;
    self.name = nil;
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

+(SQDonationModel *)theDonation
{
    if (theModel == nil)
    {
        theModel = [[SQDonationModel alloc] init];
    }
    
    return theModel;
}

- (void)clear
{
    [self clearExceptState];
    self.state = @"";
}

- (void)clearExceptState
{
    self.amount = [SQMoney money];
    self.name = @"";
    self.email = @"";
    self.employer = @"";
    self.street = @"";
    self.street2 = @"";
    self.city = @"";
    self.zip = @"";
    self.employer = @"";
    self.occupation = @"";
}

- (NSString *)_terminalRequestMetadata
{
    NSMutableDictionary *metadataDict = [NSMutableDictionary dictionary];
    [metadataDict setValue:self.name forKey:@"name"];
    [metadataDict setValue:self.email forKey:@"email"];
    
    NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
    [addressDictionary setValue:self.street forKey:@"street"];
    [addressDictionary setValue:self.street2 forKey:@"street2"];
    [addressDictionary setValue:self.city forKey:@"city"];
    [addressDictionary setValue:self.state forKey:@"state"];
    [addressDictionary setValue:self.zip forKey:@"zip"];
    [metadataDict setValue:addressDictionary forKey:@"address"];
    
    NSMutableDictionary *employmentDictionary = [NSMutableDictionary dictionary];
    [employmentDictionary setValue:self.employer forKey:@"employer"];
    [employmentDictionary setValue:self.occupation forKey:@"occupation"];
    [metadataDict setValue:employmentDictionary forKey:@"employment"];
    
    return [metadataDict JSONString];
}

- (SQTerminalRequest *)terminalRequest
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


@end
