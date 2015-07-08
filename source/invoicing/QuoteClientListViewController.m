//
//  SecondViewController.m
//  invoicing
//
//  Created by George on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuoteClientListViewController.h"
#import "QuoteListViewController.h"
#import "QuoteDetailViewController.h"


@implementation QuoteClientListViewController


@synthesize fetchedResultsController, managedObjectContext;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //enable the "+" nav button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addQuote)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    
    cellSize = CGSizeMake([clientTable bounds].size.width, 60);
 
    // get database context
    invoicingAppDelegate *appDelegate = (invoicingAppDelegate *)[[UIApplication sharedApplication] delegate];   
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    // retrieve client database 
    [self refreshClientList]; 
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];

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

- (void)addQuote
{
    NSLog(@"New Quote");
    
    QuoteDetailViewController *dvController = [[QuoteDetailViewController alloc] initWithNibName:@"QuoteDetailView" bundle:[NSBundle mainBundle]];
    
    // initialize database managed object
    NSMutableDictionary * quote = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Quotes" inManagedObjectContext:[self managedObjectContext]];
    
    dvController.quote = quote;
    dvController.owner = self;
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
    dvController = nil;    
}

- (void)refreshList
{
    [self refreshClientList];
}

- (void)refreshClientList
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Clients" inManagedObjectContext:[self managedObjectContext]];
    request.predicate = [NSPredicate predicateWithFormat:@"quotes.@count > 0"];  
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
        
        NSLog(@"quote clients: got %d entries", [[self.fetchedResultsController fetchedObjects] count]);
                
        [clientTable reloadData]; 
    }
     
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
        
        cell.detailTextLabel.text = @"There are no quotes defined"; 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        
        NSMutableDictionary * client = (NSMutableDictionary *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
        // Set up the cell 
        [cell.textLabel setText:[client valueForKey:@"name"]]; 
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
        //cell.detailTextLabel.text = [client valueForKey:@"email"]; 
        
        int q = [[client mutableSetValueForKey:@"quotes"] count];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i quotes", q];

        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }    
    
    // done.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) { return; }
    
    QuoteListViewController *dvController = [[QuoteListViewController alloc] initWithNibName:@"QuoteListView" bundle:[NSBundle mainBundle]];
    
    dvController.client = (NSMutableDictionary *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
    dvController = nil;    
    
}




@end
