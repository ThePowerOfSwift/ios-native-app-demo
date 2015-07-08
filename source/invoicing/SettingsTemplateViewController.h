//
//  SettingsTemplateViewController.h
//  invoicing
//
//  Created by George on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsTemplateViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    IBOutlet UIButton * UITemplateLogo;
    IBOutlet UITextField * UITemplateLogoURL;
    
    IBOutlet UITextField * UITemplateTitleQuote; 
    IBOutlet UITextField * UITemplateTitleInvoice; 
    
    IBOutlet UITextField * UITemplateRegNo; 
    IBOutlet UITextField * UITemplateBank; 
    IBOutlet UITextField * UITemplateBankAccount; 
    
    IBOutlet UITextField * UITemplatePhone; 
    IBOutlet UITextField * UITemplateEmail; 
    IBOutlet UITextField * UITemplateInvoiceNo; 
    IBOutlet UITextField * UITemplateDate; 
    
    IBOutlet UITextField * UITemplateProduct;
    IBOutlet UITextField * UITemplateUnit;
    IBOutlet UITextField * UITemplateUnitCost;
    IBOutlet UITextField * UITemplateQuantity;
    IBOutlet UITextField * UITemplatePrice;
    
    IBOutlet UITextField * UITemplateSubtotal;
    IBOutlet UITextField * UITemplateDiscount;
    IBOutlet UITextField * UITemplateTaxes;
    IBOutlet UITextField * UITemplateTotal;
    
    IBOutlet UITextField * UITemplateFooterQuote1;
    IBOutlet UITextField * UITemplateFooterQuote2;
    IBOutlet UITextField * UITemplateFooterQuote3;
    IBOutlet UITextField * UITemplateFooterInvoice1;
    IBOutlet UITextField * UITemplateFooterInvoice2;
    IBOutlet UITextField * UITemplateFooterInvoice3;
    
    IBOutlet UITextField * UIPayNow; 
    
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    
    IBOutlet UIScrollView * scrollView;
    
    BOOL keyboardIsShown;
    
    UITextField * activeField;
    
}

-(IBAction)selectImage;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


- (void)openTemplate;
- (void)saveTemplate;
- (void)saveDefaults;

-(NSString *)Base64Encode:(NSData *)data;


@end
