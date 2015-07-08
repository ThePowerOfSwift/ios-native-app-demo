//
//  ReportDetailViewController.m
//  invoicing
//
//  Created by George on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReportDetailViewController.h"

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@implementation ReportDetailViewController


@synthesize graphView;
@synthesize fetchedResultsController, managedObjectContext;


- (void)viewWillAppear:(BOOL)animated {
    
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {      
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
        self.view.bounds = CGRectMake(0.0, 0.0, 480, 320);
    }
     
     
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
    //self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
    self.graphView = [[S7GraphView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view = self.graphView;
	self.graphView.dataSource = self;
	
    //self.view.backgroundColor = [UIColor yellowColor];
}


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
    [graphView release];
    graphView = nil;
    
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
    
    
    // get database context
    invoicingAppDelegate *appDelegate = (invoicingAppDelegate *)[[UIApplication sharedApplication] delegate];   
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [NSString stringWithString:NSLocalizedString(@"Invoices", @"")],
                                             [NSString stringWithString:NSLocalizedString(@"Amounts", @"")],
                                             nil]];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    //segmentedControl.tintColor = [UIColor blackColor];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl setFrame:CGRectMake(0, 0, 200, 30)];
    [segmentedControl addTarget:self action:@selector(changeSegment:) forControlEvents:UIControlEventValueChanged];
    
    
    
    //[self.navigationController.toolbar addSubview:segmentedControl];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
    [segmentedControl release];
    
    
    [self plotGraph];
    
    [self.graphView reloadData];
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

- (NSUInteger)graphViewNumberOfPlots:(S7GraphView *)graphView {
    /* Return the number of plots you are going to have in the view. 1+ */
    
    return 2;
}

- (NSArray *)graphViewXValues:(S7GraphView *)graphView {
    /* An array of objects that will be further formatted to be displayed on the X-axis.
     The number of elements should be equal to the number of points you have for every plot. */
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    
    [comp setMonth:[comp month]-5];
    
    //NSDate *firstDayOfMonthDate = [gregorian dateFromComponents:comp];
    
    
    NSMutableArray * labels = [[[NSMutableArray alloc] initWithCapacity:6] autorelease];
    
    for (int i=0; i < 6; i++) {
        
        [labels addObject:[gregorian dateFromComponents:comp]];
        
        [comp setMonth:[comp month]+1];
        
    }
    
    [gregorian release];
    
    return labels;
}

- (NSArray *)graphView:(S7GraphView *)graphView yValuesForPlot:(NSUInteger)plotIndex {
    /* Return the values for a specific graph. Each plot is meant to have equal number of points.
     And this amount should be equal to the amount of elements you return from graphViewXValues: method. */
    
    
    NSMutableArray * values = [[[NSMutableArray alloc] initWithCapacity:6] autorelease];
    
    // setup predicate date
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    
    
    //[comp setMonth:[comp month]-5];
    if ([comp month]-5 < 1) {
        [comp setYear:[comp year]-1];
        [comp setMonth:[comp month]-5+12];
    }
    else {
        [comp setMonth:[comp month]-5]; 
    } 
    
    [comp setDay:1];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = plotIndex == 0 ? 
        [NSEntityDescription entityForName:@"Invoices" inManagedObjectContext:[self managedObjectContext]] : 
        [NSEntityDescription entityForName:@"Quotes" inManagedObjectContext:[self managedObjectContext]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sent" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"sent >= %@", [gregorian dateFromComponents:comp]];  
    
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                       initWithFetchRequest:request 
                                       managedObjectContext:[self managedObjectContext] 
                                       sectionNameKeyPath:nil 
                                       cacheName:nil];
    
    self.fetchedResultsController = frc;
    
    
    NSError *error = nil; 
    if (![self.fetchedResultsController performFetch:&error]) {
        
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //exit(-1);  // Fail
        
    }
    else {
        
        NSDateComponents *sent;
        
        //NSLog(@"products: got %d entries", [[self.fetchedResultsController fetchedObjects] count]);
        NSString *ident = [NSString stringWithFormat:@"%i%i", [comp year], [comp month]];
        int count = 0;
        for (NSMutableDictionary *invoice in self.fetchedResultsController.fetchedObjects) {
        
            sent = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[invoice valueForKey:@"sent"]];
            
            while (![ident isEqualToString:[NSString stringWithFormat:@"%i%i", [sent year], [sent month]]]) {
            
                [values addObject:[NSNumber numberWithInt:count]];
                
                if ([comp month]+1 > 12) {
                    [comp setYear:[comp year]+1];
                    [comp setMonth:1];
                }
                else {
                    [comp setMonth:[comp month]+1]; 
                }    
                
                ident = [NSString stringWithFormat:@"%i%i", [comp year], [comp month]];
                count = 0;
            }
            
            if (selected == 0) {
                count++;
            }
            else {
                count += [[NSNumber numberWithFloat:[self computeTotal:invoice]] intValue];
            }
                
        }
        
        
        // add 0 until today's date
        sent = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
        while (![ident isEqualToString:[NSString stringWithFormat:@"%i%i", [sent year], [sent month]]]) {
            
            //NSLog(@"Adding value for %@ -> %@", ident, [NSString stringWithFormat:@"%i%i", [sent year], [sent month]]);
            [values addObject:[NSNumber numberWithInt:count]];
            
            if ([comp month]+1 > 12) {
                [comp setYear:[comp year]+1];
                [comp setMonth:1];
            }
            else {
                [comp setMonth:[comp month]+1]; 
            } 
                
            ident = [NSString stringWithFormat:@"%i%i", [comp year], [comp month]];
            count = 0;
        }
        
        [values addObject:[NSNumber numberWithInt:count]];

    }
    
    [frc release];
    [request release];
    [gregorian release];
    
    return values;
}

- (void) plotGraph
{
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:0];
    [numberFormatter setMaximumFractionDigits:0];
    
    self.graphView.yValuesFormatter = numberFormatter;
    
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMM YY"];
    //[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    //[dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    self.graphView.xValuesFormatter = dateFormatter;
    
    
    //[dateFormatter release];        
    [numberFormatter release];
    
    self.graphView.backgroundColor = [UIColor blackColor];
    
    self.graphView.drawAxisX = YES;
    self.graphView.drawAxisY = YES;
    self.graphView.drawGridX = YES;
    self.graphView.drawGridY = YES;
    
    self.graphView.xValuesColor = [UIColor whiteColor];
    self.graphView.yValuesColor = [UIColor whiteColor];
    
    self.graphView.gridXColor = [UIColor whiteColor];
    self.graphView.gridYColor = [UIColor whiteColor];
    
    self.graphView.drawInfo = YES;
    self.graphView.info = @"Quotes: Green - Invoices: Blue";
    self.graphView.infoColor = [UIColor whiteColor];
}

- (void) changeSegment:(id)sender
{
    if ([(UISegmentedControl *)sender selectedSegmentIndex] == 0) {
        //self.graphView.info = @"Number of Invoices Sent";
    }
    
    if ([(UISegmentedControl *)sender selectedSegmentIndex] == 1) {
        //self.graphView.info = @"Value of Invoices Sent";
    }
    
    selected = [(UISegmentedControl *)sender selectedSegmentIndex];
        
    [self.graphView reloadData];
}

- (float)computeTotal:(NSMutableDictionary *)invoice
{
    float total_products = 0; 
    float total_discount = 0;
    float total_taxes = 0;
    float total_total = 0;
    
    float product_price;
    float product_discount;
    float product_tax;
    
    // products
    NSMutableSet *products = [invoice mutableSetValueForKey:@"products"];
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
    if ([invoice valueForKey:@"discount"] != nil) {
        
        NSMutableDictionary *discount = [invoice valueForKey:@"discount"];
        
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
    if ([invoice valueForKey:@"tax"] != nil) {
        
        NSMutableDictionary *tax = [invoice valueForKey:@"tax"];
        
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
    
    return total_total;
}

@end
