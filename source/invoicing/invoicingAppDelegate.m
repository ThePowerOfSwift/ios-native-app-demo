//
//  invoicingAppDelegate.m
//  invoicing
//
//  Created by George on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "invoicingAppDelegate.h"
#import "ClientListViewController.h"
#import "SettingsCompanyViewController.h"
#import "SettingsOtherViewController.h"
#import "SettingsTemplateViewController.h"
#import "SettingsPaymentViewController.h"

#import "Appirater.h"


@implementation invoicingAppDelegate


@synthesize window=_window;

@synthesize tabBarController=_tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
//    @class ClientListViewController.managedObjectContext = self.managedObjectContext;
    
    [self install];
    
    [Appirater appLaunched:YES];
       
    return YES;
}

- (void) install 
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
    
    
    BOOL found = FALSE;
    
    NSError *error = nil;    
    if (![frc performFetch:&error]) {
        
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        // alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to setup initial settings.\nPlease use the feedback form to notify us of this problem." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        //exit(-1);  // Fail
    }
    else {
        
        //NSLog(@"settings: got %d entries", [[frc fetchedObjects] count]);
        
        for (NSMutableDictionary *settings in frc.fetchedObjects) {
            
            //NSLog(@"checking %@ = %@", [settings valueForKey:@"name"], [settings valueForKey:@"value"]);
            
            if ([[settings valueForKey:@"name"] isEqual:@"installed"]) {
                
                if ([[settings valueForKey:@"value"] isEqual:kAppVersion]) {
                    
                    found = TRUE;
                }
            }
        }
        
        if (!found) {
            
            
            // Company
            SettingsCompanyViewController *dvController1 = [[SettingsCompanyViewController alloc] initWithNibName:@"SettingsCompanyView" bundle:[NSBundle mainBundle]];
            
            [dvController1 viewDidLoad];
            [dvController1 saveCompany];
            [dvController1 viewDidUnload];
            
            [dvController1 release];
            dvController1 = nil; 
            
            
            // Other
            SettingsOtherViewController *dvController2 = [[SettingsOtherViewController alloc] initWithNibName:@"SettingsOtherView" bundle:[NSBundle mainBundle]];
            
            [dvController2 viewDidLoad];
            [dvController2 saveSettings];
            [dvController2 viewDidUnload];
            
            [dvController2 release];
            dvController2 = nil; 
            
            
            // Template
            SettingsTemplateViewController *dvController3 = [[SettingsTemplateViewController alloc] initWithNibName:@"SettingsTemplateView" bundle:[NSBundle mainBundle]];
            
            [dvController3 viewDidLoad];
            [dvController3 saveTemplate];
            [dvController3 viewDidUnload];
            
            [dvController3 release];
            dvController3 = nil; 
            
            // Payment
            SettingsPaymentViewController *dvController4 = [[SettingsPaymentViewController alloc] initWithNibName:@"SettingsPaymentView" bundle:[NSBundle mainBundle]];
            
            [dvController4 viewDidLoad];
            [dvController4 saveSettings];
            [dvController4 viewDidUnload];
            
            [dvController4 release];
            dvController4 = nil; 
            
            
            /*
            NSMutableDictionary * entry;
            
            // default units
            entry = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Units" inManagedObjectContext:[self managedObjectContext]];
            
            [entry setValue:@"Kg" forKey:@"name"];
            
            entry = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Units" inManagedObjectContext:[self managedObjectContext]];
            
            [entry setValue:@"Sqm" forKey:@"name"];
            
            // default discounts
            entry = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Discount" inManagedObjectContext:[self managedObjectContext]];
            
            [entry setValue:@"5% Off" forKey:@"name"];
            [entry setValue:[NSNumber numberWithFloat:5.0] forKey:@"value"];
            [entry setValue:[NSNumber numberWithInt:1] forKey:@"type"];
            
            // default taxes
            entry = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Taxes" inManagedObjectContext:[self managedObjectContext]];
            
            [entry setValue:@"20% VAT" forKey:@"name"];
            [entry setValue:[NSNumber numberWithFloat:20.0] forKey:@"value"];
            [entry setValue:[NSNumber numberWithInt:1] forKey:@"type"];
            
            entry = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Taxes" inManagedObjectContext:[self managedObjectContext]];
            
            [entry setValue:@"10% GST" forKey:@"name"];
            [entry setValue:[NSNumber numberWithFloat:10.0] forKey:@"value"];
            [entry setValue:[NSNumber numberWithInt:1] forKey:@"type"];
            */
            
            
            
            // set Installed = YES
            NSMutableDictionary * set = (NSMutableDictionary *)[NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:[self managedObjectContext]];
            
            [set setValue:@"installed" forKey:@"name"];
            [set setValue:kAppVersion forKey:@"value"];
             
            
            NSError *error = nil;
            if (![[self managedObjectContext] save:&error]) {
                
                // Handle error
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                
            }
            else {
                
                NSLog(@"Defaults Saved fine");
            }
            
        }
    }  
    
    [frc release];
    [request release];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/


// *** CORE DATA

//Explicitly write Core Data accessors
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"invoicing22.sqlite"]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:options error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end

