//
//  SettingsViewController.h
//  invoicing
//
//  Created by George on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController {
    
    IBOutlet UITableView * mainTable; 
    
    CGSize cellSize;
    
    NSMutableArray * settings;
    
}

@end
