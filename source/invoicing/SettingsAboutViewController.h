//
//  SettingsAboutViewController.h
//  invoicing
//
//  Created by George on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface SettingsAboutViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
    IBOutlet UILabel * UIAppName;
    IBOutlet UILabel * UIAppVersion;
    
}

@property (nonatomic,retain) IBOutlet UILabel *UIAppName;

-(IBAction)clickedFeedback;

@end
