//
//  NewRunViewController.m
//  CouchTo5K
//
//  Created by Peter Friese on 16.03.12.
//  Copyright (c) 2012 peterfriese.de. All rights reserved.
//

#import "NewRunViewController.h"
#import "ActiveRunViewController.h"

@interface NewRunViewController ()

@end

@implementation NewRunViewController

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    
    self.quickDialogTableView.backgroundColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1.000];
    self.quickDialogTableView.bounces = NO;
    self.quickDialogTableView.styleProvider = self;
    
    ((QEntryElement *)[self.root elementWithKey:@"login"]).delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void) cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
//    cell.backgroundColor = [UIColor colorWithRed:0.9582 green:0.9104 blue:0.7991 alpha:1.0000];
//    
//    if ([element isKindOfClass:[QEntryElement class]] || [element isKindOfClass:[QButtonElement class]]){
//        cell.textLabel.textColor = [UIColor colorWithRed:0.6033 green:0.2323 blue:0.0000 alpha:1.0000];
//    }
    
    if ([element isKindOfClass:[QButtonElement class]]){
        cell.backgroundColor = [UIColor colorWithRed:0.209 green:0.349 blue:0.836 alpha:1.000];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
}

+ (QRootElement *)createNewRunForm {
    QRootElement *root = [[QRootElement alloc] init];
    root.controllerName = @"NewRunViewController";        
    root.title = @"New Run";
    root.grouped = YES;
    
    QSection *section = [[QSection alloc] init];
    QEntryElement *runnemEntry = [[QEntryElement alloc] initWithTitle:@"Run" 
                                                          Value:@"run-peterfriese-1" 
                                                    Placeholder:@"My awesome run"];
    runnemEntry.key = @"runName";

    QEntryElement *nameEntry = [[QEntryElement alloc] initWithTitle:@"Your name" 
                                                              Value:@"peterfriese" 
                                                        Placeholder:@"John Doe"];
    nameEntry.key = @"runnerName";
    
    [root addSection:section];
    [section addElement:runnemEntry];
    [section addElement:nameEntry];
    
    QSection *section2 = [[QSection alloc] init];
    QButtonElement *startButton = [[QButtonElement alloc] initWithTitle:@"Start your run"];
    startButton.controllerAction = @"onStartRun";
    [root addSection:section2];
    [section2 addElement:startButton];
    
    return root;
}

- (BOOL)QEntryShouldChangeCharactersInRangeForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
    NSLog(@"Should change characters");
    return YES;
}

- (void)QEntryEditingChangedForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
    NSLog(@"Editing changed");
}


- (void)QEntryMustReturnForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
    NSLog(@"Must return");
}

- (void)onStartRun {
    ActiveRunViewController *activeRunController = [[ActiveRunViewController alloc] init];    
    [self.root fetchValueIntoObject:activeRunController];
    
    [self presentModalViewController:activeRunController animated:YES];
}

@end