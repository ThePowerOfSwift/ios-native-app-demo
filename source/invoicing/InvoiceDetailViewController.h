//
//  InvoiceDetailViewController.h
//  invoicing
//
//  Created by George on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface InvoiceDetailViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate> {
    
    IBOutlet UIButton * nameButton;
    IBOutlet UITextField * titleField;
    IBOutlet UILabel * UIInvoiceNo;
    
    NSMutableDictionary * invoice;
    
    NSManagedObjectContext *managedObjectContext;
    
    UIViewController * owner;
    
    IBOutlet UIScrollView * scrollView;
    
    IBOutlet UITableView * mainTable; 
    
    BOOL keyboardIsShown;
    
    UITextField * activeField;
    
    float total_products, total_discount, total_taxes, total_total;
    
}

-(IBAction)selectClient;

@property (nonatomic, retain) NSMutableDictionary * invoice;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIViewController * owner;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic) float total_products;
@property (nonatomic) float total_discount;
@property (nonatomic) float total_taxes;
@property (nonatomic) float total_total;

- (void)saveInvoice;
- (void)setClient:(NSMutableDictionary*)client;
- (void)setProduct:(NSMutableDictionary*)product;
- (void)setDiscount:(NSMutableDictionary*)discount;
- (void)setTax:(NSMutableDictionary*)tax;

- (void)quantityDown:(id)sender;
- (void)quantityUp:(id)sender;

- (void)newIndex;
- (void)computeTotals;


@end
