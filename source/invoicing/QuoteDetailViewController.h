//
//  QuoteDetailViewController.h
//  invoicing
//
//  Created by George on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface QuoteDetailViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate> {
    
    IBOutlet UIButton * nameButton;
    IBOutlet UITextField * titleField;
    
    NSMutableDictionary * quote;
    
    NSManagedObjectContext *managedObjectContext;
    
    UIViewController * owner;
    
    IBOutlet UIScrollView * scrollView;
    
    IBOutlet UITableView * mainTable; 
    
    BOOL keyboardIsShown;
    
    UITextField * activeField;
    
    float total_products, total_discount, total_taxes, total_total;
    
}

-(IBAction)selectClient;

@property (nonatomic, retain) NSMutableDictionary * quote;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIViewController * owner;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic) float total_products;
@property (nonatomic) float total_discount;
@property (nonatomic) float total_taxes;
@property (nonatomic) float total_total;

- (void)saveQuote;
- (void)setClient:(NSMutableDictionary*)client;
- (void)setProduct:(NSMutableDictionary*)product;
- (void)setDiscount:(NSMutableDictionary*)discount;
- (void)setTax:(NSMutableDictionary*)tax;

- (void)quantityDown:(id)sender;
- (void)quantityUp:(id)sender;

- (void)computeTotals;

@end
