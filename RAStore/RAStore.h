//
//  RAStore.h
//
//  Created by David House on 7/29/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@class RADocument;

@interface RAStore : NSObject {
}

#pragma mark - Open/Close Methods
+ (void)openStore;
+ (void)openStore:(NSString *)storeName;
+ (void)openStoreWithPath:(NSString *)storePath;
+ (void)closeStore;
+ (void)removeStore;
+ (void)removeStore:(NSString *)storeName;
+ (void)removeStoreWithPath:(NSString *)storePath;

#pragma mark - Collection methods
+ (void)replaceCollection:(NSString  *)collection withResource:(NSString *)resource ofType:(NSString *)type usingClass:(Class)docClass;
+ (void)replaceCollection:(NSString *)collection withJSON:(NSData *)jsonData usingClass:(Class)docClass;
+ (void)updateCollection:(NSString *)collection withJSON:(NSData *)jsonData usingClass:(Class)docClass;
+ (void)emptyCollection:(NSString *)collection;
+ (void)insertDocument:(RADocument *)document withClass:(Class)docClass;
+ (void)updateDocument:(RADocument *)document inCollection:(NSString *)collection;
+ (void)deleteDocument:(RADocument *)document fromCollection:(NSString *)collection;

#pragma mark - Library methods
+ (void)replaceLibrary:(NSString *)library withResource:(NSString *)resource ofType:(NSString *)type;
+ (void)replaceLibrary:(NSString *)library withURL:(NSString *)url;
+ (void)replaceResouce:(NSString *)library withURL:(NSString *)url;

#pragma mark - Query methods
+ (FMResultSet *)selectFromCollection:(NSString *)collection where:(NSString *)whereClause limit:(int)limit;


@end
