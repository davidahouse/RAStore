//
//  NSObject+RAStoreCategory.m
//
//  Created by David House on 8/3/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import "NSObject+RAStoreCategory.h"

@implementation NSObject (RAStoreCategory)


- (id)valueForPath:(NSArray *)path {
    
    if ( [path count] == 0 ) {
        return nil;
    }
    else if ( [path count] == 1 ) {
        return [self valueForKey:[path objectAtIndex:0]];
    }
    else {
        // first take first element out of the array
        id first = [path objectAtIndex:0];
        NSArray *restOfPath = [NSArray arrayWithArray:[path objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [path count] - 1)]]];
        
        // if we are an array, then the path should be an index or special string. Otherwise just pass along our valueForKey
        if ( [self respondsToSelector:@selector(objectAtIndex:)] ) {
            
            NSArray *selfArray = (NSArray *)self;
            
            if ( [first isEqualToString:@"first"] ) {
                
                return [[selfArray objectAtIndex:0] valueForPath:restOfPath];
            }
            else if ( [first isEqualToString:@"last"] ) {
                return [[selfArray objectAtIndex:[selfArray count] - 1] valueForPath:restOfPath];
            }
            else {
                return [[selfArray objectAtIndex:[first intValue]] valueForPath:restOfPath];
            }
        }
        else {
            return [[self valueForKey:first] valueForPath:restOfPath];
        }
    }
}

@end
