//
//  SettingsTemplateViewController.m
//  invoicing
//
//  Created by George on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsTemplateViewController.h"


@implementation SettingsTemplateViewController


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
    
    self.navigationItem.title = @"Translation";
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveTemplate)] autorelease];
    
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
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 2025)];
    
    
    // get template information
    [self openTemplate];
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


-(IBAction)selectImage
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
//    [imagePicker setAllowsEditing:YES];
    [self presentModalViewController:imagePicker animated:YES];
    [imagePicker release];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"got: %@", info);
    
    //UIImageJPEGRepresentation( [info objectForKey:@"UIImagePickerControllerOriginalImage"] , 1.0);
    NSData *image = UIImagePNGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"]);
    //NSString *imageStr = [@"" stringByAppendingFormat:@"data:image/png;base64,%@", [self base64EncodingWithLineLength:0 data:image]];
    NSString *imageStr = [@"" stringByAppendingFormat:@"data:image/png;base64,%@", [self Base64Encode:image]];
    
    
    
    UITemplateLogoURL.text = imageStr;
    
    /*
    [info objectForKey:UIImagePickerControllerMediaURL];
    
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *newImage = [self createGameImage:selectedImage];
    [gameOptionsImageDisplay setImage:[self resizeImage:newImage toSize:CGSizeMake(95, 95)]];  
    [self dismissModalViewControllerAnimated:YES];
//    [mainView setFrame:CGRectMake(0, 0, 320, 480)]; 
     */
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
//    [mainView setFrame:CGRectMake(0, 0, 320, 480)];  
}

- (void)openTemplate
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
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:logo"]) {
                
                UITemplateLogoURL.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:quote:title"]) {
                
                UITemplateTitleQuote.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:invoice:title"]) {
                
                UITemplateTitleInvoice.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:regno"]) {
                
                UITemplateRegNo.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:bank:name"]) {
                
                UITemplateBank.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:bank:account"]) {
                
                UITemplateBankAccount.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:phone"]) {
                
                UITemplatePhone.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:email"]) {
                
                UITemplateEmail.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:invoice:number"]) {
                
                UITemplateInvoiceNo.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:date"]) {
                
                UITemplateDate.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:product"]) {
                
                UITemplateProduct.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:unit"]) {
                
                UITemplateUnit.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:unitcost"]) {
                
                UITemplateUnitCost.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:quantity"]) {
                
                UITemplateQuantity.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:price"]) {
                
                UITemplatePrice.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:subtotal"]) {
                
                UITemplateSubtotal.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:discount"]) {
                
                UITemplateDiscount.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:taxes"]) {
                
                UITemplateTaxes.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:total"]) {
                
                UITemplateTotal.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:quote:footer1"]) {
                
                UITemplateFooterQuote1.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:quote:footer2"]) {
                
                UITemplateFooterQuote2.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:quote:footer3"]) {
                
                UITemplateFooterQuote3.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:invoice:footer1"]) {
                
                UITemplateFooterInvoice1.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:invoice:footer2"]) {
                
                UITemplateFooterInvoice2.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:invoice:footer3"]) {
                
                UITemplateFooterInvoice3.text = [settings valueForKey:@"value"];
            }
            
            if ([[settings valueForKey:@"name"] isEqual:@"template:invoice:paynow"]) {
                
                UIPayNow.text = [settings valueForKey:@"value"];
            }
            
        }
        
    }
}


- (void)saveDefaults
{
    NSLog(@"defaults: %@", UITemplateTitleInvoice.text);
}


- (void)saveTemplate
{
    NSLog(@"Save Template");
    
    
    //[self.discount setValue:UIDiscountName.text forKey:@"name"];
    //[self.discount setValue:[NSNumber numberWithFloat:UIDiscountType.selectedSegmentIndex] forKey:@"type"];
    //[self.discount setValue:[NSNumber numberWithFloat:[UIDiscountValue.text floatValue]] forKey:@"value"];
    
    NSMutableArray * new_settings = [[NSMutableArray alloc] init];
    
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:logo", @"name", UITemplateLogoURL.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:quote:title", @"name", UITemplateTitleQuote.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:invoice:title", @"name", UITemplateTitleInvoice.text, @"value",nil] autorelease]];
    
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:regno", @"name", UITemplateRegNo.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:bank:name", @"name", UITemplateBank.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:bank:account", @"name", UITemplateBankAccount.text, @"value",nil] autorelease]];
    
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:phone", @"name", UITemplatePhone.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:email", @"name", UITemplateEmail.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:invoice:number", @"name", UITemplateInvoiceNo.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:date", @"name", UITemplateDate.text, @"value",nil] autorelease]];
    
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:product", @"name", UITemplateProduct.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:unit", @"name", UITemplateUnit.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:unitcost", @"name", UITemplateUnitCost.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:quantity", @"name", UITemplateQuantity.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:price", @"name", UITemplatePrice.text, @"value",nil] autorelease]];
    
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:subtotal", @"name", UITemplateSubtotal.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:discount", @"name", UITemplateDiscount.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:taxes", @"name", UITemplateTaxes.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:total", @"name", UITemplateTotal.text, @"value",nil] autorelease]];
    
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:quote:footer1", @"name", UITemplateFooterQuote1.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:quote:footer2", @"name", UITemplateFooterQuote2.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:quote:footer3", @"name", UITemplateFooterQuote3.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:invoice:footer1", @"name", UITemplateFooterInvoice1.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:invoice:footer2", @"name", UITemplateFooterInvoice2.text, @"value",nil] autorelease]];
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:invoice:footer3", @"name", UITemplateFooterInvoice3.text, @"value",nil] autorelease]];
    
    [new_settings addObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"template:invoice:paynow", @"name", UIPayNow.text, @"value",nil] autorelease]];
    
    
    
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
        
        NSLog(@"Template Saved fine");
        
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

/******************* BASE64 ENCODING **********************/

-(NSString *)Base64Encode:(NSData *)data
{
    //Point to start of the data and set buffer sizes
    int inLength = [data length];
    int outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
    const char *inputBuffer = [data bytes];
    char *outputBuffer = malloc(outLength);
    outputBuffer[outLength] = 0;
    
    //64 digit code
    static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    //start the count
    int cycle = 0;
    int inpos = 0;
    int outpos = 0;
    char temp;
    
    //Pad the last to bytes, the outbuffer must always be a multiple of 4
    outputBuffer[outLength-1] = '=';
    outputBuffer[outLength-2] = '=';
    
    /* http://en.wikipedia.org/wiki/Base64
     Text content   M           a           n
     ASCII          77          97          110
     8 Bit pattern  01001101    01100001    01101110
     
     6 Bit pattern  010011  010110  000101  101110
     Index          19      22      5       46
     Base64-encoded T       W       F       u
     */
    
    
    while (inpos < inLength){
        switch (cycle) {
            case 0:
                outputBuffer[outpos++] = Encode[(inputBuffer[inpos]&0xFC)>>2];
                cycle = 1;
                break;
            case 1:
                temp = (inputBuffer[inpos++]&0x03)<<4;
                outputBuffer[outpos] = Encode[temp];
                cycle = 2;
                break;
            case 2:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0)>> 4];
                temp = (inputBuffer[inpos++]&0x0F)<<2;
                outputBuffer[outpos] = Encode[temp];
                cycle = 3;                  
                break;
            case 3:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0)>>6];
                cycle = 4;
                break;
            case 4:
                outputBuffer[outpos++] = Encode[inputBuffer[inpos++]&0x3f];
                cycle = 0;
                break;                          
            default:
                cycle = 0;
                break;
        }
    }
    NSString *pictemp = [NSString stringWithUTF8String:outputBuffer];
    free(outputBuffer); 
    return pictemp;
}    

@end
