//
//  RAResource.h
//
//  Created by David House on 8/5/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAResource : NSObject

#pragma mark - Properties
@property (nonatomic,retain) NSString *resourcePath;
@property (nonatomic,retain) NSString *destinationFileName;

# pragma mark - Class methods
+ (void)emptyLibrary:(NSString *)library;
+ (NSString *)pathForLibrary:(NSString *)library;

#pragma mark - Initializers
- (id)initWithResource:(NSString *)resource;

#pragma mark - Public methods
- (void)store:(NSString *)library;

@end
