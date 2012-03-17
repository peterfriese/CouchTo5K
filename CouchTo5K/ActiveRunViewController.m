//
//  ActiveRunViewController.m
//  CouchTo5K
//
//  Created by Peter Friese on 16.03.12.
//  Copyright (c) 2012 peterfriese.de. All rights reserved.
//

#import "ActiveRunViewController.h"
#import "DatabaseAdapter.h"
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>
#import <CouchCocoa/CouchUITableSource.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>

@interface ActiveRunViewController ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL running;
@property (strong, nonatomic) CouchLiveQuery *waypointsQuery;
@end

@implementation ActiveRunViewController

@synthesize locationManager;
@synthesize running;
@synthesize waypointsQuery;
@synthesize runName;
@synthesize runnerName;
@synthesize timeLabel;
@synthesize trackpointsLabel;
@synthesize distanceLabel;
@synthesize runnameLabel;
@synthesize toolBar;
@synthesize startStopButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.running = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.runnameLabel.text = self.runName;
}

- (void)viewDidUnload
{
    [self setTimeLabel:nil];
    [self setTrackpointsLabel:nil];
    [self setDistanceLabel:nil];
    [self setRunnameLabel:nil];
    [self setStartStopButton:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)startLiveQuery
{
    waypointsQuery = [[[DatabaseAdapter sharedAdapter] queryWayPointsByRun] asLiveQuery];
    
    [waypointsQuery setStartKey:[NSArray arrayWithObjects:self.runName, nil]];
    [waypointsQuery setEndKey:[NSArray arrayWithObjects:self.runName, @"ZZZ", nil]];

    [waypointsQuery addObserver:self forKeyPath:@"rows" options:0 context:nil];
    
    [waypointsQuery start];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == waypointsQuery) {
        self.trackpointsLabel.text = [NSString stringWithFormat:@"%d", [waypointsQuery.rows count]];
        
        CLLocation *previous = nil;
        CLLocationDistance distance = 0;
        for (CouchQueryRow *row in waypointsQuery.rows) {
            id waypoint = row.value;
            CLLocationDegrees lat = [[waypoint objectForKey:@"lat"] doubleValue];
            CLLocationDegrees lon = [[waypoint objectForKey:@"lon"] doubleValue];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            if (previous) {
                distance  += [location distanceFromLocation:previous];
            }
            previous = location;
        }
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2d", distance];
    }
}

- (IBAction)startStop:(id)sender 
{
    if (!self.running) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:[self.toolBar items]];
        UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause 
                                                                                   target:self 
                                                                                   action:@selector(startStop:)];        
        [items replaceObjectAtIndex:0 withObject:pauseButton];
        [self.toolBar setItems:items];
        self.running = YES;
        [self.locationManager startUpdatingLocation];
        [self startLiveQuery];
    }
    else {
        NSMutableArray *items = [NSMutableArray arrayWithArray:[self.toolBar items]];
        UIBarButtonItem *playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay 
                                                                                     target:self 
                                                                                     action:@selector(startStop:)];        
        [items replaceObjectAtIndex:0 withObject:playButton];
        [self.toolBar setItems:items];
        
        [self.locationManager stopUpdatingLocation];
        self.running = NO;
        [self.startStopButton setStyle:UIBarButtonSystemItemPlay];
    }
}

- (IBAction)finish:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];    
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
        (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
    {    
        CouchDatabase *database = [[DatabaseAdapter sharedAdapter] database];
        
        NSDictionary *trackpointProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                              self.runnerName, @"user", 
                                              self.runName, @"run",
                                              [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:newLocation.coordinate.latitude]], @"lat",
                                              [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:newLocation.coordinate.longitude]], @"lon",
                                              [NSString stringWithFormat:@"%@", newLocation.timestamp]  , @"time",
                                              nil];
            
        CouchDocument *trackpointDocument =[database untitledDocument];
        RESTOperation* op = [trackpointDocument putProperties:trackpointProperties];
        [op onCompletion: ^{
            if (op.error)
                NSLog(@"Couldn't save the new item");
        }];
        [op start];    
    };

    
}

@end
