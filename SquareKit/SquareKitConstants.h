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

#import <Foundation/Foundation.h>

enum {
    SQUnknownError,
    SQAppNotInstalledError,
    SQMissingParameterError,
    SQInvalidParameterError,
};

extern NSString *const SQErrorDomain;

extern NSString *const SQAppStoreLink;

extern NSString *const SQTerminalAmountParameter;
extern NSString *const SQTerminalCurrencyParameter;
extern NSString *const SQTerminalCallbackURLParameter;
extern NSString *const SQTerminalDescriptionParameter;
extern NSString *const SQTerminalDefaultEmailParameter;
extern NSString *const SQTerminalDefaultPhoneParameter;
extern NSString *const SQTerminalReferenceIDParameter;
extern NSString *const SQTerminalofferReceiptParameter;
extern NSString *const SQTerminalMetadataParameter;
extern NSString *const SQTerminalToParameter;
extern NSString *const SQTerminalAPIVersionParameter;
extern NSString *const SQTerminalAppIDParameter;

extern NSString *const SQTerminalErrorCodeAmountMissing;
extern NSString *const SQTerminalErrorCodeAmountInvalidFormat;
extern NSString *const SQTerminalErrorCodeAmountTooSmall;
extern NSString *const SQTerminalErrorCodeAmountTooLarge;
extern NSString *const SQTerminalErrorCodeAppIDInvalid;
extern NSString *const SQTerminalErrorCodeAppIDMissing;
extern NSString *const SQTerminalErrorCodeCurrencyMissing;
extern NSString *const SQTerminalErrorCodeCurrencyNotSupported;
extern NSString *const SQTerminalErrorCodeDescriptionTooLong;
extern NSString *const SQTerminalErrorCodeMetadataTooLong;
extern NSString *const SQTerminalErrorCodeReferenceIDTooLong;
extern NSString *const SQTerminalErrorCodeToInvalidRecipient;

extern const NSUInteger SQTerminalDescriptionMaximumLength;
extern const NSUInteger SQTerminalMetadataMaximumNumberOfBytes;
extern const NSUInteger SQTerminalReferenceIDMaximumLength;
