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

#import "NSDictionary-SQAdditions.h"
#import "NSURL-SQAdditions.h"


@implementation NSURL (SQAdditions)

- (NSURL *)URLByAppendingQueryParameters:(NSDictionary *)parameters;
{
    if (!parameters.count) {
        return self;
    }
    
    NSMutableString *urlString = [[self absoluteString] mutableCopy];
    
    [urlString appendString:[self query] ? @"&" : @"?"];
    [urlString appendString:[parameters URLParameterString]];
    
    NSURL *returnURL = [NSURL URLWithString:urlString];
    [urlString release];
    
    return returnURL;
}

- (NSDictionary *)queryParameters;
{
    NSString *query = [self query];
    NSArray *keyValuePairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    for (NSString *pair in keyValuePairs) {
        NSArray *components = [pair componentsSeparatedByString:@"="];
        
        if (components.count == 2) {
            NSString *key = [[components objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            if (key && value) {
                [params setObject:value forKey:key];
            }
        }
    }
    
    return params;
}

@end
