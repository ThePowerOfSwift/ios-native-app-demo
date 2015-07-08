//
//  InvoiceListViewController.h
//  invoicing
//
//  Created by George on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InvoiceListViewController : UIViewController {
    
    NSMutableDictionary * client;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    IBOutlet UITableView * mainTable; 
    
    CGSize cellSize;
    
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSMutableDictionary * client;

- (void)addInvoice;
- (void)refreshInvoiceList;

- (void)refreshList;

@end
