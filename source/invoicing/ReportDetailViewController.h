//
//  ReportDetailViewController.h
//  invoicing
//
//  Created by George on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "S7GraphView.h"


@interface ReportDetailViewController : UIViewController <S7GraphViewDataSource> {
    
    S7GraphView * graphView;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    int selected;
}

@property (nonatomic, retain) S7GraphView * graphView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


- (void) plotGraph;
- (void) changeSegment:(id)sender;

- (float)computeTotal:(NSMutableDictionary *)invoice;

@end
