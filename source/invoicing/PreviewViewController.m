//
//  PreviewViewController.m
//  invoicing
//
//  Created by George on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreviewViewController.h"
#import "QuoteDetailViewController.h"
#import "InvoiceDetailViewController.h"

#import "Appirater.h"


@implementation PreviewViewController


@synthesize owner;
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
    //NSLog(@"DEALLOC");
    
    [self.fetchedResultsController release];
    
    //[file release];
    [lang release];
    
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
    
    self.navigationItem.title = @"Preview";
        
    // get database context
    invoicingAppDelegate *appDelegate = (invoicingAppDelegate *)[[UIApplication sharedApplication] delegate];   
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // get language
    lang = [[NSMutableDictionary alloc] init];
    [self openSettings];
    
    // load template
    NSString *path = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"htm"];  
    //file = [[NSString alloc] initWithContentsOfFile:path];
    NSError *error = nil;
    file = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    file = [file stringByReplacingOccurrencesOfString:@"{APPNAME}" withString:kAppName];
    
    if ([self.owner isKindOfClass:[QuoteDetailViewController class]]) {
        file = [file stringByReplacingOccurrencesOfString:@"{TYPE}" withString:@"quote"];
        
        file = [file stringByReplacingOccurrencesOfString:@"{INCLUDE_BANK}" withString:@"off"];
        file = [file stringByReplacingOccurrencesOfString:@"{INCLUDE_PAY}" withString:@"off"];
    }
    if ([self.owner isKindOfClass:[InvoiceDetailViewController class]]) {
        file = [file stringByReplacingOccurrencesOfString:@"{INCLUDE_BANK}" withString:[lang valueForKey:@"other:bankdetails"]];
        file = [file stringByReplacingOccurrencesOfString:@"{INCLUDE_PAY}" withString:[lang valueForKey:@"payment:paypal"]];
        
        file = [file stringByReplacingOccurrencesOfString:@"{TYPE}" withString:@"invoice"];
    }
    
    file = [file stringByReplacingOccurrencesOfString:@"{INCLUDE_CODE}" withString:[lang valueForKey:@"other:productcode"]];
    if ([[lang valueForKey:@"template:logo"] isEqual:@""]) {
        file = [file stringByReplacingOccurrencesOfString:@"{INCLUDE_LOGO}" withString:@"off"];
    }
    
    file = [file stringByReplacingOccurrencesOfString:@"{LOGO}" withString:[lang valueForKey:@"template:logo"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_QUOTE_TITLE}" withString:[lang valueForKey:@"template:quote:title"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_INVOICE_TITLE}" withString:[lang valueForKey:@"template:invoice:title"]];
    
    file = [file stringByReplacingOccurrencesOfString:@"{L_REGNO}" withString:[lang valueForKey:@"template:regno"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_BANK}" withString:[lang valueForKey:@"template:bank:name"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_ACCOUNT}" withString:[lang valueForKey:@"template:bank:account"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_PHONE}" withString:[lang valueForKey:@"template:phone"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_EMAIL}" withString:[lang valueForKey:@"template:email"]];
    
    file = [file stringByReplacingOccurrencesOfString:@"{L_INVOICENO}" withString:[lang valueForKey:@"template:invoice:number"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_DATE}" withString:[lang valueForKey:@"template:date"]];
    
    file = [file stringByReplacingOccurrencesOfString:@"{L_PRODUCT}" withString:[lang valueForKey:@"template:product"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_UNIT}" withString:[lang valueForKey:@"template:unit"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_UNITCOST}" withString:[lang valueForKey:@"template:unitcost"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_QUANTITY}" withString:[lang valueForKey:@"template:quantity"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_PRICE}" withString:[lang valueForKey:@"template:price"]];
    
    file = [file stringByReplacingOccurrencesOfString:@"{L_SUBTOTAL}" withString:[lang valueForKey:@"template:subtotal"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_DISCOUNT}" withString:[lang valueForKey:@"template:discount"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_TAXES}" withString:[lang valueForKey:@"template:taxes"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_TOTAL}" withString:[lang valueForKey:@"template:total"]];
    
    file = [file stringByReplacingOccurrencesOfString:@"{L_QUOTE_FOOTER1}" withString:[lang valueForKey:@"template:quote:footer1"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_QUOTE_FOOTER2}" withString:[lang valueForKey:@"template:quote:footer2"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_QUOTE_FOOTER3}" withString:[lang valueForKey:@"template:quote:footer3"]];
    
    file = [file stringByReplacingOccurrencesOfString:@"{L_INVOICE_FOOTER1}" withString:[lang valueForKey:@"template:invoice:footer1"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_INVOICE_FOOTER2}" withString:[lang valueForKey:@"template:invoice:footer2"]];
    file = [file stringByReplacingOccurrencesOfString:@"{L_INVOICE_FOOTER3}" withString:[lang valueForKey:@"template:invoice:footer3"]];
    
    file = [file stringByReplacingOccurrencesOfString:@"{L_PAYNOW}" withString:[lang valueForKey:@"template:invoice:paynow"]];
    
    // ------
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:kDateFormat];
    NSString *str_today = [dateFormatter stringFromDate:today];
    
    file = [file stringByReplacingOccurrencesOfString:@"{DATE}" withString:str_today];
    
    file = [file stringByReplacingOccurrencesOfString:@"{COMPANY}" withString:[lang valueForKey:@"company:name"]];
    file = [file stringByReplacingOccurrencesOfString:@"{ADDRESS1}" withString:[lang valueForKey:@"company:addr1"]];
    file = [file stringByReplacingOccurrencesOfString:@"{ADDRESS2}" withString:[lang valueForKey:@"company:addr2"]];
    file = [file stringByReplacingOccurrencesOfString:@"{PHONE}" withString:[lang valueForKey:@"company:phone"]];
    file = [file stringByReplacingOccurrencesOfString:@"{EMAIL}" withString:[lang valueForKey:@"company:email"]];
    file = [file stringByReplacingOccurrencesOfString:@"{REGNO}" withString:[lang valueForKey:@"company:code"]];
    if ([[lang valueForKey:@"other:bankdetails"] isEqual:@"on"]) {
        
        file = [file stringByReplacingOccurrencesOfString:@"{BANK}" withString:[lang valueForKey:@"company:bank"]];
        file = [file stringByReplacingOccurrencesOfString:@"{ACCOUNT}" withString:[lang valueForKey:@"company:account"]];
    }    
    
    file = [file stringByReplacingOccurrencesOfString:@"{CURRENCY}" withString:[lang valueForKey:@"other:currency"]];
    
    
    NSMutableSet *products;
    
    // totals
    if ([self.owner isKindOfClass:[QuoteDetailViewController class]]) {
        
        QuoteDetailViewController * o = (QuoteDetailViewController *) self.owner; 
        
        file = [file stringByReplacingOccurrencesOfString:@"{CUSTOMER}" withString:[[o.quote valueForKey:@"client"] valueForKey:@"name"]];
        
        file = [file stringByReplacingOccurrencesOfString:@"{TOTAL}" withString:[NSString stringWithFormat:@"%.2f", [o total_total]]];
        file = [file stringByReplacingOccurrencesOfString:@"{SUBTOTAL}" withString:[NSString stringWithFormat:@"%.2f", [o total_products]]];
        file = [file stringByReplacingOccurrencesOfString:@"{DISCOUNT}" withString:[NSString stringWithFormat:@"%.2f", [o total_discount]]];
        file = [file stringByReplacingOccurrencesOfString:@"{TAXES}" withString:[NSString stringWithFormat:@"%.2f", [o total_taxes]]];
        
        products = [o.quote mutableSetValueForKey:@"products"];
    }
    
    if ([self.owner isKindOfClass:[InvoiceDetailViewController class]]) {
        
        InvoiceDetailViewController * o = (InvoiceDetailViewController *) self.owner; 
        
        file = [file stringByReplacingOccurrencesOfString:@"{CUSTOMER}" withString:[[o.invoice valueForKey:@"client"] valueForKey:@"name"]];
        
        file = [file stringByReplacingOccurrencesOfString:@"{INVOICENO}" withString:[NSString stringWithFormat:@"%i", [[o.invoice valueForKey:@"index"] intValue]]];
        
        file = [file stringByReplacingOccurrencesOfString:@"{TOTAL}" withString:[NSString stringWithFormat:@"%.2f", [o total_total]]];
        file = [file stringByReplacingOccurrencesOfString:@"{SUBTOTAL}" withString:[NSString stringWithFormat:@"%.2f", [o total_products]]];
        file = [file stringByReplacingOccurrencesOfString:@"{DISCOUNT}" withString:[NSString stringWithFormat:@"%.2f", [o total_discount]]];
        file = [file stringByReplacingOccurrencesOfString:@"{TAXES}" withString:[NSString stringWithFormat:@"%.2f", [o total_taxes]]];
        
        
        if ([[lang valueForKey:@"payment:paypal"] isEqual:@"on"]) {
            
            file = [file stringByReplacingOccurrencesOfString:@"{PAYPAL}" withString:
                    [NSString stringWithFormat:@"https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=%@&item_name=%@&item_number=%i&amount=%.2f&currency_code=%@", 
                     [lang valueForKey:@"payment:paypal:email"], 
                     [NSString stringWithFormat:@"%@ %i", [lang valueForKey:@"template:invoice:number"], [[o.invoice valueForKey:@"index"] intValue]], 
                     [[o.invoice valueForKey:@"index"] intValue], 
                     [o total_total], 
                     [lang valueForKey:@"payment:paypal:currency"]]
                    ];
        }   
        
        
        products = [o.invoice mutableSetValueForKey:@"products"];
    }
    
    
    // locate product template
    NSRange start = [file rangeOfString:@"{PRODUCT}"];
    NSRange end = [file rangeOfString:@"{/PRODUCT}"];
    NSRange range = NSMakeRange(start.location + start.length, end.location - start.location - start.length);
    
    NSString * product_tpl = [file substringWithRange:range];
    
    // remove product from template
    file = [file stringByReplacingOccurrencesOfString:product_tpl withString:@""];
    
    // loop products
    
    for (NSMutableDictionary *used_product in products) {
        
        NSString * tpl = [NSString stringWithString:product_tpl];
        
        NSMutableDictionary *product = [used_product valueForKey:@"product"];
        
        tpl = [tpl stringByReplacingOccurrencesOfString:@"{NAME}" withString:[product valueForKey:@"name"]];
        if ([[lang valueForKey:@"other:productcode"] isEqual:@"on"]) {
            
            tpl = [tpl stringByReplacingOccurrencesOfString:@"{CODE}" withString:[product valueForKey:@"code"]];
        }
        else {
            tpl = [tpl stringByReplacingOccurrencesOfString:@"{CODE}" withString:@""];
        }
        if ([product valueForKey:@"unit"] != nil) {
            
            tpl = [tpl stringByReplacingOccurrencesOfString:@"{UNIT}" withString:[[product valueForKey:@"unit"] valueForKey:@"name"]];
        }
        else {
            tpl = [tpl stringByReplacingOccurrencesOfString:@"{UNIT}" withString:@"-"];
        }
        tpl = [tpl stringByReplacingOccurrencesOfString:@"{QUANTITY}" 
                                             withString:[NSString stringWithFormat:@"%i", [[used_product valueForKey:@"quantity"] intValue]]];
        tpl = [tpl stringByReplacingOccurrencesOfString:@"{UNITPRICE}" 
                                             withString:[NSString stringWithFormat:@"%.2f", [[product valueForKey:@"price"] floatValue]]];
        tpl = [tpl stringByReplacingOccurrencesOfString:@"{QUANTITYPRICE}" 
                                             withString:[NSString stringWithFormat:@"%.2f", [[product valueForKey:@"price"] floatValue] * [[used_product valueForKey:@"quantity"] intValue]]];
        
        file = [file stringByReplacingOccurrencesOfString:@"{/PRODUCT}" withString:[tpl stringByAppendingString:@"{/PRODUCT}"]];
    }  
    
    
    file = [file stringByReplacingOccurrencesOfString:@"{PRODUCT}" withString:@""];
    file = [file stringByReplacingOccurrencesOfString:@"{/PRODUCT}" withString:@""];
    
    
    [preview loadHTMLString:file baseURL:nil];
    //preview_t.text = file;

}

- (void)viewDidUnload
{
    //NSLog(@"DID UNLOAD");
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //NSLog(@"ROTATE: %i", interfaceOrientation);
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)openSettings
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
            
            [lang setValue:[settings valueForKey:@"value"] forKey:[settings valueForKey:@"name"]];
            
        }
        
    }
}

- (void) printWithTitle:(NSString *)title
{
    if ([UIPrintInteractionController isPrintingAvailable]) {
        
        UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = title; 
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        
        controller.printInfo = printInfo;
        controller.showsPageRange = YES;
        //controller.printingItem = [NSData data];
        
        
        // assign data to print
        //NSString *html = [preview stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
        
        NSLog(@"HTML: %@", file);
        
        UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:file];
        htmlFormatter.startPage = 0;
        htmlFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1-inch margins on all sides
        //htmlFormatter.maximumContentWidth = 6 * 72.0;   // printed content should be 6-inches wide within those margins
        controller.printFormatter = htmlFormatter;
        [htmlFormatter release];
        
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"Printing could not complete because of error: %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error while trying to print." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            }
        };
        
        [controller presentAnimated:YES completionHandler:completionHandler];
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Printing is not possible on your device." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (void) emailWithTitle:(NSString *)title
{
    NSMutableDictionary * client = nil;
    
    if ([self.owner isKindOfClass:[QuoteDetailViewController class]]) {
        QuoteDetailViewController * o = (QuoteDetailViewController *) self.owner; 
        client = [o.quote valueForKey:@"client"];
    }   
    if ([self.owner isKindOfClass:[InvoiceDetailViewController class]]) {
        InvoiceDetailViewController * o = (InvoiceDetailViewController *) self.owner; 
        client = [o.invoice valueForKey:@"client"];
    } 
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        // Set up recipients
        NSArray *recp = [NSArray arrayWithObject:[client valueForKey:@"email"]];
        
        [picker setSubject:title];
        [picker setToRecipients:recp];
        [picker setMessageBody:file isHTML:YES];
        
        if ([[lang valueForKey:@"other:bcc"] length] > 0) {
            
            NSArray *bcc = [NSArray arrayWithObject:[lang valueForKey:@"other:bcc"]];
            [picker setBccRecipients:bcc];
        }
        
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",[client valueForKey:@"email"]]];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    if (result == MFMailComposeResultSent) {
        
        if ([self.owner isKindOfClass:[QuoteDetailViewController class]]) {
            
            QuoteDetailViewController * o = (QuoteDetailViewController *) self.owner; 
            [o.quote setValue:[NSDate date] forKey:@"lastupdate"];
            [o.quote setValue:[NSDate date] forKey:@"sent"];
            [o.quote setValue:@"sent" forKey:@"status"];
            [o saveQuote];
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Quote Sent." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        
        if ([self.owner isKindOfClass:[InvoiceDetailViewController class]]) {
            
            InvoiceDetailViewController * o = (InvoiceDetailViewController *) self.owner; 
            [o.invoice setValue:[NSDate date] forKey:@"lastupdate"];
            [o.invoice setValue:[NSDate date] forKey:@"sent"];
            [o.invoice setValue:@"sent" forKey:@"status"];
            
            [o saveInvoice];
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Invoice Sent." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
            
            [Appirater userDidSignificantEvent:YES];
        }
        
    }
    
    
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

- (void) payWithPaypal
{
    if ([self.owner isKindOfClass:[InvoiceDetailViewController class]]) {
        
        InvoiceDetailViewController * o = (InvoiceDetailViewController *) self.owner; 
    
        [o.invoice setValue:[NSDate date] forKey:@"lastupdate"];
        [o saveInvoice];
        
        NSLog(@"PAYMENT: %@", [NSString stringWithFormat:@"http://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=%@&item_name=%@&item_number=%i&amount=%.2f&currency_code=%@", 
                               [lang valueForKey:@"payment:paypal:email"],
                               [[NSString stringWithFormat:@"%@ %i", [lang valueForKey:@"template:invoice:number"], [[o.invoice valueForKey:@"index"] intValue]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                               [[o.invoice valueForKey:@"index"] intValue], 
                               [o total_total], 
                               [lang valueForKey:@"payment:paypal:currency"]]);
        
        [[UIApplication sharedApplication] 
         openURL:[NSURL URLWithString: 
                  
                  [NSString stringWithFormat:@"http://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=%@&item_name=%@&item_number=%i&amount=%.2f&currency_code=%@", 
                   [lang valueForKey:@"payment:paypal:email"],
                   [[NSString stringWithFormat:@"%@ %i", [lang valueForKey:@"template:invoice:number"], [[o.invoice valueForKey:@"index"] intValue]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                   [[o.invoice valueForKey:@"index"] intValue], 
                   [o total_total], 
                   [lang valueForKey:@"payment:paypal:currency"]]
                                                
                  ]];

    }

}

@end
