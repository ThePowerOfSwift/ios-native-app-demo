//
//  SettingsCompanyViewController.h
//  invoicing
//
//  Created by George on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsCompanyViewController : UIViewController {
    
    IBOutlet UITextField * UICompanyName; 
    IBOutlet UITextField * UICompanyCode; 
    IBOutlet UITextField * UICompanyAddr1;
    IBOutlet UITextField * UICompanyAddr2;
    IBOutlet UITextField * UICompanyEmail;
    IBOutlet UITextField * UICompanyPhone;
    IBOutlet UITextField * UICompanyBank;
    IBOutlet UITextField * UICompanyAccount; 
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    
    IBOutlet UIScrollView * scrollView;
    
    BOOL keyboardIsShown;
    
    UITextField * activeField;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)openCompany;
- (void)saveCompany;

@end
