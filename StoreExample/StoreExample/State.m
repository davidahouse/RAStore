//
//  State.m
//  StoreExample
//
//  Created by David House on 8/18/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import "State.h"

@implementation State

#pragma mark - Properties
- (NSString *)capital {
    return [self stringInBodyUsingPath:@"attributes\\capital" default:@""];
}

- (NSString *)mostPopulousCity {
    return [self stringInBodyUsingPath:@"attributes\\most-populous-city" default:@""];
}

- (NSString *)size {
    
    return [self stringInBodyUsingPath:@"attributes\\size" default:@"unknown"];
}

#pragma mark - Index searches
+ (NSArray *)findInCapital:(NSString *)searchClause {
 
    // TODO: Implement this
    return nil;
}

+ (NSArray *)indexedColumns {
    return @[@"capital"];
}


#pragma mark - Path methods that should be overriden
- (NSString *)pathForKey {
    return @"attributes\\abbreviation";
}

- (NSString *)pathForForeignKey {
    return @"";
}

- (NSString *)pathForTitle {
    return @"attributes\\name";
}

- (NSString *)pathForKeywords {
    return @"";
}

- (NSString *)pathForUpdateTime {
    return @"";
}

@end
