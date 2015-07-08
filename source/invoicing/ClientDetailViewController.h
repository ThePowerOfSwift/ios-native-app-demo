//
//  ClientDetailViewController.h
//  invoicing
//
//  Created by George on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ClientDetailViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
    IBOutlet UIButton * nameButton;
    IBOutlet UIButton * emailButton;
    IBOutlet UIButton * phoneButton;
    
    NSMutableDictionary * client;
    
    NSManagedObjectContext *managedObjectContext;
    
}

-(IBAction)clickedName;
-(IBAction)clickedEmail;
-(IBAction)clickedPhone;

-(IBAction)createQuote;
-(IBAction)createInvoice;

@property (nonatomic, retain) NSMutableDictionary * client;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)editClient;
- (void)refreshClient;

@end
