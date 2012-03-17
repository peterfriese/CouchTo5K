//
//  DatabaseAdapter.m
//  CouchTo5K
//
//  Created by Peter Friese on 12.03.12.
//  Copyright (c) 2012 peterfriese.de. All rights reserved.
//

#import "DatabaseAdapter.h"

@interface DatabaseAdapter ()
- (void)setupViews;
@property (strong, nonatomic) CouchDesignDocument *designViewWaypointsByRun;
@end

@implementation DatabaseAdapter

@synthesize database = _database;
@synthesize connected = _connected;
@synthesize designViewWaypointsByRun;

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
    
    self.database = [server databaseNamed:@"couch25k"];
    
    NSError *error;
    if (! [self.database ensureCreated:&error]) {
        // raise error
        self.connected = false;
    }
    self.connected = true;
    self.database.tracksChanges = YES;
    return self.database;
}

- (CouchQuery *)queryWayPointsByRun
{
    designViewWaypointsByRun = [self.database designDocumentWithName: @"couch25k"];
    [designViewWaypointsByRun defineViewNamed: @"waypoints_by_run" mapBlock: MAPBLOCK({
        NSString *run = (NSString *)[doc objectForKey:@"run"];
        id time = [doc objectForKey:@"time"];
        NSMutableArray *key = [[NSMutableArray alloc] init];
        [key addObject:run];
        [key addObject:time];
        emit(key, doc);
    }) version: @"1.1"];
    
    CouchQuery *query = [[self.database designDocumentWithName: @"couch25k"] queryViewNamed: @"waypoints_by_run"];
    return query;
}

- (void)startSync
{
    if (self.connected) {
//        NSURL *url = [NSURL URLWithString:@"http://peterfriese.local:5984/couch25k"];
        NSURL *url = [NSURL URLWithString:@"http://peterfriese.iriscouch.com/couch25k"];        
        NSArray *replications = [self.database replicateWithURL:url exclusively: YES];  
    
        CouchPersistentReplication *from = [replications objectAtIndex:0];
        from.continuous = YES;
        from.filter = @"couch25k/by_user";
        NSDictionary *filterParams = [NSDictionary dictionaryWithObjectsAndKeys:@"peterfriese", @"username", nil];
        from.query_params = filterParams;    
    }
}

@end
