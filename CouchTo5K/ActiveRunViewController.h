//
//  ActiveRunViewController.h
//  CouchTo5K
//
//  Created by Peter Friese on 16.03.12.
//  Copyright (c) 2012 peterfriese.de. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ActiveRunViewController : UIViewController<CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *runName;
@property (strong, nonatomic) NSString *runnerName;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackpointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *runnameLabel;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *startStopButton;
@property (strong, nonatomic) IBOutlet UIImageView *ledlinesOverlay;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

- (IBAction)startStop:(id)sender;
- (IBAction)finish:(id)sender;

@end
