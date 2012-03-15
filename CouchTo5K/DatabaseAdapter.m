//
//  DatabaseAdapter.m
//  CouchTo5K
//
//  Created by Peter Friese on 12.03.12.
//  Copyright (c) 2012 peterfriese.de. All rights reserved.
//

#import "DatabaseAdapter.h"
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>

@implementation DatabaseAdapter

@synthesize database = _database;
@synthesize connected = _connected;

static DatabaseAdapter *sharedInstance;

+ (void)initialize
{
    if ([DatabaseAdapter class] == self) {
        sharedInstance = [[DatabaseAdapter alloc] init];
    }
}

+ (DatabaseAdapter *)sharedAdapter 
{
    return sharedInstance;
}

- (CouchDatabase *)connect 
{
    CouchTouchDBServer *server = [CouchTouchDBServer sharedInstance];
    NSAssert(!server.error, @"Error initializing TouchDB server: %@", server.error);
    
    self.database = [server databaseNamed:@"couch-2-5k-2"];
    
    NSError *error;
    if (! [self.database ensureCreated:&error]) {
        // raise error
        self.connected = false;
    }
    self.connected = true;
    self.database.tracksChanges = YES;
    return self.database;
}

- (void)startSync
{
    if (self.connected) {
        NSURL *url = [NSURL URLWithString:@"http://peterfriese.local:5984/couch25k"];
        NSArray *replications = [self.database replicateWithURL:url exclusively: YES];  
    
        CouchPersistentReplication *from = [replications objectAtIndex:0];
        from.continuous = YES;
        from.filter = @"couch25k/by_user";
        NSDictionary *filterParams = [NSDictionary dictionaryWithObjectsAndKeys:@"peterfriese", @"username", nil];
        from.query_params = filterParams;    
    }
}

@end
