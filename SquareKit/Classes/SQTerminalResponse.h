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


/*!
 @enum SQTerminalResponseStatus
 @abstract Possible responses from the Square application.
 @constant SQTerminalResponseStatusCancelled Indicates the payment was cancelled by the user.
 @constant SQTerminalResponseStatusSuccessful Indicates the payment was completed successfully.
 @constant SQTerminalResponseStatusError Indicates the payment was not completed, and there was at least one error.
 */
typedef enum {
    SQTerminalResponseStatusCancelled,
    SQTerminalResponseStatusSuccessful,
    SQTerminalResponseStatusError,
} SQTerminalResponseStatus;

/*!
 @class SQTerminalResponse
 @abstract Encapsulates a URL response from the Square application.
 @discussion An SQTerminalResponse should be initialized from the callback URL called by Square, passed to the UIApplication delegate upon launch. This data is passed in application:didFinishLaunchingWithOptions: inside of the launchOptions dictionary as well as application:openURL:sourceApplication:annotation:
 */
@interface SQTerminalResponse : NSObject

/*!
 @method terminalResponseWithLaunchOptions:
 @discussion This methods creates and initializes a response from a callback URL inside of the launchOptions dictionary.
 @param launchOptions The launchOptions dictionary passed to the UIApplication delegate in didFinishLaunchingWithOptions.
 @result An SQTerminalResponse instance or nil.
 */
+ (SQTerminalResponse *)terminalResponseWithLaunchOptions:(NSDictionary *)launchOptions;

/*!
 @method terminallResponseWithOpenURL:
 @discussion This methods creates and initializes a response from a callback URL directly.
 @param openURL The URL passed to the UIApplication delegate.
 @result An SQTerminalResponse instance or nil.
 */
+ (SQTerminalResponse *)terminallResponseWithOpenURL:(NSURL *)openURL;

/*!
 @property status
 @discussion The status of the response. See SQTerminalResponseStatus for the possible values.
 */
@property (nonatomic, readonly) SQTerminalResponseStatus status;

/*!
 @property transactionID
 @discussion Square's unique identifier for the transaction. Present only if the transaction was completed successfully.
 */
@property (nonatomic, copy, readonly) NSString *transactionID;

/*!
 @property referenceID
 @discussion Reference ID provided by the API client in the original request, present only when a ReferenceID was set.
 */
@property (nonatomic, copy, readonly) NSString *referenceID;

/*!
 @property errors
 @discussion An array of NSError objects that describe any errors with the payment, or nil if there are none.
 */
@property (nonatomic, retain, readonly) NSArray *errors;

- (id)initWithLaunchOptions:(NSDictionary *)launchOptions;
- (id)initWithOpenURL:(NSURL *)openURL;

/*!
 @method successful
 @discussion The status of the response, this is a convenience method for checking the status property against the successful transaction enum value.
 @result A boolean indicating whether or not payment completed successfully.
 */
- (BOOL)successful;

@end
