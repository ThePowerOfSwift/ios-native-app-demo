//
//  ProductDetailViewController.h
//  invoicing
//
//  Created by George on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductDetailViewController : UIViewController {
    
    IBOutlet UISwitch * UIStatus;
    IBOutlet UITextField * UIName;
    IBOutlet UITextField * UICode;
    IBOutlet UITextField * UIPrice;
    IBOutlet UIButton * UIUnit;
    IBOutlet UIButton * UIDiscount;
    IBOutlet UIButton * UITax;
    
    IBOutlet UIScrollView * scrollView;
    
    
    NSMutableDictionary * product;
    
    NSManagedObjectContext *managedObjectContext;
    
    UIViewController * owner;
    
    BOOL keyboardIsShown;
    
    UITextField * activeField;
    
}

-(IBAction)selectUnit;
-(IBAction)selectDiscount;
-(IBAction)selectTax;

@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSMutableDictionary * product;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIViewController * owner;

- (void)saveProduct;

- (void)setUnit:(NSMutableDictionary*)unit;
- (void)setDiscount:(NSMutableDictionary*)discount;
- (void)setTax:(NSMutableDictionary*)tax;

@end
