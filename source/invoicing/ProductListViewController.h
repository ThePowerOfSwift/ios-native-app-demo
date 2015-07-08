//
//  ProductListViewController.h
//  invoicing
//
//  Created by George on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductListViewController : UIViewController {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    IBOutlet UITableView * mainTable; 
    
    CGSize cellSize;
    
    UIViewController * owner;
}

@property (nonatomic, retain) UIViewController * owner;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)addProduct;
- (void)refreshList;

@end
