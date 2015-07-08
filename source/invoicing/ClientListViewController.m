//
//  ClientListViewController.m
//  invoicing
//
//  Created by George on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClientListViewController.h"
#import "ClientDetailViewController.h"
#import "ClientEditViewController.h"

#import "QuoteDetailViewController.h"
#import "InvoiceDetailViewController.h"


@implementation ClientListViewController

@synthesize clients, owner;
@synthesize fetchedResultsController, managedObjectContext;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
      
    self.navigationItem.title = @"Clients";
    
    //enable the "+" nav button
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClient)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    //[addButton release];
    
    cellSize = CGSizeMake([clientTable bounds].size.width, 60);
    
    
    // get database context
    invoicingAppDelegate *appDelegate = (invoicingAppDelegate *)[[UIApplication sharedApplication] delegate];   
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    // retrieve client database 
    [self refreshClientList];
    
    NSLog(@"started");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    NSLog(@"view did unload");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //NSLog(@"view did unload");

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated {
    
    [self refreshClientList];
    
    [super viewWillAppear:animated];
}


- (void)dealloc
{
    [self.fetchedResultsController release];
    
    [super dealloc];
}

- (void)addClient 
{
    NSLog(@"New Client");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"New Client" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Import Contact", @"Create Client", nil];
    [actionSheet showInView:self.parentViewController.tabBarController.view];
    [actionSheet release];  
}

/******************* ACTION SHEET **********************/

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    
    // import
    if (buttonIndex == 0) {
        
        ABPeoplePickerNavigationController *peoplePickerController = [[ABPeoplePickerNavigationController alloc] init];
        peoplePickerController.peoplePickerDelegate = self;
        [self presentModalViewController:peoplePickerController animated:YES];
        [peoplePickerController release];
    }
    
    // create
    if (buttonIndex == 1) {
        
        ClientEditViewController *dvController = [[ClientEditViewController alloc] initWithNibName:@"ClientEditView" bundle:[NSBundle mainBundle]];
        
        // initialize database managed object
        NSMutableDictionary * client = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Clients" inManagedObjectContext:[self managedObjectContext]];
        
        dvController.client = client;
        dvController.owner = self;
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        
        [dvController release];
        dvController = nil;
    }    
}

- (void)refreshClientList
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Clients" inManagedObjectContext:[self managedObjectContext]];
    request.predicate = nil;    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                       initWithFetchRequest:request 
                                       managedObjectContext:[self managedObjectContext] 
                                       sectionNameKeyPath:nil 
                                       cacheName:nil];
    
    self.fetchedResultsController = frc;
    [frc release];
    [request release];
    
    NSError *error = nil;    
    if (![self.fetchedResultsController performFetch:&error]) {
        
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //exit(-1);  // Fail
    }
    else {
    
        NSLog(@"clients: got %d entries", [[self.fetchedResultsController fetchedObjects] count]);
        
        /*
        [clients removeAllObjects];
        
        for(NSMutableDictionary *client in [self.fetchedResultsController fetchedObjects]) {
            
            NSLog(@"added client from db: %@", client);
            
            //NSLog(@"client property: %@", [client objectForKey:@"email"]);
            [clients addObject: client];
        } 
         */
        
        [clientTable reloadData]; 
    }
}


/**************  Contacts Delegate Functions  ***************/

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    int i;
    
    // get all phone numbers
    ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    for (i = 0; i < ABMultiValueGetCount(phoneMulti); i++) {
        NSString *aPhone = [(NSString*)ABMultiValueCopyValueAtIndex(phoneMulti, i) autorelease];
        
        [phones addObject:aPhone];
    }
    
    CFRelease(phoneMulti);
    
    // get all emails
    ABMutableMultiValueRef emailMulti = ABRecordCopyValue(person, kABPersonEmailProperty);

    for (i = 0; i < ABMultiValueGetCount(emailMulti); i++) {
		NSString *anEmail = [(NSString*)ABMultiValueCopyValueAtIndex(emailMulti, i) autorelease];
		[emails addObject:anEmail];
	}

    CFRelease(emailMulti);
	
	// initialize database managed object
    NSMutableDictionary * client = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Clients" inManagedObjectContext:[self managedObjectContext]];
    
    NSString * sName = (NSString*)ABRecordCopyCompositeName(person);
    NSLog(@"name: %@", sName);
    [client setValue:sName forKey:@"name"]; 
    
    [sName release];
    
    if([phones count] > 0) {
        NSString * sPhone = (NSString*)[phones objectAtIndex:0];
        
        NSLog(@"mobile: %@", sPhone);
        [client setValue:sPhone forKey:@"phone"]; 
    }
    
    if([emails count] > 0)
	{
		NSString * sEmail = (NSString*)[emails objectAtIndex:0];
        
        NSLog(@"email: %@", sEmail);
        [client setValue:sEmail forKey:@"email"]; 
	}
    
    /*
    NSSet * quotes = [[NSSet alloc] init];
    [client setValue:quotes forKey:@"quotes"];
    */   
        
    // save to database
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }
    else {
    
        NSLog(@"Saved fine");
    }
    
    //[client release];
    [phones release];
    [emails release];
    
    // exit
    [peoplePicker dismissModalViewControllerAnimated:YES];
    
    [self refreshClientList];    
    
    return NO;
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    
    return NO;
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    // assigning control back to the main controller
    [peoplePicker dismissModalViewControllerAnimated:YES];
}



/**************  TableView Delegate Functions  ***************/

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController fetchedObjects] count] == 0 ? 1 : [[self.fetchedResultsController fetchedObjects] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        
        cell.detailTextLabel.text = @"There are no clients defined"; 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        
        NSMutableDictionary * client = (NSMutableDictionary *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
        // Set up the cell 
        [cell.textLabel setText:[client valueForKey:@"name"]]; 
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
        cell.detailTextLabel.text = [client valueForKey:@"email"]; 
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }    
    
    // done.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) { return; }
    
    if(self.owner != nil) { 
    
        if ([self.owner isKindOfClass:[QuoteDetailViewController class]]) {
            [(QuoteDetailViewController *)self.owner setClient:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
        }   
        
        if ([self.owner isKindOfClass:[InvoiceDetailViewController class]]) {
            [(InvoiceDetailViewController *)self.owner setClient:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
        return;
    }
    
    
    ClientDetailViewController *dvController = [[ClientDetailViewController alloc] initWithNibName:@"ClientDetailView" bundle:[NSBundle mainBundle]];
    
    /*
    int ix = [indexPath indexAtPosition: [indexPath length] - 1]; 
    dvController.client = [clients objectAtIndex: ix];
    */
    
    dvController.client = (NSMutableDictionary *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
       
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
    dvController = nil;
	  
}

@end
