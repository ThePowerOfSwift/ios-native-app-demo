//
//  ClientDetailViewController.m
//  invoicing
//
//  Created by George on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClientDetailViewController.h"
#import "ClientEditViewController.h"

#import "QuoteDetailViewController.h"
#import "InvoiceDetailViewController.h"


@implementation ClientDetailViewController

@synthesize client;
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
    
    self.navigationItem.title = [[self client] valueForKey: @"name"];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editClient)] autorelease];
    
    // get database context
    invoicingAppDelegate *appDelegate = (invoicingAppDelegate *)[[UIApplication sharedApplication] delegate];   
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self refreshClient];
}

- (void)editClient
{
    ClientEditViewController *dvController = [[ClientEditViewController alloc] initWithNibName:@"ClientEditView" bundle:[NSBundle mainBundle]];
        
    dvController.client = client;
    dvController.owner = self;
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    
    [dvController release];
    dvController = nil;
}

- (void)refreshClient
{
    //nameButton.titleLabel = [client objectForKey: @"name"];
    [nameButton setTitle:[client valueForKey: @"name"] forState:UIControlStateNormal];
    [emailButton setTitle:[client valueForKey: @"email"] forState:UIControlStateNormal];
    [phoneButton setTitle:[client valueForKey: @"phone"] forState:UIControlStateNormal];
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

-(IBAction)clickedName
{
    [self editClient];
}

-(IBAction)clickedEmail
{

    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        // Set up recipients
        NSArray *recp = [NSArray arrayWithObject:[client valueForKey:@"email"]];
        NSString *body = [NSString stringWithFormat:@"\n\n\n\n\nSent using %@.", kAppName];
        
        [picker setToRecipients:recp];
        [picker setMessageBody:body isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",[client valueForKey:@"email"]]];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(IBAction)clickedPhone
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[client valueForKey:@"phone"]]];
    
    [[UIApplication sharedApplication] openURL:url];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{

    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:

            NSLog(@"Mail: Cancelled");
            break;
        case MFMailComposeResultSaved:

            NSLog(@"Mail: Saved");
            break;
        case MFMailComposeResultSent:

            NSLog(@"Mail: Sent");
            break;
        case MFMailComposeResultFailed:

            NSLog(@"Mail: Failed");
            break;
        default:

            NSLog(@"Mail: Not Sent");
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)createQuote
{
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

-(IBAction)createInvoice
{
    InvoiceDetailViewController *dvController = [[InvoiceDetailViewController alloc] initWithNibName:@"InvoiceDetailView" bundle:[NSBundle mainBundle]];
    
    // initialize database managed object
    NSMutableDictionary * invoice = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Invoices" inManagedObjectContext:[self managedObjectContext]];
    
    dvController.owner = self;
    dvController.invoice = invoice;
    [dvController.invoice setValue:client forKey:@"client"];
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
    dvController = nil;  
}

@end
