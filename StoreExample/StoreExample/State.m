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

- (void)setSize:(NSString *)size {
    [self setStringInBody:size usingPath:@"attributes\\size"];
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
