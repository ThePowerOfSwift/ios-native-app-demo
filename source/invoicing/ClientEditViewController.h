//
//  ClientEditViewController.h
//  invoicing
//
//  Created by George on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ClientEditViewController : UIViewController {
    
    IBOutlet UITextField * UIClientName;
    IBOutlet UITextField * UIClientEmail;
    IBOutlet UITextField * UIClientPhone;
    
    IBOutlet UIScrollView * scrollView;
    
    NSMutableDictionary * client;
    
    NSManagedObjectContext *managedObjectContext;
    
    UIViewController * owner;
    
    BOOL keyboardIsShown;
    
    UITextField * activeField;
}

@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSMutableDictionary * client;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIViewController * owner;


- (void)saveClient;

@end
