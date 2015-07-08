//
//  SecondViewController.h
//  invoicing
//
//  Created by George on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuoteClientListViewController : UIViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate> {

    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    IBOutlet UITableView * clientTable; 
    
    CGSize cellSize;
    
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)addQuote;
- (void)refreshClientList;

- (void)refreshList;

@end
