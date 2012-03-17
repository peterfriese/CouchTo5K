//
//  DatabaseAdapter.h
//  CouchTo5K
//
//  Created by Peter Friese on 12.03.12.
//  Copyright (c) 2012 peterfriese.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>
#import <CouchCocoa/CouchUITableSource.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>

@class CouchDatabase;

@interface DatabaseAdapter : NSObject

@property (strong, nonatomic) CouchDatabase *database;
@property (nonatomic) BOOL connected;

+ (DatabaseAdapter *)sharedAdapter;
- (CouchDatabase *)connect;
- (void)startSync;

- (CouchLiveQuery *)queryRuns;
- (CouchQuery *)queryWayPointsByRun;

@end
