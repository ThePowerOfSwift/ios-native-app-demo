//
//  SettingsUnitDetailViewController.m
//  invoicing
//
//  Created by George on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsUnitDetailViewController.h"
#import "SettingsUnitListViewController.h"


@implementation SettingsUnitDetailViewController


@synthesize unit, owner;
@synthesize managedObjectContext;


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
    
    if ([self.unit valueForKey:@"name"] == nil) {
        
        self.navigationItem.title = @"New Unit";
    }    
    else {
        
        self.navigationItem.title = @"Edit Unit";
    }
    
    UIName.text = [self.unit valueForKey: @"name"];
    
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveUnit)] autorelease];
    
    // get database context
    invoicingAppDelegate *appDelegate = (invoicingAppDelegate *)[[UIApplication sharedApplication] delegate];   
    self.managedObjectContext = appDelegate.managedObjectContext;
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

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.  
        
        NSLog(@"rollback");
        [[self managedObjectContext] rollback];
    }
    [super viewWillDisappear:animated];
}

- (void)saveUnit
{
    NSLog(@"Save Unit");
    
    [self.unit setValue:UIName.text forKey:@"name"];
    
    if ([self.unit valueForKey:@"name"] == nil || [[self.unit valueForKey:@"name"] isEqual:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please assign a name." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }
    else {
        
        NSLog(@"Unit Saved fine");
        
        [self.navigationController popViewControllerAnimated:YES];
        
        if (self.owner != nil) {
            [(SettingsUnitListViewController*)self.owner refreshList];
        }
        
    }
}


/******************* TEXT FIELD **********************/

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    NSLog(@"hide");
    [theTextField resignFirstResponder];
    return YES;
}



@end
