//
//  SettingsDiscountListViewController.h
//  invoicing
//
//  Created by George on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsDiscountListViewController : UIViewController {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    IBOutlet UITableView * mainTable; 
    
    CGSize cellSize;
    
    UIViewController * owner;
}

@property (nonatomic, retain) UIViewController * owner;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)addDiscount;
- (void)refreshList;

@end
