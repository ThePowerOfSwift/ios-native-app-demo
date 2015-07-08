//
//  QuoteListViewController.h
//  invoicing
//
//  Created by George on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuoteListViewController : UIViewController {
    
    NSMutableDictionary * client;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    IBOutlet UITableView * mainTable; 
    
    CGSize cellSize;
    
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSMutableDictionary * client;

- (void)addQuote;
- (void)refreshQuoteList;

- (void)refreshList;

@end
