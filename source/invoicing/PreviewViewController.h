//
//  PreviewViewController.h
//  invoicing
//
//  Created by George on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface PreviewViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
    IBOutlet UIWebView * preview;
    
    UIViewController * owner;
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    
    NSMutableDictionary * lang;
    
    NSString * file;
    
}

@property (nonatomic, retain) UIViewController * owner;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)openSettings;

- (void)printWithTitle:(NSString *)title;
- (void)emailWithTitle:(NSString *)title;
- (void)payWithPaypal;

@end
