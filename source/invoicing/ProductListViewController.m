//
//  ProductListViewController.m
//  invoicing
//
//  Created by George on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductDetailViewController.h"

#import "QuoteDetailViewController.h"
#import "InvoiceDetailViewController.h"


@implementation ProductListViewController

@synthesize owner;
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
    
    self.navigationItem.title = @"Products";
    
    //enable the "+" nav button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProduct)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    
    cellSize = CGSizeMake([mainTable bounds].size.width, 60);
    
    // get database context
    invoicingAppDelegate *appDelegate = (invoicingAppDelegate *)[[UIApplication sharedApplication] delegate];   
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    // retrieve client database 
    [self refreshList]; 
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


- (void)addProduct
{
    NSLog(@"New Product");
    
    
    ProductDetailViewController *dvController = [[ProductDetailViewController alloc] initWithNibName:@"ProductDetailView" bundle:[NSBundle mainBundle]];
    
    // initialize database managed object
    NSMutableDictionary * product = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Products" inManagedObjectContext:[self managedObjectContext]];
    
    dvController.owner = self;
    dvController.product = product;
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
    dvController = nil;    
     
}


- (void)refreshList
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Products" inManagedObjectContext:[self managedObjectContext]];
    request.predicate = self.owner == nil ? nil : [NSPredicate predicateWithFormat:@"status = \"on\""];  
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
        
        NSLog(@"products: got %d entries", [[self.fetchedResultsController fetchedObjects] count]);
        
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
        
        cell.detailTextLabel.text = @"There are no products in your inventory"; 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        
        NSMutableDictionary * product = (NSMutableDictionary *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
        if ([[product valueForKey:@"status"] isEqual:@"off"]) {
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
        else {
            [cell.textLabel setTextColor:[UIColor blackColor]];
        }
        
        // Set up the cell 
        [cell.textLabel setText:[product valueForKey:@"name"]]; 
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", [[product valueForKey:@"price"] floatValue]]; 
        
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
            [(QuoteDetailViewController *)self.owner setProduct:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
        }   
        
        if ([self.owner isKindOfClass:[InvoiceDetailViewController class]]) {
            [(InvoiceDetailViewController *)self.owner setProduct:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
        } 
        
        [self.navigationController popViewControllerAnimated:YES];
        
        return;
    }
    
    ProductDetailViewController *dvController = [[ProductDetailViewController alloc] initWithNibName:@"ProductDetailView" bundle:[NSBundle mainBundle]];
    
    dvController.owner = self;
    dvController.product = (NSMutableDictionary *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
    dvController = nil;    
    
}


@end
