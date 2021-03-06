//
//  FlipsideViewController.h
//  worth-utility
//
//  Created by John Adams on 2/28/11.
//  Copyright 2011 John Adams. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;
@interface FlipsideViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate> {
	
	IBOutlet UIBarButtonItem  *doneBtn;
	IBOutlet UITextField *ticker;
	IBOutlet UITextField *shares_held;
	IBOutlet UITextField *shares_sold;
	IBOutlet UIButton *grant_date;
	IBOutlet UIButton *end_date;
	IBOutlet UITextField *strike_price;
	IBOutlet UITextField *current_price;
	IBOutlet UISwitch *firstyearcliff;
	IBOutlet UISegmentedControl *period;
	IBOutlet UISwitch *livestockquote;
	
	id <FlipsideViewControllerDelegate> delegate;
}

@property (nonatomic, retain) UIBarButtonItem *doneBtn;
@property (nonatomic, retain) UITextField *ticker;
@property (nonatomic, retain) UITextField *shares_held;
@property (nonatomic, retain) UITextField *shares_sold;
@property (nonatomic, retain) UIButton *grant_date;
@property (nonatomic, retain) UIButton *end_date;
@property (nonatomic, retain) UITextField *strike_price;
@property (nonatomic, retain) UITextField *current_price;
@property (nonatomic, retain) UISwitch *firstyearcliff;
@property (nonatomic, retain) UISwitch *livestockquote;
@property (nonatomic, retain) UISegmentedControl *period;
@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundTouched:(id)sender; 
- (IBAction)showVestingStartDatePicker:(id)sender;
- (IBAction)showVestingEndDatePicker:(id)sender;
- (IBAction)liveQuoteChanged:(id)sender; 
- (void) syncQuoteFields;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

