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

#import "NSError-SQAdditions.h"
#import "SquareKit.h"


NSString *const SQTerminalErrorCodeKey = @"terminalErrorCode";


@interface NSString (SQAdditions)

+ (NSString *)localizedMissingFieldErrorDescription:(NSString *)fieldName;
+ (NSString *)localizedMissingFieldErrorRecoverySuggestion:(NSString *)fieldName;

@end


@implementation NSError (SQAdditions)

+ (NSError *)errorWithMissingURLAPIParameter:(NSString *)fieldName;
{
    NSString *errorDescription = [NSString localizedMissingFieldErrorDescription:fieldName];
    NSString *localizedRecoverySuggestion = [NSString localizedMissingFieldErrorRecoverySuggestion:fieldName];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, localizedRecoverySuggestion, NSLocalizedRecoverySuggestionErrorKey, nil];

    return [NSError errorWithDomain:SQErrorDomain code:SQMissingParameterError userInfo:userInfo];
}

+ (NSError *)errorWithURLAPIErrorCode:(NSString *)URLAPIErrorCode;
{
    NSInteger code = 0;
    NSString *localizedDescription = nil;
    NSString *localizedRecoverySuggestion = nil;
    
    // expand limited URL descriptions into full NSError objects
    if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeAmountMissing]) {
        code = SQMissingParameterError;
        localizedDescription = [NSString localizedMissingFieldErrorDescription:SQTerminalAmountParameter];
        localizedRecoverySuggestion = [NSString localizedMissingFieldErrorRecoverySuggestion:SQTerminalAmountParameter];
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeAmountInvalidFormat]) {
        code = SQInvalidParameterError;
        localizedDescription = NSLocalizedString(@"Invalid amount format", @"invalid amount format");
        localizedRecoverySuggestion = NSLocalizedString(@"Make sure to format the amount with the right number of decimal places for the locale. For USD, 1.00 is valid but 1 is not", @"invalid amount format recovery suggestion");
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeAmountTooSmall]) {
        code = SQInvalidParameterError;
        localizedDescription = NSLocalizedString(@"Amount too small", @"amount too small");
        localizedRecoverySuggestion = NSLocalizedString(@"The amount entered was too small for Square to process, enter a larger amount.", @"amount too small recovery suggestion");
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeAmountTooLarge]) {
        code = SQInvalidParameterError;
        localizedDescription = NSLocalizedString(@"Amount too large", @"amount too large");
        localizedRecoverySuggestion = NSLocalizedString(@"The amount entered was too large for Square to process, enter a smaller amount.", @"amount too large recovery suggestion");
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeAppIDInvalid]) {
        code = SQInvalidParameterError;
        localizedDescription = NSLocalizedString(@"App ID invalid", @"app id invalid");
        localizedRecoverySuggestion = NSLocalizedString(@"The app id supplied was invalid.", @"app id invalid recovery suggestion");
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeAppIDMissing]) {
        code = SQMissingParameterError;
        localizedDescription = [NSString localizedMissingFieldErrorDescription:SQTerminalAppIDParameter];
        localizedRecoverySuggestion = [NSString localizedMissingFieldErrorRecoverySuggestion:SQTerminalAppIDParameter];
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeCurrencyMissing]) {
        code = SQMissingParameterError;
        localizedDescription = [NSString localizedMissingFieldErrorDescription:SQTerminalCurrencyParameter];
        localizedRecoverySuggestion = [NSString localizedMissingFieldErrorRecoverySuggestion:SQTerminalCurrencyParameter];
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeCurrencyNotSupported]) {
        code = SQInvalidParameterError;
        localizedDescription = NSLocalizedString(@"Currency not supported", @"currency not supported");
        localizedRecoverySuggestion = NSLocalizedString(@"The currency supplied is not currently supported by Square. Refer to the online documentation for a list of currently supported currencies.", @"currency not supported recovery suggestion");
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeDescriptionTooLong]) {
        code = SQInvalidParameterError;
        localizedDescription = NSLocalizedString(@"Description too long", @"description too long");
        localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"Description supplied exceeded %d characters, please use a shorter description.", @"description too long recovery suggestion format"), SQTerminalDescriptionMaximumLength];
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeMetadataTooLong]) {
        code = SQInvalidParameterError;
        localizedDescription = NSLocalizedString(@"Metadata too long", @"metadata too long");
        localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"Metadata supplied exceeded %d characters, please attach shorter metadata.", @"metadata too long recovery suggestion format"), SQTerminalMetadataMaximumNumberOfBytes];
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeReferenceIDTooLong]) {
        code = SQInvalidParameterError;
        localizedDescription = NSLocalizedString(@"Reference ID too long", @"reference id too long");
        localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"Reference ID supplied exceeded %d characters, please attach a shorter Reference ID.", @"reference id too long recovery suggestion format"), SQTerminalReferenceIDMaximumLength];
    } else if ([URLAPIErrorCode isEqualToString:SQTerminalErrorCodeToInvalidRecipient]) {
        code = SQInvalidParameterError;
        localizedDescription = NSLocalizedString(@"To invalid recipient", @"to invalid recipient");
        localizedRecoverySuggestion = NSLocalizedString(@"The recipient supplied was invalid.", @"to invalid recipient recovery suggestion");
    } else {
        code = SQUnknownError;
        localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"Unknown Error: %@", @"unknown error"), URLAPIErrorCode];
        localizedRecoverySuggestion = NSLocalizedString(@"Please refer to the online documentation for assistance with this error" , @"unknown error recovery suggestion");
    }
    
    NSAssert1(localizedDescription, @"Expected a localized error description. URL API error code: %@", URLAPIErrorCode);
    NSAssert1(localizedDescription, @"Expected a localized error recovery suggestion. URL API error code: %@", URLAPIErrorCode);

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:localizedDescription, NSLocalizedDescriptionKey, localizedRecoverySuggestion, NSLocalizedRecoverySuggestionErrorKey, URLAPIErrorCode, SQTerminalErrorCodeKey, nil];
    
    return [NSError errorWithDomain:SQErrorDomain code:code userInfo:userInfo];
}

- (NSString *)terminalErrorCode;
{
    return [self.userInfo objectForKey:SQTerminalErrorCodeKey];
}

@end


@implementation NSString (SQAdditions)

+ (NSString *)localizedMissingFieldErrorDescription:(NSString *)fieldName;
{
    return [NSString stringWithFormat:NSLocalizedString(@"Request is missing required field: %@", @"missing required field format"), fieldName];
}

+ (NSString *)localizedMissingFieldErrorRecoverySuggestion:(NSString *)fieldName;
{
    return [NSString stringWithFormat:NSLocalizedString(@"Make sure to set the %@ field before sending your request", @"field missing suggestion format"), fieldName];
}


@end
