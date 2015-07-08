//
//  SettingsCompanyViewController.m
//  invoicing
//
//  Created by George on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsCompanyViewController.h"


@implementation SettingsCompanyViewController


@synthesize scrollView;
@synthesize managedObjectContext, fetchedResultsController;


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
        
    self.navigationItem.title = @"Company Details";
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveCompany)] autorelease];
    
    // get database context
    invoicingAppDelegate *appDelegate = (invoicingAppDelegate *)[[UIApplication sharedApplication] delegate];   
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    // KEYBOARD
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:self.view.window];
    keyboardIsShown = NO;
    //make contentSize bigger than your scrollSize (you will need to figure out for your own use case)
    //CGSize scrollContentSize = CGSizeMake(320, 345);
    //self.scrollView.contentSize = scrollContentSize; 
    
    // Setup scroll view
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 650)];
    
    
    // get company information
    [self openCompany];
    
    //NSLog(@"scrollsize: %@", self.scrollView.contentSize);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardWillHide:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]; //UIKeyboardBoundsUserInfoKey
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    
    
    // resize the scrollview
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height += (keyboardSize.height - kTabBarHeight);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]; //UIKeyboardBoundsUserInfoKey
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    
    // resize the noteView
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height -= (keyboardSize.height - kTabBarHeight);
    
    
    CGRect textRect = [activeField frame];
    CGPoint textOffset = textRect.origin;
    
    textOffset.x = self.scrollView.frame.origin.x;
    textOffset.y -= keyboardSize.height - kTabBarHeight - 10;
    
    if (textOffset.y < 0) {
        textOffset.y = self.scrollView.frame.origin.y;
    }
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    [self.scrollView setFrame:viewFrame];
    [self.scrollView setContentOffset:textOffset];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}


-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.  
        
        //NSLog(@"rollback");
        //[[self managedObjectContext] rollback];
    }
    [super viewWillDisappear:animated];
}


- (void)openCompany
{
    // get all settings
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:[self managedObjectContext]];
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
        
        NSLog(@"settings: got %d entries", [[self.fetchedResultsController fetchedObjects] count]);
        
        //
        for (NSMutableDictionary *settings in self.fetchedResultsController.fetchedObjects) {
            
            //NSLog(@"checking %@ = %@", [settings valueForKey:@"name"], [settings valueForKey:@"value"]);
            
            if ([[settings valueForKey:@"name"] isEqual:@"company:name"]) {
                
                UICompanyName.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"company:code"]) {
                
                UICompanyCode.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"company:addr1"]) {
                
                UICompanyAddr1.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"company:addr2"]) {
                
                UICompanyAddr2.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"company:email"]) {
                
                UICompanyEmail.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"company:phone"]) {
                
                UICompanyPhone.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"company:bank"]) {
                
                UICompanyBank.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"company:account"]) {
                
                UICompanyAccount.text = [settings valueForKey:@"value"];
            }
            
            //[self.managedObjectContext deleteObject:(NSManagedObject*)settings];
        }
        
        /*
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            
            // Handle error
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
        }
        else {
            
            NSLog(@"Removed fine");
            
            //[self.navigationController popViewControllerAnimated:YES];
        }
        */ 
        
    }
}


- (void)saveCompany
{
    NSLog(@"Save Company");
    
    
    //[self.discount setValue:UIDiscountName.text forKey:@"name"];
    //[self.discount setValue:[NSNumber numberWithFloat:UIDiscountType.selectedSegmentIndex] forKey:@"type"];
    //[self.discount setValue:[NSNumber numberWithFloat:[UIDiscountValue.text floatValue]] forKey:@"value"];
    
    NSMutableArray * new_settings = [[NSMutableArray alloc] init];
    
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"company:name", @"name", UICompanyName.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"company:code", @"name", UICompanyCode.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"company:addr1", @"name", UICompanyAddr1.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"company:addr2", @"name", UICompanyAddr2.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"company:email", @"name", UICompanyEmail.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"company:phone", @"name", UICompanyPhone.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"company:bank", @"name", UICompanyBank.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"company:account", @"name", UICompanyAccount.text, @"value",nil] autorelease]];
    

    
    //NSLog(@"settings: %@", new_settings);
    //NSLog(@"existing: %@", self.fetchedResultsController.fetchedObjects);
    
    BOOL found = FALSE;
    
    for (NSMutableDictionary *settings2 in new_settings) {
    
        //NSLog(@"trying: %@", [settings2 valueForKey:@"name"]);
        
        found = FALSE;
        for (NSMutableDictionary *settings in self.fetchedResultsController.fetchedObjects) {
            
            if ([[settings valueForKey:@"name"] isEqual:[settings2 valueForKey:@"name"]]) {
            
                [settings setValue:[settings2 valueForKey:@"value"] forKey:@"value"];
                NSLog(@"updated %@ = %@", [settings2 valueForKey:@"name"], [settings2 valueForKey:@"value"]);
                
                found = TRUE;
            }
        }
        
        if (!found) {
            
            // initialize database managed object
            NSMutableDictionary * set = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:[self managedObjectContext]];
            
            [set setValue:[settings2 valueForKey:@"name"] forKey:@"name"];
            [set setValue:[settings2 valueForKey:@"value"] forKey:@"value"];
            
            NSLog(@"added %@ = %@", [settings2 valueForKey:@"name"], [settings2 valueForKey:@"value"]);
            
        }
    }
        
    [new_settings release];
    
    /*
    if ([self.discount valueForKey:@"name"] == nil || [self.discount valueForKey:@"name"] == @"") {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Discount must have a name" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    */
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }
    else {
        
        NSLog(@"Company Saved fine");
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


/******************* TEXT FIELD **********************/

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    NSLog(@"hide");
    [theTextField resignFirstResponder];
    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
	activeField = textField;
	return YES;
}


@end
