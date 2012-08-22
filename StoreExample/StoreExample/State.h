//
//  State.h
//  StoreExample
//
//  Created by David House on 8/18/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import "RADocument.h"

@interface State : RADocument

#pragma mark - Properties
@property (nonatomic,readonly) NSString *capital;
@property (nonatomic,readonly) NSString *mostPopulousCity;
@property (nonatomic,retain) NSString *size;


@end
