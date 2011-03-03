//
//  FlipsideViewController.h
//  worth-utility
//
//  Created by John Adams on 2/28/11.
//  Copyright 2011 Twitter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;
@interface FlipsideViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate> {
	
	IBOutlet UIBarButtonItem  *doneBtn;
	IBOutlet UITextField *ticker;
	IBOutlet UITextField *shares_held;
	IBOutlet UITextField *shares_sold;
	IBOutlet UITextField *grant_date;
	IBOutlet UITextField *end_date;
	IBOutlet UITextField *strike_price;
	IBOutlet UITextField *current_price;
	IBOutlet UISwitch *firstyearcliff;
	IBOutlet UISegmentedControl *period;
	
	id <FlipsideViewControllerDelegate> delegate;
}

@property (nonatomic, retain) UIBarButtonItem *doneBtn;
@property (nonatomic, retain) UITextField *ticker;
@property (nonatomic, retain) UITextField *shares_held;
@property (nonatomic, retain) UITextField *shares_sold;
@property (nonatomic, retain) UITextField *grant_date;
@property (nonatomic, retain) UITextField *end_date;
@property (nonatomic, retain) UITextField *strike_price;
@property (nonatomic, retain) UITextField *current_price;
@property (nonatomic, retain) UISwitch *firstyearcliff;
@property (nonatomic, retain) UISegmentedControl *period;
@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundTouched:(id)sender; 
- (IBAction)showVestingStartDatePicker:(id)sender;
- (IBAction)showVestingEndDatePicker:(id)sender;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

