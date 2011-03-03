//
//  MainViewController.h
//  worth-utility
//
//  Created by John Adams on 2/28/11.
//  Copyright 2011 John Adams. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
	IBOutlet UILabel *ticker;
	IBOutlet UILabel *curval;
	IBOutlet UILabel *valueline;
	IBOutlet UILabel *valueline_togo;

	IBOutlet UILabel *exercisecost;

	IBOutlet UILabel *progresspcnt;
	IBOutlet UILabel *progressline;	
	
}


@property (nonatomic, retain) UILabel *ticker;
@property (nonatomic, retain) UILabel *curval;
@property (nonatomic, retain) UILabel *valueline;
@property (nonatomic, retain) UILabel *valueline_togo;
@property (nonatomic, retain) UILabel *exercisecost;
@property (nonatomic, retain) UILabel *progresspcnt;
@property (nonatomic, retain) UILabel *progressline;


- (IBAction)showInfo:(id)sender;
- (void)calculateStock;

@end
