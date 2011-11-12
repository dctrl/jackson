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

#import "SquareKitConstants.h"

NSString *const SQErrorDomain = @"Square";

NSString *const SQAppStoreLink = @"https://squareup.com/app";

NSString *const SQTerminalAmountParameter = @"amount";
NSString *const SQTerminalCurrencyParameter = @"currency";
NSString *const SQTerminalCallbackURLParameter = @"callback";
NSString *const SQTerminalDescriptionParameter = @"description";
NSString *const SQTerminalDefaultEmailParameter = @"default_email";
NSString *const SQTerminalDefaultPhoneParameter = @"default_phone";
NSString *const SQTerminalReferenceIDParameter = @"reference_id";
NSString *const SQTerminalofferReceiptParameter = @"offer_receipt";
NSString *const SQTerminalMetadataParameter = @"metadata";
NSString *const SQTerminalToParameter = @"to";
NSString *const SQTerminalAPIVersionParameter = @"api_version";
NSString *const SQTerminalAppIDParameter = @"app_id";

NSString *const SQTerminalErrorCodeAmountMissing = @"amount_missing";
NSString *const SQTerminalErrorCodeAmountInvalidFormat = @"amount_invalid_format";
NSString *const SQTerminalErrorCodeAmountTooSmall = @"amount_too_small";
NSString *const SQTerminalErrorCodeAmountTooLarge = @"amount_too_large";
NSString *const SQTerminalErrorCodeAppIDInvalid = @"app_id_invalid";
NSString *const SQTerminalErrorCodeAppIDMissing = @"app_id_missing";
NSString *const SQTerminalErrorCodeCurrencyMissing = @"currency_missing";
NSString *const SQTerminalErrorCodeCurrencyNotSupported = @"currency_not_supported";
NSString *const SQTerminalErrorCodeDescriptionTooLong = @"description_too_long";
NSString *const SQTerminalErrorCodeMetadataTooLong = @"metadata_too_long";
NSString *const SQTerminalErrorCodeReferenceIDTooLong = @"reference_id_too_long";
NSString *const SQTerminalErrorCodeToInvalidRecipient = @"to_invalid_recipient";

const NSUInteger SQTerminalDescriptionMaximumLength = 140;
const NSUInteger SQTerminalMetadataMaximumNumberOfBytes = 4096;
const NSUInteger SQTerminalReferenceIDMaximumLength = 256;

