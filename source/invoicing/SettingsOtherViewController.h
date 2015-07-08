//
//  SettingsOtherViewController.h
//  invoicing
//
//  Created by George on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsOtherViewController : UIViewController {
    
    IBOutlet UITextField * UIOtherIndex; 
    IBOutlet UITextField * UIOtherBCC; 
    IBOutlet UISwitch * UIOtherIncludeBankDetails; 
    IBOutlet UISwitch * UIOtherIncludeProductCode; 
    IBOutlet UITextField * UIOtherCurrency;
    
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
