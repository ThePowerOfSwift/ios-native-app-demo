//
//  SettingsDiscountDetailViewController.m
//  invoicing
//
//  Created by George on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsDiscountDetailViewController.h"
#import "SettingsDiscountListViewController.h"


@implementation SettingsDiscountDetailViewController


@synthesize discount, owner, scrollView;
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
    
    if ([self.discount valueForKey:@"name"] == nil) {
        
        self.navigationItem.title = @"New Discount";
    }    
    else {
        
        self.navigationItem.title = @"Edit Discount";
        
        UIDiscountName.text = [self.discount valueForKey: @"name"];
        UIDiscountType.selectedSegmentIndex = [[self.discount valueForKey: @"type"] integerValue];
        UIDiscountValue.text = [NSString stringWithFormat:@"%.2f", [[self.discount valueForKey:@"value"] floatValue]];
        
    }
    
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveDiscount)] autorelease];
    
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
    CGSize scrollContentSize = CGSizeMake(320, 345);
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
        
        NSLog(@"rollback");
        [[self managedObjectContext] rollback];
    }
    [super viewWillDisappear:animated];
}

- (void)saveDiscount
{
    NSLog(@"Save Discount");
    
    
    [self.discount setValue:UIDiscountName.text forKey:@"name"];
    [self.discount setValue:[NSNumber numberWithFloat:UIDiscountType.selectedSegmentIndex] forKey:@"type"];
    [self.discount setValue:[NSNumber numberWithFloat:[UIDiscountValue.text floatValue]] forKey:@"value"];
    
    if ([self.discount valueForKey:@"name"] == nil || [[self.discount valueForKey:@"name"] isEqual:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Discount must have a name" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
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
        
        NSLog(@"Discount Saved fine");
        
        [self.navigationController popViewControllerAnimated:YES];
        
        if (self.owner != nil) {
            [(SettingsDiscountListViewController*)self.owner refreshList];
        }
        
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
