//
//  ViewController.m
//  StoreExample
//
//  Created by David House on 8/18/12.
//  Copyright (c) 2012 David House. All rights reserved.
//

#import "ViewController.h"
#import "RAStore.h"
#import "State.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // RAStore Examples

    // For the test purpose, remove any existing store database so we are starting fresh.
    NSLog(@"=== removeStore");
    [RAStore removeStore];
    
    // Initialize the store. If you just call the open method with no arguments, the
    // store database will be created and named 'store.db'. There are overrides that allow
    // you to customize the name and/or location of the database file.
    NSLog(@"=== openStore");
    [RAStore openStore];

    // Initialize a collection using a JSON file included in the bundle. This states JSON file
    // came from the following site:
    // http://www.tellingmachine.com/post/all-50-states-as-xml-json-csv-xls-files.aspx
    NSLog(@"=== replaceCollection");
    [RAStore replaceCollection:@"State" withResource:@"States" ofType:@"json" usingClass:[State class]];
    
    // Return all the State objects in the store
    NSLog(@"=== allDocuments");
    NSArray *states = [State findAll];
    NSLog(@"%d states found, should be 50",[states count]);
    
    // Find a particular state by the Key
    NSLog(@"=== find");
    State *georgia = [State find:@"GA"];
    if ( georgia ) {
        NSLog(@"found georgia, the capital is %@",georgia.capital);
    }
    else {
        NSLog(@"ERROR: state not found");
    }
    
    // More things to implement & test:
    
    // Access non-property data from an object
    NSLog(@"=== stringInBodyUsingPath");
    NSString *population = [georgia stringInBodyUsingPath:@"attributes\\population" default:@"not found"];
    NSLog(@"population = %@",population);
    
    // Search by title
    NSLog(@"=== findInTitle");
    NSArray *startsWithC = [State findInTitle:@"like 'C%'"];
    NSLog(@"found %d states that start with C",[startsWithC count]);
    for ( State *s in startsWithC ) {
        NSLog(@"%@",s.title);
    }
    
    // Search by foreign key
    
    // Update existing objects
    for ( State *s in states ) {
        
    }
    
    
    
    // Delete an object
    // Delete a bunch of objects
    // Clear an entire collection
    NSLog(@"=== emptyCollection");
    [RAStore emptyCollection:@"State"];
    states = [State findAll];
    NSLog(@"%d states found, should be 0",[states count]);

    // Create an index on a field and search on it
    // Insert resource from a URL
    // Download a list of resources from a URL and update any that are new
    // Delete a resource
    // Delete a library
    
    // Do a bunch of inserts and see how long it takes. First build up
    // a JSON document with a bunch of objects in it
    NSLog(@"=== insert timing test");
    NSMutableData *builtStatesJson = [[NSMutableData alloc] init];
    [builtStatesJson appendData:[@"[" dataUsingEncoding:NSUTF8StringEncoding]];
    for ( int i = 0; i < 10000; i++ ) {
        if ( i > 0 ) {
            [builtStatesJson appendData:[@"," dataUsingEncoding:NSUTF8StringEncoding]];
        }

        NSString *stateJson = [NSString stringWithFormat:@"{ \"attributes\": { \"name\": \"%@\", \"abbreviation\": \"%@\"}}",[NSString stringWithFormat:@"state %d",i],[NSString stringWithFormat:@"%d",i]];
        [builtStatesJson appendData:[stateJson dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [builtStatesJson appendData:[@"]" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDate *startInsert = [NSDate date];
    [RAStore replaceCollection:@"State" withJSON:builtStatesJson usingClass:[State class]];
    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:startInsert];
    NSLog(@"insert of 10000 rows took %f second(s)",diff);

    // Grab the states again and lets see how many there are
    NSDate *startFindAll = [NSDate date];
    states = [State findAll];
    NSLog(@"%d states found",[states count]);
    diff = [[NSDate date] timeIntervalSinceDate:startFindAll];
    NSLog(@"find all of 10000 rows took %f second(s)",diff);
    
    // Finally close the store
    NSLog(@"=== closeStore");
    [RAStore closeStore];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
