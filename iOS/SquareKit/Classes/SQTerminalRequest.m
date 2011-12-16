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

#import "SQTerminalRequest.h"
#import "NSError-SQAdditions.h"
#import "NSURL-SQAdditions.h"


NSString *const SQTerminalFormat = @"%@terminal/%@/pay?";
NSString *const SQTerminalAPIVersion = @"1.0";


NSString *const SQTerminalStringTooLongException = @"String Too Long";
NSString *const SQTerminalRequestMissingParameterException = @"Terminal API Request Missing Parameter";


@interface SQTerminalRequest ()

- (void)_copyString:(NSString *)inString toString:(NSString **)toString checkLength:(NSUInteger)length name:(NSString *)name;

@end


@implementation SQTerminalRequest

@synthesize amount;
@synthesize callbackURL;
@synthesize description;
@synthesize defaultEmail;
@synthesize defaultPhone;
@synthesize referenceID;
@synthesize offerReceipt;
@synthesize metadata;
@synthesize to;
@synthesize appID;

#pragma mark Class Methods

+ (SQTerminalRequest *)request;
{
    return [[[[self class] alloc] init] autorelease];
}

+ (NSURL *)blankRequestURL;
{
    return [NSURL URLWithString:[NSString stringWithFormat:SQTerminalFormat, [self terminalScheme], SQTerminalAPIVersion]];
}

+ (NSString *)terminalScheme;
{
    NSArray *possibleSchemes = [NSArray arrayWithObjects:@"square-debug://", @"square-alpha://", @"square-beta://", @"square://", nil];
    for (NSString *currentScheme in possibleSchemes) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[currentScheme stringByAppendingString:@"test"]]]) {
            return currentScheme;
        }
    }
    
    // Fall back to something, even if it doesn't exist on device, just so the other code can return an error
    return [possibleSchemes lastObject];
}

#pragma mark Initialization, etc.

- (id)init;
{
    if (!(self = [super init])) {
        return nil;
    }
    
    // default value
    self.offerReceipt = YES;
        
    return self;
}

- (void)dealloc;
{
    self.amount = nil;
    self.callbackURL = nil;
    self.description = nil;
    self.defaultEmail = nil;
    self.defaultPhone = nil;
    self.referenceID = nil;
    self.metadata = nil;
    self.to = nil;
    self.appID = nil;

    [super dealloc];
}

#pragma mark Accessors/Mutators

- (void)setDescription:(NSString *)inDescription;
{
    [self _copyString:inDescription toString:&description checkLength:SQTerminalDescriptionMaximumLength name:SQTerminalDescriptionParameter];
}

- (void)setMetadata:(NSString *)inMetadata;
{
    [self _copyString:inMetadata toString:&metadata checkLength:SQTerminalMetadataMaximumNumberOfBytes name:SQTerminalMetadataParameter];
}

- (void)setReferenceID:(NSString *)inReferenceID;
{
    [self _copyString:inReferenceID toString:&referenceID checkLength:SQTerminalReferenceIDMaximumLength name:SQTerminalReferenceIDParameter];
}

#pragma mark Request Methods

- (BOOL)send:(NSError **)error;
{
    NSURL *url = [self URLRepresentation:error];
    if (!url) {
        return NO;
    }
    
#if DEBUG 
    NSLog(@"Outgoing URL: %@", url.absoluteString);
#endif
    
    // check that Square.app is installed and send the request
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        [app openURL:url];
        return YES;
    }
    
    // Square.app is not installed
    if (error) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Square not installed on device", @"not installed error"), NSLocalizedDescriptionKey, nil];
        *error = [NSError errorWithDomain:SQErrorDomain code:SQAppNotInstalledError userInfo:userInfo];
    }

    return NO;
}

- (NSURL *)URLRepresentation:(NSError **)error;
{
    NSString *baseURLString = [NSString stringWithFormat:SQTerminalFormat, [[self class] terminalScheme], SQTerminalAPIVersion];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // required
    if (self.amount) {
        [parameters setObject:self.amount.stringValue forKey:SQTerminalAmountParameter];
        [parameters setObject:self.amount.currency forKey:SQTerminalCurrencyParameter];
    } else {
        if (error) {
            *error = [NSError errorWithMissingURLAPIParameter:SQTerminalAmountParameter];
        }
        return NO;
    }
    
    if (self.callbackURL) {
        [parameters setObject:self.callbackURL.absoluteString forKey:SQTerminalCallbackURLParameter];
    } else {
        if (error) {
            *error = [NSError errorWithMissingURLAPIParameter:SQTerminalCallbackURLParameter];
        }
    }
    
    if (self.description) {
        [parameters setObject:self.description forKey:SQTerminalDescriptionParameter];
    }
    
    if (self.defaultEmail) {
        [parameters setObject:self.defaultEmail forKey:SQTerminalDefaultEmailParameter];
    }
    
    if (self.defaultPhone) {
        [parameters setObject:self.defaultPhone forKey:SQTerminalDefaultPhoneParameter];
    }
    
    [parameters setObject:(self.offerReceipt ? @"true" : @"false") forKey:SQTerminalofferReceiptParameter];
    
    if (self.metadata) {
        [parameters setObject:self.metadata forKey:SQTerminalMetadataParameter];
    }
    
    if (self.to) {
        [parameters setObject:self.to forKey:SQTerminalToParameter];
    }
    
    // required
    if (self.appID) {
        [parameters setObject:self.appID forKey:SQTerminalAppIDParameter];
    } else {
        if (error) {
            *error = [NSError errorWithMissingURLAPIParameter:SQTerminalAppIDParameter];
        }
        return NO;
    }

    if (self.referenceID) {
        [parameters setObject:self.referenceID forKey:SQTerminalReferenceIDParameter];
    }
    
    return [[NSURL URLWithString:baseURLString] URLByAppendingQueryParameters:parameters];
}

#pragma mark Private Methods

- (void)_copyString:(NSString *)inString toString:(NSString **)toString checkLength:(NSUInteger)maxLength name:(NSString *)fieldName;
{
    if (inString && inString.length > maxLength) {
        NSString *reason = [NSString stringWithFormat:@"Attempted to set %@ with length %d longer than maximum length of %d", fieldName, inString.length, maxLength];
        
        [[NSException exceptionWithName:SQTerminalStringTooLongException reason:reason userInfo:nil] raise];
    }
    
    NSString *copy = [inString copy];
    [*toString release];
    *toString = copy;
}

@end

