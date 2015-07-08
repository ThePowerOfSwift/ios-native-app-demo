//
//  InvoiceClientListViewController.h
//  invoicing
//
//  Created by George on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InvoiceClientListViewController : UIViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    IBOutlet UITableView * clientTable; 
    
    CGSize cellSize;
    
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)addInvoice;
- (void)refreshClientList;

- (void)refreshList;


@end
