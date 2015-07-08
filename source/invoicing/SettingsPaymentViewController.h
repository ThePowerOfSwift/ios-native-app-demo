//
//  SettingsPaymentViewController.h
//  invoicing
//
//  Created by George on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsPaymentViewController : UIViewController {
    
    IBOutlet UITextField * UIPaymentEmail; 
    IBOutlet UITextField * UIPaymentCurrency; 
    IBOutlet UISwitch * UIIncludePayment; 
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    
    IBOutlet UIScrollView * scrollView;
    
    BOOL keyboardIsShown;
    
    UITextField * activeField;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)openSettings;
- (void)saveSettings;


@end
