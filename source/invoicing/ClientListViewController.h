//
//  ClientListViewController.h
//  invoicing
//
//  Created by George on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h> 


@interface ClientListViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    IBOutlet UITableView * clientTable; 
    
    NSMutableArray * clients;
    
    UIViewController * owner;
    
    CGSize cellSize;

}

@property (nonatomic, retain) NSMutableArray * clients;
@property (nonatomic, retain) UIViewController * owner;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)addClient;
- (void)refreshClientList;

@end
