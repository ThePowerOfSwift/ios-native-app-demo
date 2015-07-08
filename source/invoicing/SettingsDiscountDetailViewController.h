//
//  SettingsDiscountDetailViewController.h
//  invoicing
//
//  Created by George on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsDiscountDetailViewController : UIViewController {
    
    IBOutlet UITextField * UIDiscountName;
    IBOutlet UITextField * UIDiscountValue;
    IBOutlet UISegmentedControl * UIDiscountType;
    IBOutlet UIScrollView * scrollView;
    
    
    NSMutableDictionary * discount;
    
    NSManagedObjectContext *managedObjectContext;
    
    UIViewController * owner;
    
    BOOL keyboardIsShown;
    
    UITextField * activeField;
    
}

@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;


@property (nonatomic, retain) NSMutableDictionary * discount;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIViewController * owner;

- (void)saveDiscount;

@end
