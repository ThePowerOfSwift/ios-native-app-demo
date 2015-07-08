//
//  SettingsAboutViewController.m
//  invoicing
//
//  Created by George on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsAboutViewController.h"


@implementation SettingsAboutViewController

@synthesize UIAppName;

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
    
    self.navigationItem.title = @"About";
    
    UIAppName.text = kAppName;
    UIAppVersion.text = [@"Version " stringByAppendingString:kAppVersion];
    
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

-(IBAction)clickedFeedback
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        // Set up recipients
        NSArray *recp = [NSArray arrayWithObject:kFeedbackEmail];
        //NSString *body = [NSString stringWithFormat:@"\n\n\n\n\nSent using %@.", kAppName];
        
        [picker setToRecipients:recp];
        //[picker setMessageBody:body isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",kFeedbackEmail]];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your feedback has been sent.\nThank You!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
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

@end
