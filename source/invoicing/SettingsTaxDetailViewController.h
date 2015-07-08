//
//  SettingsTaxDetailViewController.h
//  invoicing
//
//  Created by George on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsTaxDetailViewController : UIViewController {
    
    IBOutlet UITextField * UITaxName;
    IBOutlet UITextField * UITaxValue;
    IBOutlet UISegmentedControl * UITaxType;
    IBOutlet UIScrollView * scrollView;
    
    
    NSMutableDictionary * tax;
    
    NSManagedObjectContext *managedObjectContext;
    
    UIViewController * owner;
    
    BOOL keyboardIsShown;
    
    UITextField * activeField;
    
}

@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;


@property (nonatomic, retain) NSMutableDictionary * tax;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIViewController * owner;

- (void)saveTax;

@end
