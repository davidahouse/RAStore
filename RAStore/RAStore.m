//
//  RAStore.m
//
//  Created by David House on 7/29/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import "RAStore.h"
#import "RADocument.h"
#import "RAResource.h"

@interface RAStore ()

+ (void)createCollectionIfDoesntExist:(Class)docClass;

@end

static FMDatabase *staticStore;
static NSMutableArray *staticCollectionList;

@implementation RAStore

#pragma mark - Open/Close Methods

+ (void)openStore {

    [RAStore openStore:@"store.db"];
}

+ (void)openStore:(NSString *)storeName {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:storeName];
    [RAStore openStoreWithPath:fullPath];
}

+ (void)openStoreWithPath:(NSString *)storePath {

    if ( staticStore ) {
        [RAStore closeStore];
    }

    staticStore = [FMDatabase databaseWithPath:storePath];
    [staticStore open];
}

+ (void)closeStore {

    [staticStore close];
    staticStore = nil;
}

+ (void)removeStore {
    
    [RAStore removeStore:@"store.db"];
}

+ (void)removeStore:(NSString *)storeName {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:storeName];
    [RAStore removeStoreWithPath:fullPath];
}

+ (void)removeStoreWithPath:(NSString *)storePath {
    
    if ( staticStore ) {
        [RAStore closeStore];
    }

    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:storePath error:&error];
}

#pragma mark - Collection methods
+ (void)replaceCollection:(NSString  *)collection withResource:(NSString *)resource ofType:(NSString *)type usingClass:(Class)docClass {

    // open resource file (it should be a json file)
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:resource ofType:type];
    NSData *rawData = [NSData dataWithContentsOfFile:dataPath];
    [RAStore replaceCollection:collection withJSON:rawData usingClass:docClass];
}

+ (void)replaceCollection:(NSString *)collection withJSON:(NSData *)jsonData usingClass:(Class)docClass {
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if ( jsonObject == nil ) {
        NSLog(@"error loading json: %@",[error localizedDescription]);
    }

    // We assume the top level is an array
    for ( id doc in jsonObject ) {
        
        RADocument *newDoc = [[docClass alloc] initWithBody:doc];
        [newDoc insert];
    }
}

+ (void)updateCollection:(NSString *)collection withJSON:(NSData *)jsonData usingClass:(Class)docClass {
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if ( jsonObject == nil ) {
        NSLog(@"error loading json: %@",[error localizedDescription]);
    }
    
    // We assume the top level is an array
    for ( id doc in jsonObject ) {
        
        RADocument *newDoc = [[docClass alloc] initWithBody:doc];
        [newDoc update];
    }
}

+ (void)emptyCollection:(NSString *)collection {
    
//    [RAStore createCollectionIfDoesntExist:collection];
    
    if ( ![staticStore executeUpdate:[NSString stringWithFormat:@"delete from %@",collection]] ) {
        NSLog(@"error emptying collection: %@",[staticStore lastErrorMessage]);
    }
}

+ (void)insertDocument:(RADocument *)document withClass:(Class)docClass {
    
    NSString *collection = NSStringFromClass(docClass);
    [RAStore createCollectionIfDoesntExist:docClass];
    
    // create an NSData object from the document body
    NSMutableData *bodyArchive = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:bodyArchive];
    [archiver encodeObject:document.body forKey:@"root"];
    [archiver finishEncoding];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ VALUES (:docKey,:docForeignKey,:docTitle,:updateTime,:orderNumber,:docBody)",collection];
    if ( ![staticStore executeUpdate:sql withParameterDictionary:@{@"docKey":document.key,@"docForeignKey":document.foreignKey,@"docTitle":document.title,@"updateTime":[NSNumber numberWithDouble:[document.updateTime timeIntervalSince1970]],@"orderNumber":document.order,@"docBody":bodyArchive}]) {

        NSLog(@"error inserting data: %@",[staticStore lastErrorMessage]);
    }
}

+ (void)updateDocument:(RADocument *)document inCollection:(NSString *)collection {
    
    // create an NSData object from the document body
    NSMutableData *bodyArchive = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:bodyArchive];
    [archiver encodeObject:document.body forKey:@"root"];
    [archiver finishEncoding];

    NSString *sql = [NSString stringWithFormat:@"update %@ set docForeignKey = :docForeignKey, docTitle = :docTitle, updateTime = :updateTime, orderNumber = :orderNumber, docBody = :docBody where docKey = :docKey",collection];
    if ( ![staticStore executeUpdate:sql withParameterDictionary:@{@"docKey":document.key,@"docForeignKey":document.foreignKey,@"docTitle":document.title,@"updateTime":[NSNumber numberWithDouble:[document.updateTime timeIntervalSince1970]],@"orderNumber":document.order,@"docBody":bodyArchive}]) {
        NSLog(@"error updating data: %@",[staticStore lastErrorMessage]);
    }
}

+ (void)deleteDocument:(RADocument *)document fromCollection:(NSString *)collection {
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where docKey = :docKey",collection];
    if ( ![staticStore executeUpdate:sql withParameterDictionary:@{@"docKey":document.key}]) {
        NSLog(@"error deleting data: %@",[staticStore lastErrorMessage]);
    }
}

+ (BOOL)documentExists:(RADocument *)document inCollection:(NSString *)collection {
    
    FMResultSet *results = [RAStore selectFromCollection:collection where:[NSString stringWithFormat:@"docKey = '%@'",document.key] limit:-1];
    if ( [results next] ) {
        return YES;
    }
    else {
        return NO;
    }
}


#pragma mark - Library methods
+ (void)replaceLibrary:(NSString *)library withResource:(NSString *)resource ofType:(NSString *)type {
        
    [RAResource emptyLibrary:library];
    
    // Gather a list of the resources that match the name & type given to us
    NSArray *foundFiles = [[NSBundle mainBundle] pathsForResourcesOfType:type inDirectory:nil];
    for ( NSString *path in foundFiles ) {
        
        NSRange foundRange = [[path lastPathComponent] rangeOfString:resource];
        if ( ([resource isEqualToString:@""]) || (( foundRange.location != NSNotFound ) && ( foundRange.location == 0 ) )) {
         
            // ok to store the resource
            RAResource *newResource = [[RAResource alloc] initWithResource:path];
            [newResource store:library];
        }
    }
}

+ (void)replaceLibrary:(NSString *)library withResourcePrefix:(NSString *)prefix removePrefix:(BOOL)removePrefix {

    [RAResource emptyLibrary:library];
    
    // Gather a list of the resources that match the name & type given to us
    NSArray *foundFiles = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:nil];
    for ( NSString *path in foundFiles ) {
        
        NSRange foundRange = [[path lastPathComponent] rangeOfString:prefix];
        if ( ([prefix isEqualToString:@""]) || (( foundRange.location != NSNotFound ) && ( foundRange.location == 0 ) )) {
            
            // ok to store the resource
            RAResource *newResource = [[RAResource alloc] initWithResource:path];
            
            if ( removePrefix ) {
                NSString *fileName = [path lastPathComponent];
                fileName = [fileName stringByReplacingOccurrencesOfString:prefix withString:@""];
                newResource.destinationFileName = fileName;
            }
            [newResource store:library];
        }
    }
}


+ (void)replaceLibrary:(NSString *)library withURL:(NSString *)url {
    
}

+ (void)replaceResouce:(NSString *)library withURL:(NSString *)url {
    
}



#pragma mark - Insert/Update/Delete library methods

#pragma mark - Query methods
+ (FMResultSet *)selectFromCollection:(NSString *)collection where:(NSString *)whereClause limit:(int)limit {

    NSString *querySql =[NSString stringWithFormat:@"select * from %@",collection];
    if ( ![whereClause isEqualToString:@""] ) {
        querySql = [querySql stringByAppendingFormat:@" where %@",whereClause];
    }
    querySql = [querySql stringByAppendingFormat:@" order by orderNumber"];
    if ( limit > 0 ) {
        querySql = [querySql stringByAppendingFormat:@" limit %d",limit];
    }
    
    NSLog(@"RASTORE## query: %@",querySql);
    return [staticStore executeQuery:querySql];
}

#pragma mark - Private Methods
+ (void)createCollectionIfDoesntExist:(Class)docClass{
    
    NSString *collection = NSStringFromClass(docClass);

    // Check for the static array that lists all the collections
    if ( !staticCollectionList ) {
        staticCollectionList = [[NSMutableArray alloc] init];
    }
    
    // Now check if we have already created this collection, if so
    // just return as there is nothing to do.
    if ( ![staticCollectionList containsObject:collection] ) {
    
        // create a table for this collection
        NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@ (docKey text, docForeignKey text, docTitle text, updateTime real, orderNumber integer, docBody blob)",collection];
        if ( ![staticStore executeUpdate:createSQL] ) {
            NSLog(@"error creating table: %@",[staticStore lastErrorMessage]);
        }
        
        // Check to see if the class defines any custom indexes. If so,
        // we need to create them.
        NSArray *indexedColumns = [docClass indexedColumns];
        for ( NSString *column in indexedColumns ) {
            
            NSString *indexSQL = [NSString stringWithFormat:@"create table if not exists %@_%@ (docKey text, %@ text)",collection,column,column];
            if ( ![staticStore executeUpdate:indexSQL] ) {
                NSLog(@"error creating table: %@_%@",collection,column);
            }
        }
        
        [staticCollectionList addObject:collection];
    }
}

#pragma mark - Execute methods
+ (void)executeSQL:(NSString *)sql {
    
    if ( ![staticStore executeUpdate:sql] ) {
        NSLog(@"error %@ executing query: %@",[staticStore lastErrorMessage],sql);
    }
}

@end
