//
//  PlotRunMapViewController.m
//  CouchTo5K
//
//  Created by Peter Friese on 14.03.12.
//  Copyright (c) 2012 peterfriese.de. All rights reserved.
//

#import "PlotRunMapViewController.h"
#import "DatabaseAdapter.h"
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>
#import <CouchCocoa/CouchUITableSource.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>
#import <CouchCocoa/REST.h>
#import <CoreLocation/CoreLocation.h>

@interface PlotRunMapViewController()
- (void)updateRunFromDB;
- (void)addNewLocation:(CLLocation *)locatio;
@end

@implementation PlotRunMapViewController

@synthesize runKey;
@synthesize mapView;
@synthesize crumbs;
@synthesize crumbView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    mapView.delegate = self;
    [self updateRunFromDB];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateRunFromDB
{
    
    CouchDatabase *database = [[DatabaseAdapter sharedAdapter] database];
    
    CouchDesignDocument* design = [database designDocumentWithName: @"couch-2-5k"];
    [design defineViewNamed: @"waypoints_by_run" mapBlock: MAPBLOCK({
        NSString *run = (NSString *)[doc objectForKey:@"run"];
        id time = [doc objectForKey:@"time"];
        if ([run isEqualToString:runKey]) {
            emit(time, doc);
        }
    }) version: @"1.0"];
    
    CouchLiveQuery *query = [[[database designDocumentWithName: @"couch-2-5k"]
                              queryViewNamed: @"waypoints_by_run"] asLiveQuery];
    [query setStartKey:self.runKey];
    RESTOperation *fetch = [query start];
    [fetch onCompletion:^{
        BOOL success = fetch.isSuccessful;
        NSUInteger rows = [query.rows count];
        NSLog(@"Aaaaand - we're done. Success: %d, # rows:%d", success, rows);
        for (CouchQueryRow *row in query.rows) {
            id waypoint = row.value;
            CLLocationDegrees lat = [[waypoint objectForKey:@"lat"] doubleValue];
            CLLocationDegrees lon = [[waypoint objectForKey:@"lon"] doubleValue];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            
            [self addNewLocation:location];
        }
        
    }];
    
    NSLog(@"This is AFTER the block");
}

- (void)addNewLocation:(CLLocation *)location
{
    if (!crumbs)
    {
        // This is the first time we're getting a location update, so create
        // the CrumbPath and add it to the map.
        //
        crumbs = [[CrumbPath alloc] initWithCenterCoordinate:location.coordinate];
        [mapView addOverlay:crumbs];
        
        // On the first location update only, zoom map to user location
        MKCoordinateRegion region = 
        MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000);
        [mapView setRegion:region animated:YES];
    }
    else
    {
        // This is a subsequent location update.
        // If the crumbs MKOverlay model object determines that the current location has moved
        // far enough from the previous location, use the returned updateRect to redraw just
        // the changed area.
        //
        // note: iPhone 3G will locate you using the triangulation of the cell towers.
        // so you may experience spikes in location data (in small time intervals)
        // due to 3G tower triangulation.
        // 
        MKMapRect updateRect = [crumbs addCoordinate:location.coordinate];
        
        if (!MKMapRectIsNull(updateRect))
        {
            // There is a non null update rect.
            // Compute the currently visible map zoom scale
            MKZoomScale currentZoomScale = (CGFloat)(mapView.bounds.size.width / mapView.visibleMapRect.size.width);
            // Find out the line width at this zoom scale and outset the updateRect by that amount
            CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
            updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
            // Ask the overlay view to update just the changed area.
            [crumbView setNeedsDisplayInMapRect:updateRect];
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (!crumbView) {
        crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return crumbView;
}

@end
