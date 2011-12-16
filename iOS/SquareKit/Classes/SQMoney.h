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


// for dictionary representations
extern NSString *SQMoneyAmountKey;
extern NSString *SQMoneyCurrencyKey;


@interface SQMoney : NSObject <NSCoding, NSCopying> {
    NSString *currency;
    NSDecimalNumber *amount;
}

@property (nonatomic, readonly, retain) NSDecimalNumber *amount;
@property (nonatomic, readonly, retain) NSString *currency;

+ (SQMoney *)moneyWithAmount:(NSDecimalNumber *)amount currency:(NSString *)currency;
+ (SQMoney *)moneyWithDecimal:(NSDecimal)decimalAmount currency:(NSString *)currency;
+ (SQMoney *)moneyWithCents:(NSString *)cents currency:(NSString *)currency;
+ (SQMoney *)moneyWithString:(NSString *)inString currency:(NSString *)currency;
+ (SQMoney *)moneyByTotalingMoneyArray:(NSArray *)moneyList;
+ (SQMoney *)money; // Creates an empty money object defaulting to $0.00 USD

// Creates an empty money object defaulting to $0.00 USD
+ (SQMoney *)money;

// returns USD (United States Dollars)
+ (NSString *)defaultCurrency;
+ (void)setDefaultCurrency:(NSString *)inCurrency;

- (id)initWithAmount:(NSDecimalNumber *)inAmount currency:(NSString *)inCurrency;
- (id)initWithDecimal:(NSDecimal)decimalAmount currency:(NSString *)inCurrency;
- (id)initWithString:(NSString *)inAmount currency:(NSString *)inCurrency;

- (NSComparisonResult)compare:(SQMoney *)money;

- (NSString *)cents;
- (NSString *)displayValue;

// returns $1 if the amount is 1.00, or $1.50 if the amount is 1.50
- (NSString *)displayOptionalCentsValue;
- (NSString *)stringValue;

- (BOOL)isZero;
- (BOOL)hasSameCurrency:(SQMoney *)money;

- (SQMoney *)moneyByAdding:(NSString *)number;
- (SQMoney *)moneyByAddingMoney:(SQMoney *)money;
- (SQMoney *)moneyBySubtracting:(NSString *)number;
- (SQMoney *)moneyBySubtractingMoney:(SQMoney *)money;
- (SQMoney *)moneyByDividingBy:(NSString *)number;
- (SQMoney *)moneyByMultiplyingBy:(NSString *)number;
- (SQMoney *)moneyByMultiplyingByAmount:(NSDecimalNumber *)number;
- (SQMoney *)moneyByMultiplyingByPowerOf10:(short)number;
- (SQMoney *)percentOfMoney:(NSUInteger)percent; // 0-100 (whole)

- (SQMoney *)expectedMoneyTendered;

@end
