//
//  SettingsUnitDetailViewController.h
//  invoicing
//
//  Created by George on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsUnitDetailViewController : UIViewController {
    
    IBOutlet UITextField * UIName;
    
    NSMutableDictionary * unit;
    
    NSManagedObjectContext *managedObjectContext;
    
    UIViewController * owner;
    
}

@property (nonatomic, retain) NSMutableDictionary * unit;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIViewController * owner;

- (void)saveUnit;

@end
