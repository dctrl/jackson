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

#import "SQMoney.h"


// Constants
NSString *SQMoneyAmountKey = @"amount";
NSString *SQMoneyCurrencyKey = @"currency";


// Helper additions
@interface NSString (SQMoneyAdditions)

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet;

@end

@interface NSCharacterSet (SQMoneyAdditions)

+ (NSCharacterSet *)numericCharacterSet; // only 0 thru 9
+ (NSCharacterSet *)notNumericCharacterSet; // anything but 0 thru 9

@end


// Private Methods
@interface SQMoney ()

@property (nonatomic, retain) NSDecimalNumber *amount;
@property (nonatomic, retain) NSString *currency;

@end


@implementation SQMoney

@synthesize currency;
@synthesize amount;

#pragma mark Static Methods

static NSNumberFormatter *currencyFormatter = nil;
static NSNumberFormatter *numberFormatter = nil;
static NSDecimalNumberHandler *roundingHandler = nil;
static NSString *defaultCurrency = nil;

+ (void)initialize;
{
    if (self == [SQMoney class]) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setCurrencySymbol:@""];
        [numberFormatter setCurrencyDecimalSeparator:@"."];
        [numberFormatter setCurrencyGroupingSeparator:@""];

        // this is set to plain rounding for now until we decide how to handle
        // bankers rounding calculations between the client and the server
        roundingHandler = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundBankers scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    }
}

+ (SQMoney *)moneyWithAmount:(NSDecimalNumber *)amount currency:(NSString *)currency;
{
    return [[[[self class] alloc] initWithAmount:amount currency:currency] autorelease];
}

+ (SQMoney *)moneyWithDecimal:(NSDecimal)decimalAmount currency:(NSString *)currency;
{
    if (NSDecimalIsNotANumber(&decimalAmount)) {
        return [SQMoney money];
    }
    
    return [[[[self class] alloc] initWithDecimal:decimalAmount currency:currency] autorelease];
}

+ (SQMoney *)moneyWithCents:(NSString *)cents currency:(NSString *)currency;
{
    NSString *moneyString = nil;

    if (cents.length == 0) {
        moneyString = @"0.00";
    } else if (cents.length == 1) {
        moneyString = [NSString stringWithFormat:@"0.0%@", cents];
    } else if (cents.length == 2) {
        moneyString = [NSString stringWithFormat:@"0.%@", cents];
    } else {
        moneyString = [NSString stringWithFormat:@"%@.%@", [cents substringToIndex:cents.length - 2], [cents substringFromIndex:cents.length - 2]];
    }

    return [SQMoney moneyWithString:moneyString currency:currency];
}

+ (SQMoney *)moneyWithString:(NSString *)string currency:(NSString *)currency;
{
    return [[[[self class] alloc] initWithString:string currency:currency] autorelease];
}

+ (SQMoney *)moneyByTotalingMoneyArray:(NSArray *)moneyList;
{
    // nothing to add, treat it as 0
    if (!moneyList.count) {
        return [SQMoney money];
    }
    
    NSDecimal totalAmount;
    NSString *knownCurrency = ((SQMoney *)[moneyList objectAtIndex:0]).currency;
    
    for (SQMoney *currentMoney in moneyList) {
        if (![currentMoney.currency isEqualToString:knownCurrency]) {
            // undefined
            return nil;
        }
        
        NSDecimal currentAmount = [currentMoney.amount decimalValue];
        NSDecimalAdd(&totalAmount, &totalAmount, &currentAmount, NSRoundBankers);
    }
    
    return [SQMoney moneyWithDecimal:totalAmount currency:knownCurrency];
}

+ (SQMoney *)money;
{
    return [[[[self class] alloc] init] autorelease];
}

+ (NSString *)defaultCurrency;
{
    if (!defaultCurrency.length) {
        [SQMoney setDefaultCurrency:@"USD"];
    }

    return defaultCurrency;
}

+ (void)setDefaultCurrency:(NSString *)inCurrency;
{
    [inCurrency retain];
    [defaultCurrency release];
    defaultCurrency = inCurrency;
}

#pragma mark Initialization

- (id)init;
{
    return [self initWithAmount:[NSDecimalNumber zero] currency:[SQMoney defaultCurrency]];
}

- (id)initWithAmount:(NSDecimalNumber *)inAmount currency:(NSString *)inCurrency;
{
    if (!(self = [super init])) {
        return nil;
    }

    // don't allow invalid currencies
    if (!inCurrency.length) {
        [self release];
        return self = nil;
    }

    self.amount = inAmount;
    self.currency = inCurrency;

    return self;
}
                                     
- (id)initWithDecimal:(NSDecimal)decimalAmount currency:(NSString *)inCurrency;
{
    return [self initWithAmount:[NSDecimalNumber decimalNumberWithDecimal:decimalAmount] currency:inCurrency];
}

- (id)initWithString:(NSString *)inAmount currency:(NSString *)inCurrency;
{
    return [self initWithAmount:[NSDecimalNumber decimalNumberWithString:(inAmount.length ? inAmount : @"0")] currency:inCurrency];
}

- (id)initWithCoder:(NSCoder *)decoder;
{
    NSString *amountString = [decoder decodeObjectForKey:SQMoneyAmountKey];
    NSString *currencyString = [decoder decodeObjectForKey:SQMoneyCurrencyKey];

    return [self initWithString:amountString currency:currencyString];
}

- (void)dealloc;
{
    [currency release];
    currency = nil;

    [amount release];
    amount = nil;

    [super dealloc];
}

#pragma mark Accessors/Mutators

- (void)setAmount:(NSDecimalNumber *)inAmount;
{
    if (!inAmount || [inAmount isEqualToNumber:[NSDecimalNumber notANumber]]) {
        inAmount = [NSDecimalNumber zero];
    } else {
        inAmount = [inAmount decimalNumberByRoundingAccordingToBehavior:roundingHandler];
    }

    [inAmount retain];
    [amount release];
    amount = inAmount;
}

- (void)setCurrency:(NSString *)inCurrency;
{
    NSString *newCurrency = [inCurrency uppercaseString];
    [currency release];
    currency = [newCurrency retain];
}

#pragma mark Public Methods

- (NSString *)cents;
{
	NSString *centsString = [[self stringValue] stringByRemovingCharactersInSet:[NSCharacterSet notNumericCharacterSet]];
    
    // don't bother if we're just 0.00
    if ([centsString integerValue] == 0) {
        return @"0";
    }
    
    // trim leading zeros
	while ([centsString hasPrefix:@"0"]) {
		centsString = [centsString substringWithRange:NSMakeRange(1, centsString.length - 1)];
	}
    
    return centsString;
}

- (NSString *)displayValue;
{
    [currencyFormatter setCurrencyCode:currency];
    NSString *displayString = [currencyFormatter stringFromNumber:self.amount];

    // strip off parens and replace them with what NORMAL PEOPLE display negative values as
    if ([self compare:[SQMoney money]] == NSOrderedAscending &&
        [displayString hasPrefix:@"("] &&
        [displayString hasSuffix:@")"]) {
        displayString = [@"-" stringByAppendingString:[displayString substringWithRange:NSMakeRange(1, displayString.length - 2)]];
    }

    return displayString;
}

- (NSString *)displayOptionalCentsValue;
{
    NSNumberFormatter *optionalCentsFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [optionalCentsFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [optionalCentsFormatter setAlwaysShowsDecimalSeparator:NO];

    NSString *centsValue = self.cents;
    BOOL hideZeros = NO;

    if ([self isZero]) {
        hideZeros = YES;
    } else if (centsValue.length > 2) {
        // this means we have at least 3 digits, i.e. 123 cents vs 50 cents
        hideZeros = [centsValue hasSuffix:@"00"];
    }

    if (hideZeros) {
        [optionalCentsFormatter setMaximumFractionDigits:0];
    }

    return [optionalCentsFormatter stringFromNumber:self.amount];
}

- (NSString *)stringValue;
{
    return [numberFormatter stringFromNumber:self.amount];
}

- (BOOL)isZero;
{
    return [self.amount isEqual:[NSDecimalNumber zero]];
}

- (BOOL)hasSameCurrency:(SQMoney *)money;
{
    return [self.currency isEqualToString:money.currency];
}

#pragma mark Money Mutators

- (SQMoney *)moneyByAdding:(NSString *)number;
{
    return [self moneyByAddingMoney:[SQMoney moneyWithString:number currency:self.currency]];
}

- (SQMoney *)moneyByAddingMoney:(SQMoney *)money;
{
    // nothing to add, treat it as 0
    if (!money) {
        return self;
    }

    if ([self hasSameCurrency:money]) {
        return [SQMoney moneyWithAmount:[self.amount decimalNumberByAdding:money.amount] currency:self.currency];
    }

    // undefined
    return nil;
}

- (SQMoney *)moneyBySubtracting:(NSString *)number;
{
    return [self moneyBySubtractingMoney:[SQMoney moneyWithString:number currency:self.currency]];
}

- (SQMoney *)moneyBySubtractingMoney:(SQMoney *)money;
{
    // if there's nothing to subtract treat it as 0
    if (!money) {
        return self;
    }

    if ([self hasSameCurrency:money]) {
        return [SQMoney moneyWithAmount:[self.amount decimalNumberBySubtracting:money.amount] currency:self.currency];
    }

    // undefined
    return nil;
}

- (SQMoney *)moneyByDividingBy:(NSString *)number;
{
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:number];
    return [SQMoney moneyWithAmount:[self.amount decimalNumberByDividingBy:decimalNumber] currency:self.currency];
}

- (SQMoney *)moneyByMultiplyingBy:(NSString *)number;
{
    return [self moneyByMultiplyingByAmount:[NSDecimalNumber decimalNumberWithString:number]];
}

- (SQMoney *)moneyByMultiplyingByAmount:(NSDecimalNumber *)number;
{
    return [SQMoney moneyWithAmount:[self.amount decimalNumberByMultiplyingBy:number] currency:self.currency];
}

- (SQMoney *)moneyByMultiplyingByPowerOf10:(short)number;
{
    return [SQMoney moneyWithAmount:[self.amount decimalNumberByMultiplyingByPowerOf10:number] currency:self.currency];
}

- (SQMoney *)percentOfMoney:(NSUInteger)percent;
{
    NSDecimalNumber *hundredDecimal = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *percentDecimal = [NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithUnsignedInteger:percent] stringValue]];
    percentDecimal = [percentDecimal decimalNumberByDividingBy:hundredDecimal];

    return [self moneyByMultiplyingByAmount:percentDecimal];
}

- (SQMoney *)expectedMoneyTendered;
{
    // this is supposed to be a round up, because we're trying to figure out
    // how much a whole-dollar amount would be if giving change, i.e. price is $4.50 and expected money tendered is $5.00
	NSDecimalNumberHandler *roundUpHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp
																								scale:0
																					 raiseOnExactness:NO
																					  raiseOnOverflow:NO
																					 raiseOnUnderflow:NO
																				  raiseOnDivideByZero:NO];

	return [SQMoney moneyWithAmount:[self.amount decimalNumberByRoundingAccordingToBehavior:roundUpHandler] currency:self.currency];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:[self stringValue] forKey:SQMoneyAmountKey];
    [coder encodeObject:self.currency forKey:SQMoneyCurrencyKey];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    return [[SQMoney allocWithZone:zone] initWithAmount:self.amount currency:self.currency];
}

#pragma mark NSObject

- (NSComparisonResult)compare:(SQMoney *)money;
{
    return [self.amount compare:money.amount];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p (%@)>", NSStringFromClass([self class]), self, [self displayValue]];
}

- (BOOL)isEqual:(id)obj;
{
    BOOL equal = NO;

    if ([obj isKindOfClass:[SQMoney class]]) {
        SQMoney *money = (SQMoney *)obj;
        equal = [self.amount isEqualToNumber:money.amount] && [self hasSameCurrency:money];
    }

    return equal;
}

@end


#pragma mark Categories


@implementation NSCharacterSet (SQMoneyAdditions)

+ (NSCharacterSet *)numericCharacterSet; // only 0 thru 9
{
    static NSCharacterSet *numericCharacterSet = nil;

    if (!numericCharacterSet) {
        NSMutableCharacterSet *charSet = [[NSMutableCharacterSet alloc] init];
        [charSet addCharactersInString:@"0123456789"];
        numericCharacterSet = charSet;
    }

    return numericCharacterSet;
}

+ (NSCharacterSet *)notNumericCharacterSet; // anything but 0 thru 9
{
    static NSCharacterSet *notNumericCharacterSet = nil;

    if (!notNumericCharacterSet) {
        notNumericCharacterSet = [[[NSCharacterSet numericCharacterSet] invertedSet] retain];
    }

    return notNumericCharacterSet;
}

@end


@implementation NSString (SQMoneyAdditions)

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet;
{
    if (!characterSet) {
        return self;
    }

    NSMutableString *string = [[[NSMutableString alloc] initWithString:self] autorelease];
    NSRange searchRange;

    while ((searchRange = [string rangeOfCharacterFromSet:characterSet]).location != NSNotFound) {
        [string deleteCharactersInRange:searchRange];
    }

    return string;
}

@end
