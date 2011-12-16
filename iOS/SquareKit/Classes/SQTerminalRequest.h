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
#import "SquareKit.h"


@class SQMoney;

/*!
 @class SQTerminalRequest
 @abstract Encapsulates a URL request to the Square application.
 @discussion An SQTerminalRequest instance will pre-fill a payment in the Square application. Use the properties to configure this request.
*/
@interface SQTerminalRequest : NSObject 

/*!
 @method request
 @result An SQTerminalRequest instance
 */
+ (SQTerminalRequest *)request;

/*!
 @method terminalScheme
 @result The scheme that should be used by requests.  This is determined by different Square builds found on the system.
 */
+ (NSString *)terminalScheme;

/*!
 @method blankRequestURL
 @result An NSURL object containing a blank Square Terminal URL request. This object can be used to check if Square is installed by using the UIApplication canOpenURL method
 */
+ (NSURL *)blankRequestURL;

/*!
 @property amount
 @discussion Required. An SQMoney object that describes the total value (and currency) of a payment. 
 */
@property (nonatomic, copy) SQMoney *amount;

/*!
 @property callbackURL
 */
@property (nonatomic, copy) NSURL *callbackURL;

/*!
 @property description
 */
@property (nonatomic, copy) NSString *description;

/*!
 @property defaultEmail
 */
@property (nonatomic, copy) NSString *defaultEmail;

/*!
 @property defaultPhone
 */
@property (nonatomic, copy) NSString *defaultPhone;

/*!
 @property referenceID
 */
@property (nonatomic, copy) NSString *referenceID;

/*!
 @property offerReceipt
 */
@property (nonatomic) BOOL offerReceipt;

/*!
 @property metadata
 */
@property (nonatomic, copy) NSString *metadata;

/*!
 @property to
 */
@property (nonatomic, copy) NSString *to;

/*!
 @property appID
 */
@property (nonatomic, copy) NSString *appID;

/*!
 @method send:
 @abstract Initiates a Square payment
 @discussion This method will build a request URL and attempt to open it in the Square application.
 @param error If an error occurs, will contain an NSError object that contains the error. Pass nil if you do not want error information.
 @result Returns YES if the request was successfully sent, NO otherwise.
*/
- (BOOL)send:(NSError **)error;

/*!
 @method URLRepresentation
 @abstract A URL Representation of the Terminal Request
 @discussion Builds a URL that conforms to the Square Terminal API specification from the current configuration of the SQTerminalRequest instance.
 @param error If an error occurs, will contain an NSError object that contains the error. Pass nil if you do not want error information.
 @result A URL that represents the current SQTerminalRequest instance, or nil if there is some sort of error.
*/
- (NSURL *)URLRepresentation:(NSError **)error;

@end
