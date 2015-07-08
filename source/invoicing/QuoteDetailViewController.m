//
//  QuoteDetailViewController.m
//  invoicing
//
//  Created by George on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuoteDetailViewController.h"
#import "QuoteListViewController.h"
#import "QuoteClientListViewController.h"
#import "ClientListViewController.h"
#import "ProductListViewController.h"
#import "SettingsDiscountListViewController.h"
#import "SettingsTaxListViewController.h"
#import "PreviewViewController.h"

#import "InvoiceDetailViewController.h"


@implementation QuoteDetailViewController


@synthesize quote, owner, scrollView;
@synthesize managedObjectContext;
@synthesize total_products, total_discount, total_taxes, total_total;


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

    if ([self.quote valueForKey:@"client"] == nil) {
        
        self.navigationItem.title = @"New Quote";
    }    
    else {
        
        self.navigationItem.title = @"Edit Quote";
    }
    
    titleField.text = [self.quote valueForKey: @"title"];
    
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveQuote)] autorelease];
    
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
    
    
    [mainTable reloadData];
    
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, mainTable.contentSize.height + 200)];
    [mainTable setFrame:CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width, mainTable.contentSize.height + 100)];
    

    [self computeTotals];    
    
}

- (void)computeTotals
{
    total_products = 0; 
    total_discount = 0;
    total_taxes = 0;
    total_total = 0;
    
    float product_price;
    float product_discount;
    float product_tax;
    
    // products
    NSMutableSet *products = [self.quote mutableSetValueForKey:@"products"];
    for (NSMutableDictionary *used_product in products) {
        
        
        NSMutableDictionary *product = [used_product valueForKey:@"product"];
        product_price = [[product valueForKey:@"price"] floatValue]; 
        
        // discount
        product_discount = 0;
        
        if ([product valueForKey:@"discount"] != nil) {
            
            NSMutableDictionary *discount = [product valueForKey:@"discount"];
            
            // flat
            if ([[discount valueForKey:@"type"] intValue] == 0) {
                
                product_discount = [[discount valueForKey:@"value"] floatValue];
            }
            
            // percentage
            if ([[discount valueForKey:@"type"] intValue] == 1) {
                
                product_discount = [[discount valueForKey:@"value"] floatValue] * product_price / 100;
            }
        }
        
        // tax
        product_tax = 0;
        
        if ([product valueForKey:@"tax"] != nil) {
            
            NSMutableDictionary *tax = [product valueForKey:@"tax"];
            
            // flat
            if ([[tax valueForKey:@"type"] intValue] == 0) {
                
                product_tax = [[tax valueForKey:@"value"] floatValue];
            }
            
            // percentage
            if ([[tax valueForKey:@"type"] intValue] == 1) {
                
                product_tax = [[tax valueForKey:@"value"] floatValue] * product_price / 100;
            }
        }
        
        
        //product_price -= product_discount;
        //product_price += product_tax;
        
        //NSLog(@"adding %.2f", product_discount);
        
        total_discount += [[used_product valueForKey:@"quantity"] intValue] * product_discount;
        total_taxes += [[used_product valueForKey:@"quantity"] intValue] * product_tax;
        
        total_products += [[used_product valueForKey:@"quantity"] intValue] * [[product valueForKey:@"price"] floatValue];
        
    }
    
    // discount
    if ([self.quote valueForKey:@"discount"] != nil) {
        
        NSMutableDictionary *discount = [self.quote valueForKey:@"discount"];
        
        // flat
        if ([[discount valueForKey:@"type"] intValue] == 0) {
            
            total_discount += [[discount valueForKey:@"value"] floatValue];
        }
        
        // percentage
        if ([[discount valueForKey:@"type"] intValue] == 1) {
            
            total_discount += [[discount valueForKey:@"value"] floatValue] * total_products / 100;
        }
        
    }

    // taxes
    if ([self.quote valueForKey:@"tax"] != nil) {
        
        NSMutableDictionary *tax = [self.quote valueForKey:@"tax"];
        
        // flat
        if ([[tax valueForKey:@"type"] intValue] == 0) {
            
            total_taxes += [[tax valueForKey:@"value"] floatValue];
        }
        
        // percentage
        if ([[tax valueForKey:@"type"] intValue] == 1) {
            
            total_taxes += [[tax valueForKey:@"value"] floatValue] * total_products / 100;
        }
        
    }
    
    // totals
    total_total = total_products - total_discount + total_taxes;
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
    
    NSLog(@"will hide");
    
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
    
    NSLog(@"will show");
    
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
    
    textOffset.y += activeField.superview.frame.origin.y + activeField.superview.superview.frame.origin.y + activeField.superview.superview.superview.frame.origin.y; 
    
    NSLog(@"offset to %.2f, %.2f", textOffset.x, textOffset.y);
    
    
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

- (void)saveQuote
{
    NSLog(@"Save Quote");
    
    [self.quote setValue:titleField.text forKey:@"title"];
    
    if ([self.quote valueForKey:@"client"] == nil || [self.quote valueForKey:@"title"] == nil || [[self.quote valueForKey:@"title"] isEqual:@""]) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please assign a client and a title" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    [self.quote setValue:[NSDate date] forKey:@"lastupdate"];
    
    if ([self.quote valueForKey:@"created"] == nil) {
    
        [self.quote setValue:[NSDate date] forKey:@"created"];
    }
    
    if ([self.quote valueForKey:@"status"] == nil) {
        
        [self.quote setValue:@"draft" forKey:@"status"];
    }
    
    
    NSMutableSet *products = [self.quote mutableSetValueForKey:@"products"];
    NSMutableSet *iproducts = [NSMutableSet setWithSet:[self.quote mutableSetValueForKey:@"products"]];
    for (NSMutableDictionary *product in iproducts) {
        
        if ([[product valueForKey:@"quantity"] intValue] == 0) {
            
            //[self.managedObjectContext deleteObject: product];
            [products removeObject:product];
        }    
    }
    [self.quote setValue:products forKey:@"products"];
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }
    else {
        
        NSLog(@"Quote Saved fine");
        
        //[self.navigationController popViewControllerAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your quote was saved" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        if (self.owner != nil) {
            
            if ([self.owner isKindOfClass:[QuoteListViewController class]]) {
        
                [(QuoteListViewController *)self.owner refreshList];
            }
            
            if ([self.owner isKindOfClass:[QuoteClientListViewController class]]) {
                
                [(QuoteClientListViewController *)self.owner refreshList];
            }
        }
        
        [mainTable reloadData];
    }
}

-(IBAction)selectClient
{
    ClientListViewController *dvController = [[ClientListViewController alloc] initWithNibName:@"ClientListView" bundle:[NSBundle mainBundle]];
    
    dvController.owner = self;
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [self.navigationController pushViewController:dvController animated:YES];
    
    [dvController release];
    dvController = nil; 
}

- (void)setClient:(NSMutableDictionary *)client
{
    NSLog(@"got client: %@", client);
    
    [self.quote setValue:client forKey:@"client"];
    
    //[nameButton setTitle:[client valueForKey: @"name"] forState:UIControlStateNormal];
    
    [mainTable reloadData];
}

- (void)setProduct:(NSMutableDictionary *)product
{
    NSLog(@"got product: %@", product);
    
    // initialize database managed object
    NSMutableDictionary * used = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"ProductsUsed" inManagedObjectContext:[self managedObjectContext]];
    
    [used setValue:product forKey:@"product"];
    [used setValue:[NSNumber numberWithInt:1] forKey:@"quantity"];
    
    NSMutableSet *products = [self.quote mutableSetValueForKey:@"products"];
    [products addObject:used];
    
    [self computeTotals];    
    [mainTable reloadData];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, mainTable.contentSize.height + 200)];
    [mainTable setFrame:CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width, mainTable.contentSize.height + 100)];
}

- (void)setDiscount:(NSMutableDictionary *)discount
{
    NSLog(@"got discount: %@", discount);
    
    [self.quote setValue:discount forKey:@"discount"];
    
    [self computeTotals];    
    [mainTable reloadData];
}

- (void)setTax:(NSMutableDictionary *)tax
{
    NSLog(@"got tax: %@", tax);
    
    [self.quote setValue:tax forKey:@"tax"];
    
    [self computeTotals];    
    [mainTable reloadData];
}


/**************  TableView Delegate Functions  ***************/

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray * sections = [[[NSMutableArray alloc] initWithObjects:@"Client", @"Products", @"Discount", @"Tax", @"Totals", @"Other", nil] autorelease];
	
	return [sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSMutableArray * sections = [[[NSMutableArray alloc] initWithObjects:@"Client", @"Products", @"Discount", @"Tax", @"Totals", @"Other", nil] autorelease];

    return [sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // products
    if (section == 1) {
        return [[self.quote valueForKey:@"products"] count] + 1;
    }
    
    // products
    if (section == 4) {
        return 4;
    }
    
    // all other have only 1 row
    return 1; 
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int sx = [indexPath indexAtPosition: 0]; 
    int ix = [indexPath indexAtPosition: [indexPath length] - 1]; 
    
    NSString *CellIdentifier = @"Cell1";
    if (sx == 1 && ix > 0) {
        CellIdentifier = @"Cell2";
    }    
    //NSLog(@"identifier: %@", CellIdentifier);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    
    //NSLog(@"ix: %d, %d (%@)", sx, ix, CellIdentifier);
    
    
    // client
    if (sx == 0) {
        if ([self.quote valueForKey:@"client"] == nil) {

            [cell.textLabel setText:@"Click to Select"]; 
        }    
        else {

            [cell.textLabel setText:[[self.quote valueForKey: @"client"] valueForKey:@"name"]]; 
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
    }
    
    //if products
    if (sx == 1) {
        if (ix == 0) {
            [cell.textLabel setText:@"Click to Add"]; 
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
        }
        else {
            
            // NSMutableDictionary * quote = (NSMutableDictionary *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
            NSMutableSet *products = [self.quote mutableSetValueForKey:@"products"];
            //NSMutableDictionary * product = (NSMutableDictionary *) [[self.quote valueForKey:@"products"] objectAtIndex:ix];
            
            NSMutableDictionary * used = (NSMutableDictionary *) [[products allObjects] objectAtIndex:ix-1];
            NSMutableDictionary * product = (NSMutableDictionary *) [[[products allObjects] objectAtIndex:ix-1] valueForKey:@"product"];
            
            //[cell.textLabel setText:[product valueForKey:@"name"]]; 
            
            
            //Now we have to create the two labels.
            UILabel *label;
            UITextField *field;
            UIButton *button;
            CGRect cellRect;
            
            //Create a rectangle container for the number text.
            // cellRect = CGRectMake(TEXT_OFFSET, (ROW_HEIGHT – LABEL_HEIGHT) / 2.0, TEXT_WIDTH, LABEL_HEIGHT);
            cellRect = CGRectMake(10, (44 - 22) / 2.0, 180, 21);
            
            //Initialize the label with the rectangle.
            label = [[UILabel alloc] initWithFrame:cellRect];
            [label setText:[product valueForKey:@"name"]];
            label.font = [UIFont boldSystemFontOfSize:17.0];
            
            //Add the label as a sub view to the cell.
            [cell.contentView addSubview:label];
            [label release];
            
            
            //Create a rectangle container for the number text.
            // cellRect = CGRectMake(TEXT_OFFSET, (ROW_HEIGHT – LABEL_HEIGHT) / 2.0, TEXT_WIDTH, LABEL_HEIGHT);
            cellRect = CGRectMake(200, (44 - 22) / 2.0, 40, 28);
            
            //Initialize the label with the rectangle.
            field = [[UITextField alloc] initWithFrame:cellRect];
            field.borderStyle = UITextBorderStyleNone; //UITextBorderStyleLine;
            field.textAlignment = UITextAlignmentCenter;
            field.returnKeyType = UIReturnKeyDone;
            field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            field.backgroundColor = [UIColor whiteColor];
            [field setDelegate:self];  
            [field setText:[NSString stringWithFormat:@"%i", [[used valueForKey:@"quantity"] intValue]]];
            
            //Add the label as a sub view to the cell.
            [cell.contentView addSubview:field];
            [field release];
            
            
            // buttons
            cellRect = CGRectMake(175, (44 - 28) / 2.0, 28, 28);
            button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain]; //[[UIButton alloc] initWithFrame:cellRect];
            [button setFrame:cellRect];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal ];
            [button setTitle:@"-" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(quantityDown:) forControlEvents:UIControlEventTouchDown];
            button.tag = ix;
            
            [cell.contentView addSubview:button];
            [button release];
            
            
            cellRect = CGRectMake(240, (44 - 28) / 2.0, 28, 28);
            button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain]; //[[UIButton alloc] initWithFrame:cellRect];
            [button setFrame:cellRect];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal ];
            [button setTitle:@"+" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(quantityUp:) forControlEvents:UIControlEventTouchDown];
            button.tag = ix;
            
            [cell.contentView addSubview:button];
            [button release];
            
            
            cell.accessoryType = UITableViewCellAccessoryNone; 
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    // discount
    if (sx == 2) {
        if ([self.quote valueForKey:@"discount"] == nil) {
            
            [cell.textLabel setText:@"Click to Select"]; 
        }    
        else {
            
            [cell.textLabel setText:[[self.quote valueForKey: @"discount"] valueForKey:@"name"]]; 
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
    }
    
    // tax
    if (sx == 3) {
        if ([self.quote valueForKey:@"tax"] == nil) {
            
            [cell.textLabel setText:@"Click to Select"]; 
        }    
        else {
            
            [cell.textLabel setText:[[self.quote valueForKey: @"tax"] valueForKey:@"name"]]; 
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
    }
    
    // totals
    if (sx == 4) {
        
        
        //Now we have to create the two labels.
        UILabel *label1;
        UILabel *label2;
        
        CGRect cellRect1, cellRect2;
        
        //Create a rectangle container for the number text.
        // cellRect = CGRectMake(TEXT_OFFSET, (ROW_HEIGHT – LABEL_HEIGHT) / 2.0, TEXT_WIDTH, LABEL_HEIGHT);
        cellRect1 = CGRectMake(10, (44 - 22) / 2.0, 150, 21);
        
        //Initialize the label with the rectangle.
        label1 = [[UILabel alloc] initWithFrame:cellRect1];
        label1.font = [UIFont boldSystemFontOfSize:17.0];
        

        // cellRect = CGRectMake(TEXT_OFFSET, (ROW_HEIGHT – LABEL_HEIGHT) / 2.0, TEXT_WIDTH, LABEL_HEIGHT);
        cellRect2 = CGRectMake(160, (44 - 22) / 2.0, 100, 28);
        
        //Initialize the label with the rectangle.
        label2 = [[UILabel alloc] initWithFrame:cellRect2];
        label2.font = [UIFont boldSystemFontOfSize:17.0];
        label2.textAlignment = UITextAlignmentRight;
        
                
        if (ix == 0) {
            [label1 setText:@"Products"];
            [label2 setText:[NSString stringWithFormat:@"%.2f", total_products]];
        }
        if (ix == 1) {
            [label1 setText:@"Discount"];
            [label2 setText:[NSString stringWithFormat:@"- %.2f", total_discount]];
            
            label2.textColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
        }
        if (ix == 2) {
            [label1 setText:@"Taxes"];
            [label2 setText:[NSString stringWithFormat:@"+ %.2f", total_taxes]];
            
            label2.textColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
        }
        if (ix == 3) {
            [label1 setText:@"Total"];
            [label2 setText:[NSString stringWithFormat:@"%.2f", total_total]];
        }
        
        
        //Add the labels as a sub view to the cell.
        [cell.contentView addSubview:label1];
        [label1 release];
        
        [cell.contentView addSubview:label2];
        [label2 release];
        

        
        cell.accessoryType = UITableViewCellAccessoryNone; 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // client
    if (sx == 5) {
        [cell.textLabel setText:@"Options"]; 
    }
    
    
    /*
    // Set up the cell 
    [cell.textLabel setText:[quote valueForKey:@"title"]]; 
    cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    
    //cell.detailTextLabel.text = [quote valueForKey:@"email"]; 
    */
    
    //NSLog(@"size: %f - %f", mainTable.frame.size.height, mainTable.contentSize.height);
    
    // done.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    int sx = [indexPath indexAtPosition: 0]; 
    int ix = [indexPath indexAtPosition: [indexPath length] - 1]; 
    
    //NSLog(@"ix: %d, %d", sx, ix);
    
    
    // client
    if (sx == 0) {
        
        ClientListViewController *dvController = [[ClientListViewController alloc] initWithNibName:@"ClientListView" bundle:[NSBundle mainBundle]];
        
        dvController.owner = self;
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        
        [dvController release];
        dvController = nil;
    }
    
    // products
    if (sx == 1) {
        
        if (ix == 0) {
            
            ProductListViewController *dvController = [[ProductListViewController alloc] initWithNibName:@"ProductListView" bundle:[NSBundle mainBundle]];
        
            dvController.owner = self;
        
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
            [self.navigationController pushViewController:dvController animated:YES];
        
            [dvController release];
            dvController = nil;
        }
    }
    
    // discount
    if (sx == 2) {
        
        SettingsDiscountListViewController *dvController = [[SettingsDiscountListViewController alloc] initWithNibName:@"SettingsDiscountListView" bundle:[NSBundle mainBundle]];
        
        dvController.owner = self;
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        
        [dvController release];
        dvController = nil;
    }
    
    // tax
    if (sx == 3) {
        
        SettingsTaxListViewController *dvController = [[SettingsTaxListViewController alloc] initWithNibName:@"SettingsTaxListView" bundle:[NSBundle mainBundle]];
        
        dvController.owner = self;
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        
        [dvController release];
        dvController = nil;
    }
    
    // totals
    if (sx == 4) {
        
        // do nothing
    }
    
    // other
    if (sx == 5) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Send" otherButtonTitles:@"Preview", @"Print", @"Create Invoice", nil];
        [actionSheet showInView:self.parentViewController.tabBarController.view];
        [actionSheet release];  
    }    
}


/*********************** TEXT FIELD ***********************/

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    NSLog(@"hide");
    [theTextField resignFirstResponder];
    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
	NSLog(@"begin");
    activeField = textField;
	return YES;
}

/******************* UP/DOWN BUTTONS **********************/

- (void)quantityDown:(id)sender
{
    UIButton * button = (UIButton *) sender;
    int ix = button.tag;
    
    NSMutableSet *products = [self.quote mutableSetValueForKey:@"products"];
    NSMutableDictionary * used = (NSMutableDictionary *) [[products allObjects] objectAtIndex:ix-1];
    
    if ([[used valueForKey:@"quantity"] intValue] > 0) {
        [used setValue:[NSNumber numberWithInt:[[used valueForKey:@"quantity"] intValue] - 1] forKey:@"quantity"];
    }    
    
    [self computeTotals];
    [mainTable reloadData];
}

- (void)quantityUp:(id)sender
{
    UIButton * button = (UIButton *) sender;
    int ix = button.tag;
    
    NSMutableSet *products = [self.quote mutableSetValueForKey:@"products"];
    NSMutableDictionary * used = (NSMutableDictionary *) [[products allObjects] objectAtIndex:ix-1];
    
    [used setValue:[NSNumber numberWithInt:[[used valueForKey:@"quantity"] intValue] + 1] forKey:@"quantity"];
    
    [self computeTotals];
    [mainTable reloadData];
}

/******************* ACTION SHEET **********************/

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    
    // send
    if (buttonIndex == 0) {
        
        if ([MFMailComposeViewController canSendMail]) {
            
            PreviewViewController *dvController = [[PreviewViewController alloc] initWithNibName:@"PreviewView" bundle:[NSBundle mainBundle]];
            
            dvController.owner = self;
            
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
            
            [self.navigationController pushViewController:dvController animated:YES];
            
            [dvController emailWithTitle:titleField.text];
            
            [dvController release];
            dvController = nil;
            
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Emailing is not possible on your device." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
    
    // preview
    if (buttonIndex == 1) {
        
        PreviewViewController *dvController = [[PreviewViewController alloc] initWithNibName:@"PreviewView" bundle:[NSBundle mainBundle]];
        
        dvController.owner = self;
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        
        [dvController release];
        dvController = nil;
    }
    
    // print
    if (buttonIndex == 2) {
        
        if ([UIPrintInteractionController isPrintingAvailable]) {
        
            PreviewViewController *dvController = [[PreviewViewController alloc] initWithNibName:@"PreviewView" bundle:[NSBundle mainBundle]];
            
            dvController.owner = self;
            
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
            
            [self.navigationController pushViewController:dvController animated:YES];
            
            [dvController printWithTitle:titleField.text];
            
            [dvController release];
            dvController = nil;
            
        }
        else {
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Printing is not possible on your device." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
    
    // invoice
    if (buttonIndex == 3) {
        
        InvoiceDetailViewController *dvController = [[InvoiceDetailViewController alloc] initWithNibName:@"InvoiceDetailView" bundle:[NSBundle mainBundle]];
        
        // initialize database managed object
        NSMutableDictionary * invoice = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Invoices" inManagedObjectContext:[self managedObjectContext]];
        
        // title, client, discount, tax, products
        [invoice setValue:[self.quote valueForKey:@"title"] forKey:@"title"];
        [invoice setValue:[self.quote valueForKey:@"client"] forKey:@"client"];
        [invoice setValue:[self.quote valueForKey:@"discount"] forKey:@"discount"];
        [invoice setValue:[self.quote valueForKey:@"tax"] forKey:@"tax"];
        
        NSMutableDictionary * new_used;
        NSMutableSet * new_products = [invoice mutableSetValueForKey:@"products"];
        
        NSMutableSet *products = [self.quote mutableSetValueForKey:@"products"];
        for (NSMutableDictionary *used_product in products) {
        
            new_used = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"ProductsUsed" inManagedObjectContext:[self managedObjectContext]];
            
            [new_used setValue:[used_product valueForKey:@"product"] forKey:@"product"];
            [new_used setValue:[used_product valueForKey:@"quantity"] forKey:@"quantity"];
            
            [new_products addObject:new_used];
        }
    
        
        dvController.owner = self;
        dvController.invoice = invoice;
                
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
        dvController = nil;  
    }

}

@end





