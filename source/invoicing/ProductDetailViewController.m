//
//  ProductDetailViewController.m
//  invoicing
//
//  Created by George on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductListViewController.h"
#import "SettingsUnitListViewController.h"
#import "SettingsDiscountListViewController.h"
#import "SettingsTaxListViewController.h"


@implementation ProductDetailViewController


@synthesize product, owner, scrollView;
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
    
    if ([self.product valueForKey:@"name"] == nil) {
        
        self.navigationItem.title = @"New Product";
    }    
    else {
        
        self.navigationItem.title = @"Edit Product";
        
        UIName.text = [self.product valueForKey: @"name"];
        UICode.text = [self.product valueForKey: @"code"];
        UIPrice.text = [NSString stringWithFormat:@"%.2f", [[self.product valueForKey:@"price"] floatValue]];
        
        UIStatus.on = [[self.product valueForKey: @"status"] isEqual:@"on"];
        
        if ([self.product valueForKey:@"unit"]) {
            [UIUnit setTitle:[[self.product valueForKey:@"unit"] valueForKey:@"name"] forState:UIControlStateNormal];
        }
        
        if ([self.product valueForKey:@"discount"]) {
            [UIDiscount setTitle:[[self.product valueForKey:@"discount"] valueForKey:@"name"] forState:UIControlStateNormal];
        }
        
        if ([self.product valueForKey:@"tax"]) {
            [UITax setTitle:[[self.product valueForKey:@"tax"] valueForKey:@"name"] forState:UIControlStateNormal];
        }
        
    }
    
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveProduct)] autorelease];
    
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
    CGSize scrollContentSize = CGSizeMake(320, 560);
    self.scrollView.contentSize = scrollContentSize; 
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

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.  
        
        NSLog(@"rollback");
        [[self managedObjectContext] rollback];
    }
    [super viewWillDisappear:animated];
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
    
    //textOffset.y = viewFrame.size.height - textRect.origin.y;
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



- (void)saveProduct
{
    NSLog(@"Save Product");
    
    
    [self.product setValue:UIName.text forKey:@"name"];
    [self.product setValue:UICode.text forKey:@"code"];
    [self.product setValue:[NSNumber numberWithFloat:[UIPrice.text floatValue]] forKey:@"price"];
    [self.product setValue:UIStatus.on ? @"on" : @"off" forKey:@"status"];
    
    NSLog(@"saving %@", [self.product valueForKey:@"price"]);
    
    if ([self.product valueForKey:@"name"] == nil || [[self.product valueForKey:@"name"] isEqual:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your product must have a name and price" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
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
        
        NSLog(@"Product Saved fine");
        
        [self.navigationController popViewControllerAnimated:YES];
        
        if (self.owner != nil) { 
            [(ProductListViewController*)self.owner refreshList];
        }
        
    }
}

-(IBAction)selectUnit
{
    SettingsUnitListViewController *dvController = [[SettingsUnitListViewController alloc] initWithNibName:@"SettingsUnitListView" bundle:[NSBundle mainBundle]];
    
    dvController.owner = self;
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    
    [dvController release];
    dvController = nil; 
}

-(IBAction)selectDiscount
{
    SettingsDiscountListViewController *dvController = [[SettingsDiscountListViewController alloc] initWithNibName:@"SettingsDiscountListView" bundle:[NSBundle mainBundle]];
    
    dvController.owner = self;
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    
    [dvController release];
    dvController = nil; 
}

-(IBAction)selectTax
{
    SettingsTaxListViewController *dvController = [[SettingsTaxListViewController alloc] initWithNibName:@"SettingsTaxListView" bundle:[NSBundle mainBundle]];
    
    dvController.owner = self;
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    
    [dvController release];
    dvController = nil; 
}

- (void)setUnit:(NSMutableDictionary *)unit
{
    NSLog(@"got unit: %@", unit);
    
    [self.product setValue:unit forKey:@"unit"];
    
    [UIUnit setTitle:[unit valueForKey: @"name"] forState:UIControlStateNormal];
}

- (void)setDiscount:(NSMutableDictionary *)discount
{
    NSLog(@"got discount: %@", discount);
    
    [self.product setValue:discount forKey:@"discount"];
    
    [UIDiscount setTitle:[discount valueForKey: @"name"] forState:UIControlStateNormal];
}

- (void)setTax:(NSMutableDictionary *)tax
{
    NSLog(@"got tax: %@", tax);
    
    [self.product setValue:tax forKey:@"tax"];
    
    [UITax setTitle:[tax valueForKey: @"name"] forState:UIControlStateNormal];
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
