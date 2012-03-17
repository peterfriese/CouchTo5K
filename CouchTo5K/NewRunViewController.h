//
//  NewRunViewController.h
//  CouchTo5K
//
//  Created by Peter Friese on 16.03.12.
//  Copyright (c) 2012 peterfriese.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewRunViewController : QuickDialogController <QuickDialogStyleProvider, QuickDialogEntryElementDelegate> {
    
}

+ (QRootElement *)createNewRunForm;
@end