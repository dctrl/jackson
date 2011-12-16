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

#import "SQTerminalResponse.h"
#import "SquareKit.h"
#import "NSError-SQAdditions.h"
#import "NSURL-SQAdditions.h"


// Constants
static NSString *SQStatusKey = @"square_status";
static NSString *SQTransactionIDKey = @"square_transaction_id";
static NSString *SQTransactionErrorsKey = @"square_errors";
static NSString *SQStatusCancelledString = @"cancelled";
static NSString *SQStatusSuccessfulString = @"successful";
static NSString *SQStatusErrorString = @"error";


@interface SQTerminalResponse ()

@property (nonatomic, readwrite) SQTerminalResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *transactionID;
@property (nonatomic, copy, readwrite) NSString *referenceID;
@property (nonatomic, retain, readwrite) NSArray *errors;

@end


@implementation SQTerminalResponse

@synthesize status;
@synthesize transactionID;
@synthesize referenceID;
@synthesize errors;

#pragma mark Class Methods

+ (SQTerminalResponse *)terminalResponseWithLaunchOptions:(NSDictionary *)launchOptions;
{
    return [[[[self class] alloc] initWithLaunchOptions:launchOptions] autorelease];
}

+ (SQTerminalResponse *)terminallResponseWithOpenURL:(NSURL *)openURL;
{
    return [[[[self class] alloc] initWithOpenURL:openURL] autorelease];
}

#pragma mark Initialization

- (id)initWithLaunchOptions:(NSDictionary *)launchOptions;
{
    // unpack URL from launchOptions, parse it
    NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (!launchURL) {
        [self release];
        return nil;
    }
    
    return [self initWithOpenURL:launchURL];
}

- (id)initWithOpenURL:(NSURL *)openURL;
{
    if (!openURL || !(self = [super init])) {
        [self release];
        return nil;
    }
    
    NSDictionary *queryParameters = [openURL queryParameters];
    
    NSString *SQStatusString = [queryParameters objectForKey:SQStatusKey];
    if ([SQStatusString isEqualToString:SQStatusCancelledString]) {
        status = SQTerminalResponseStatusCancelled;
    } else if ([SQStatusString isEqualToString:SQStatusSuccessfulString]) {
        status = SQTerminalResponseStatusSuccessful;
    } else if ([SQStatusString isEqualToString:SQStatusErrorString]) {
        status = SQTerminalResponseStatusError;
    }
    
    self.transactionID = [queryParameters objectForKey:SQTransactionIDKey];
    
    // unpack error codes
    NSString *errorCodesString = [queryParameters objectForKey:SQTransactionErrorsKey];
    if (errorCodesString.length) {
        NSMutableArray *errorsArray = [NSMutableArray array];
        
        for (NSString *URLAPIErrorCode in [errorCodesString componentsSeparatedByString:@","]) {
            [errorsArray addObject:[NSError errorWithURLAPIErrorCode:URLAPIErrorCode]];
        }
        
        self.errors = errorsArray;
    }
    
    return self;
}

- (void)dealloc;
{
    self.transactionID = nil;
    
    [super dealloc];
}

#pragma mark Accessors/Mutators

- (BOOL)successful;
{
    return (self.status == SQTerminalResponseStatusSuccessful);
}

@end
