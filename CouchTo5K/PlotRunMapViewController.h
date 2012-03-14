//
//  PlotRunMapViewController.h
//  CouchTo5K
//
//  Created by Peter Friese on 14.03.12.
//  Copyright (c) 2012 peterfriese.de. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CrumbPath.h"
#import "CrumbPathView.h"

@interface PlotRunMapViewController : UIViewController<MKMapViewDelegate>

@property (strong, nonatomic) NSString *runKey;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CrumbPath *crumbs;
@property (strong, nonatomic) CrumbPathView *crumbView;

@end
