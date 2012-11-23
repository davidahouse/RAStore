//
//  RAResource.m
//
//  Created by David House on 8/5/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import "RAResource.h"

@interface RAResource()
+ (void)createLibraryIfDoesntExist:(NSString *)library;
@end

@implementation RAResource


# pragma mark - Class methods
+ (void)emptyLibrary:(NSString *)library {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:library];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
    
    [RAResource createLibraryIfDoesntExist:library];
}

+ (NSString *)pathForLibrary:(NSString *)library {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:library];
    [RAResource createLibraryIfDoesntExist:library];
    return fullPath;
}


#pragma mark - Initializers
- (id)initWithResource:(NSString *)resource {
    if ( self = [super init] ) {
        self.resourcePath = resource;
    }
    return self;
}

#pragma mark - Public methods
- (void)store:(NSString *)library {
    
    // Copy the file into the local file system if we are loaded from a resource
    if ( self.resourcePath ) {
        NSString *fileName = [self.resourcePath lastPathComponent];
        if ( self.destinationFileName ) {
            fileName = self.destinationFileName;
        }
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *libraryPath = [documentsDirectory stringByAppendingPathComponent:library];
        NSString *destPath = [libraryPath stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:self.resourcePath toPath:destPath error:&error];
    }
}

#pragma mark - Private methods
+ (void)createLibraryIfDoesntExist:(NSString *)library {
    
    // Create the local Documents folder this if it doesn't already exist
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:library];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:fullPath] ) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
}


@end
