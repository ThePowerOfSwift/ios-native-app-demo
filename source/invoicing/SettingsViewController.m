//
//  SettingsViewController.m
//  invoicing
//
//  Created by George on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsUnitListViewController.h"
#import "SettingsTaxListViewController.h"
#import "SettingsDiscountListViewController.h"
#import "SettingsCompanyViewController.h"
#import "SettingsOtherViewController.h"
#import "SettingsTemplateViewController.h"
#import "SettingsAboutViewController.h"
#import "SettingsPaymentViewController.h"
#import "ReportDetailViewController.h"


@implementation SettingsViewController

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
    [settings release];
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
    
    cellSize = CGSizeMake([mainTable bounds].size.width, 60);
    
    
    /*
    NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    settings = [[NSMutableArray alloc] initWithContentsOfFile:path];
    */
    
    settings = [[NSMutableArray alloc] initWithObjects:
                             @"Company Details", @"Measuring Units", @"Taxes", @"Discounts", @"Template Settings", @"Other Settings", @"Payment", @"Reports", @"About", nil];

    
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


/**************  TableView Delegate Functions  ***************/

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [settings count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    int ix = [indexPath indexAtPosition: [indexPath length] - 1]; 
    
    // Set up the cell 
    [cell.textLabel setText:[settings objectAtIndex:ix]]; 
    cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    //cell.detailTextLabel.text = [[settings objectAtIndex:ix] valueForKey:@"detail"]; 
    
    // done.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int ix = [indexPath indexAtPosition: [indexPath length] - 1];
    
    NSLog(@"selected: %d, %@", ix, [settings objectAtIndex: ix]); 
    
    if (ix == 0) {
        
        SettingsCompanyViewController *dvController = [[SettingsCompanyViewController alloc] initWithNibName:@"SettingsCompanyView" bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;   
        
    }
    
    if (ix == 1) {
        
        SettingsUnitListViewController *dvController = [[SettingsUnitListViewController alloc] initWithNibName:@"SettingsUnitListView" bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;   
    
    }
    
    if (ix == 2) {
        
        SettingsTaxListViewController *dvController = [[SettingsTaxListViewController alloc] initWithNibName:@"SettingsTaxListView" bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;   
        
    }
    
    if (ix == 3) {
        
        SettingsDiscountListViewController *dvController = [[SettingsDiscountListViewController alloc] initWithNibName:@"SettingsDiscountListView" bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;   
        
    }
    
    if (ix == 4) {
        
        SettingsTemplateViewController *dvController = [[SettingsTemplateViewController alloc] initWithNibName:@"SettingsTemplateView" bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;   
        
    }
    
    if (ix == 5) {
        
        SettingsOtherViewController *dvController = [[SettingsOtherViewController alloc] initWithNibName:@"SettingsOtherView" bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;   
        
    }
    
    if (ix == 6) {
        
        SettingsPaymentViewController *dvController = [[SettingsPaymentViewController alloc] initWithNibName:@"SettingsPaymentView" bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;   
        
    }
    
    if (ix == 7) {
        
        ReportDetailViewController *dvController = [[ReportDetailViewController alloc] initWithNibName:@"ReportDetailView" bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;   
        
    }
    
    if (ix == 8) {
        
        SettingsAboutViewController *dvController = [[SettingsAboutViewController alloc] initWithNibName:@"SettingsAboutView" bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;   
        
    }
    
}


@end
