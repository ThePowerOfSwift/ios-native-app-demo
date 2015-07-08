//
//  QuoteListViewController.m
//  invoicing
//
//  Created by George on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuoteListViewController.h"
#import "QuoteDetailViewController.h"


@implementation QuoteListViewController


@synthesize client;
@synthesize fetchedResultsController, managedObjectContext;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self.fetchedResultsController release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //enable the "+" nav button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addQuote)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    self.navigationItem.title = [self.client valueForKey: @"name"];
    
    
    cellSize = CGSizeMake([mainTable bounds].size.width, 60);
    
    // get database context
    invoicingAppDelegate *appDelegate = (invoicingAppDelegate *)[[UIApplication sharedApplication] delegate];   
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    // retrieve client database 
    [self refreshQuoteList]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)addQuote
{
    NSLog(@"New Quote");
    
    QuoteDetailViewController *dvController = [[QuoteDetailViewController alloc] initWithNibName:@"QuoteDetailView" bundle:[NSBundle mainBundle]];
    
    // initialize database managed object
    NSMutableDictionary * quote = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Quotes" inManagedObjectContext:[self managedObjectContext]];
    
    dvController.owner = self;
    dvController.quote = quote;
    [dvController.quote setValue:client forKey:@"client"];
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
    dvController = nil;    
}

- (void)refreshList
{
    [self refreshQuoteList];
}

- (void)refreshQuoteList
{
    //NSLog(@"QUOTELIST");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Quotes" inManagedObjectContext:[self managedObjectContext]];
    request.predicate = [NSPredicate predicateWithFormat:@"client == %@", client];    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastupdate" ascending:NO ]];
                                                         
/*                                                        
                                        comparator:^(id obj1, id obj2) {
                                            
                                            //NSLog(@"INHERE");
                                            
                                            NSDate * d1 = [obj1 valueForKey:@"sent"] != nil ? 
                                                            [obj1 valueForKey:@"sent"] : [obj1 valueForKey:@"created"];
                                            NSDate * d2 = [obj2 valueForKey:@"sent"] != nil ? 
                                                            [obj2 valueForKey:@"sent"] : [obj2 valueForKey:@"created"];
                                            
                                            return [d2 compare:d1];
                                            
                                        }]];
*/    
    
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
        
        NSLog(@"quotes: got %d entries", [[self.fetchedResultsController fetchedObjects] count]);
        
        [mainTable reloadData]; 
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
    return [[self.fetchedResultsController fetchedObjects] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * quote = (NSMutableDictionary *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    NSString *CellIdentifier = @"Cell";
    if ([quote valueForKey:@"sent"] != nil) {
        CellIdentifier = @"CellSent";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell 
    [cell.textLabel setText:[quote valueForKey:@"title"]]; 
    cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    
    if ([quote valueForKey:@"sent"] != nil) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:kDateTimeFormat];
        NSString * sent = [dateFormatter stringFromDate:[quote valueForKey:@"sent"]];
    
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent: %@", sent];
    }
    else {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:kDateTimeFormat];
        NSString * updated = [dateFormatter stringFromDate:[quote valueForKey:@"lastupdate"]];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Updated: %@", updated];
    }

    if ([quote valueForKey:@"sent"] != nil) {
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(265, (44 - 24) / 2.0, 24, 24)];
        img.image = [UIImage imageNamed:@"attachment.png"];
    
        [cell.contentView addSubview:img];
    
        [img release];
    }
    
    // done.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    QuoteDetailViewController *dvController = [[QuoteDetailViewController alloc] initWithNibName:@"QuoteDetailView" bundle:[NSBundle mainBundle]];
    
    dvController.owner = self;
    dvController.quote = (NSMutableDictionary *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
    dvController = nil;    
    
}


@end
