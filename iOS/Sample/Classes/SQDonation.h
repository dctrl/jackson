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


@class SQTerminalRequest;
@class SQMoney;

@interface SQDonation : NSObject

@property (nonatomic, readonly) SQTerminalRequest *terminalRequest;

@property (nonatomic, readonly) BOOL isEmpty;
@property (nonatomic, copy) SQMoney *amount;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *street2;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, copy) NSString *employer;
@property (nonatomic, copy) NSString *occupation;

+ (SQDonation *)donation;

- (void)clear;
- (void)clearExceptState;

@end
