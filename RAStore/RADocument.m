//
//  RADocument.m
//
//  Created by David House on 7/29/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import "RADocument.h"
#import "RAStore.h"
#import "NSObject+RAStoreCategory.h"

@interface RADocument ()

#pragma mark - Path methods that should be overriden
- (NSString *)pathForKey;
- (NSArray *)compositePathForKey;
- (NSString *)pathForForeignKey;
- (NSArray *)compositePathForForeignKey;
- (NSString *)pathForTitle;
- (NSArray *)compositePathForTitle;
- (NSString *)pathForUpdateTime;


+ (NSArray *)search:(NSArray *)criteria withClass:(Class)searchClass;

@end

@implementation RADocument

#pragma mark - Initializers
- (id)initFromResults:(FMResultSet *)resultSet {
    
    if ( self = [super init] ) {
        
        self.key = [resultSet stringForColumn:@"docKey"];
        self.foreignKey = [resultSet stringForColumn:@"docForeignKey"];
        self.title = [resultSet stringForColumn:@"docTitle"];
        double timeSpan = [resultSet doubleForColumn:@"updateTime"];
        self.updateTime = [NSDate dateWithTimeIntervalSince1970:timeSpan];
        
        // unarchive the body
        NSData *archivedBody = [resultSet objectForColumnName:@"docBody"];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archivedBody];
        self.body = [[unarchiver decodeObjectForKey:@"root"] mutableCopy];
        [unarchiver finishDecoding];
    }
    return self;
}

- (id)initWithBody:(id)initBody {
    
    if ( self = [super init] ) {
        
        self.body = initBody;
        
        if ( [self compositePathForKey] ) {
            self.key = @"";
            for ( NSString *path in [self compositePathForKey] ) {
                self.key = [self.key stringByAppendingString:[self stringInBodyUsingPath:path default:@""]];
            }
        }
        else {
            self.key = [self stringInBodyUsingPath:[self pathForKey] default:@""];
        }

        if ( [self compositePathForForeignKey] ) {
            self.foreignKey = @"";
            for ( NSString *path in [self compositePathForForeignKey] ) {
                self.foreignKey = [self.foreignKey stringByAppendingString:[self stringInBodyUsingPath:path default:@""]];
            }
        }
        else {
            self.foreignKey = [self stringInBodyUsingPath:[self pathForForeignKey] default:@""];
        }
        
        if ( [self compositePathForTitle] ) {
            self.title = @"";
            for ( NSString *path in [self compositePathForTitle] ) {
                self.title = [self.title stringByAppendingFormat:@"%@ ",[self stringInBodyUsingPath:path default:@""]];
            }
        }
        else {
            self.title = [self stringInBodyUsingPath:[self pathForTitle] default:@""];
        }
        
        self.updateTime = [self dateInBodyUsingPath:[self pathForUpdateTime] default:[NSDate date]];
    }
    return self;
}

- (id)init {
    
    if ( self = [super init] ) {
        self.body = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Index declarations
+ (NSArray *)indexedColumns {
    return [NSArray array];
}

#pragma mark - Insert/Update/Delete methods
- (void)insert {
    
    // get the default collection name
    [RAStore insertDocument:self withClass:[self class]];
}

- (void)update {
    
    // get the default collection name
    NSString *collection = NSStringFromClass([self class]);
    [RAStore updateDocument:self inCollection:collection];
}

- (void)delete {
    
    // get the default collection name
    NSString *collection = NSStringFromClass([self class]);
    [RAStore deleteDocument:self fromCollection:collection];
}

#pragma mark - Query methods
+ (NSArray *)findAll {
    
    // get the default collection name
    NSString *collection = NSStringFromClass([self class]);
    
    FMResultSet *results = [RAStore selectFromCollection:collection where:@"" limit:-1];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    while ( [results next] ) {
        
        RADocument *resultModel = [[[self class] alloc] initFromResults:results];
        [resultArray addObject:resultModel];
    }
    return resultArray;    
}

+ (NSArray *)findWithForeignKey:(NSString *)foreignKey {
    
    return [RADocument search:@[[NSString stringWithFormat:@"docForeignKey = '%@'",foreignKey]] withClass:[self class]];
}

+ (id)find:(NSString *)key {
    
    // get the default collection name
    NSString *collection = NSStringFromClass([self class]);
    
    FMResultSet *results = [RAStore selectFromCollection:collection where:[NSString stringWithFormat:@"docKey = '%@'",key] limit:-1];
    if ( [results next] ) {
        RADocument *resultModel = [[[self class] alloc] initFromResults:results];
        return resultModel;
    }
    
    return nil;
}

+ (NSArray *)findInTitle:(NSString *)condition {
    
    return [RADocument search:@[[NSString stringWithFormat:@"docTitle %@",condition]] withClass:[self class]];
}


+ (NSArray *)mostRecent:(int)top {
    
    // get the default collection name
    NSString *collection = NSStringFromClass([self class]);

    FMResultSet *results = [RAStore selectFromCollection:collection where:@"" limit:top];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    while ( [results next] ) {
        
        RADocument *resultModel = [[[self class] alloc] initFromResults:results];
        [resultArray addObject:resultModel];
    }
    return resultArray;
}

+ (NSArray *)search:(NSArray *)criteria withClass:(Class)searchClass {
    
    NSString *collection = NSStringFromClass(searchClass);
    
    // setup the where clause
    NSString *where = @"";
    for ( NSString *whereCriteria in criteria ) {
        if ( ![where isEqualToString:@""] ) {
            where = [where stringByAppendingString:@" and "];
        }
        where = [where stringByAppendingString:whereCriteria];
    }
    
    FMResultSet *results = [RAStore selectFromCollection:collection where:where limit:-1];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    while ( [results next] ) {
        
        RADocument *resultModel = [[searchClass alloc] initFromResults:results];
        [resultArray addObject:resultModel];
    }
    return resultArray;
}


#pragma mark - Body query methods
- (NSString *)stringInBodyUsingPath:(NSString *)path default:(NSString *)defaultString {
    
    // Turn the path into an array
    NSArray *searchPath = [path componentsSeparatedByString:@"\\"];
    id find = [self.body valueForPath:searchPath];
    if ( find ) {
        return find;
    }
    else {
        return defaultString;
    }
}

- (NSDate *)dateInBodyUsingPath:(NSString *)path default:(NSDate *)defaultDate {
    
    // TODO: Um, need implementation here!
    return defaultDate;
}

- (NSArray *)arrayInBodyUsingPath:(NSString *)path {
    
    // Turn the path into an array
    NSArray *searchPath = [path componentsSeparatedByString:@"\\"];
    id find = [self.body valueForPath:searchPath];
    if ( find ) {
        return find;
    }
    else {
        return [NSArray array];
    }
}


#pragma mark - Path methods that should be overriden
- (NSString *)pathForKey {
    return @"";
}

- (NSArray *)compositePathForKey {
    return nil;
}


- (NSString *)pathForForeignKey {
    return @"";
}

- (NSArray *)compositePathForForeignKey {
    return nil;
}

- (NSString *)pathForTitle {
    return @"";
}

- (NSArray *)compositePathForTitle {
    return nil;
}

- (NSString *)pathForUpdateTime {
    return @"";
}

@end
