//
//  RADocument.h
//
//  Created by David House on 7/29/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface RADocument : NSObject

#pragma mark - Properties
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *foreignKey;
@property (nonatomic) NSString *title;
@property (nonatomic) NSDate *updateTime;
@property (nonatomic) id body;

#pragma mark - Initializers
- (id)initFromResults:(FMResultSet *)resultSet;
- (id)initWithBody:(id)initBody;

#pragma mark - Insert/Update/Delete methods
- (void)store;
- (void)update;

#pragma mark - Query methods
+ (id)find:(NSString *)key;
+ (NSArray *)findInTitle:(NSString *)condition;
+ (NSArray *)mostRecent:(int)top;
+ (NSArray *)findAll;
+ (NSArray *)findWithForeignKey:(NSString *)foreignKey;

#pragma mark - Body query methods
- (NSString *)stringInBodyUsingPath:(NSString *)path default:(NSString *)defaultString;
- (NSDate *)dateInBodyUsingPath:(NSString *)path default:(NSDate *)defaultDate;
- (NSArray *)arrayInBodyUsingPath:(NSString *)path;

#pragma mark - Body update methods
- (void)setStringInBody:(NSString *)setString usingPath:(NSString *)path;

@end