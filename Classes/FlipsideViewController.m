//
//  FlipsideViewController.m
//  worth-utility
//
//  Created by John Adams on 2/28/11.
//  Copyright 2011 John Adams. All rights reserved.
//

#import "FlipsideViewController.h"

@implementation FlipsideViewController

@synthesize delegate;
@synthesize doneBtn;
@synthesize ticker;
@synthesize shares_held;
@synthesize shares_sold;

@synthesize grant_date;
@synthesize end_date;

@synthesize strike_price;
@synthesize current_price;

@synthesize firstyearcliff;
@synthesize period;

#define kDatePickerTag 100


- (BOOL)validateForm {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// returns TRUE if all fields validate. 
		
	if (ticker.text.length == 0) 
		return FALSE;
	
	if ([ shares_held.text intValue ] == 0)
		return FALSE;
	
	if ([ shares_held.text intValue ] < [ shares_sold.text intValue])
		return FALSE;
	
	if ([ current_price.text floatValue ] == 0.00 )
		return FALSE;
	
	if ([ strike_price.text floatValue ] == 0.00 )
		return FALSE;

	
	NSDate *vsDate =  [defaults objectForKey:@"grant_date"];
	NSDate *veDate =  [defaults objectForKey:@"end_date"];
	NSTimeInterval delta;
	if (vsDate && veDate) { 
		// end date must be later than start date
		delta = ([veDate timeIntervalSinceDate:vsDate] / 86400);  
		if (delta <= 0)
			return FALSE;
	} else {
		return FALSE;
	}
	
	return TRUE;
}


- (void)viewDidLoad {
	[super viewDidLoad];

	// Load defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *tickerValue		= [defaults stringForKey:@"ticker"];
	float strikePriceValue		= [defaults floatForKey:@"strike_price"];
	float curPriceValue			= [defaults floatForKey:@"current_price"];
	NSInteger sharesheldValue	= [defaults integerForKey:@"shares_held"];
	NSInteger sharessoldValue	= [defaults integerForKey:@"shares_sold"];
	NSDate *grantDate			= [defaults objectForKey:@"grant_date"];
	NSDate *endDate				= [defaults objectForKey:@"end_date"];
	BOOL firstyearValue			= [defaults boolForKey:@"firstyearcliff"];
	NSInteger periodValue		= [defaults integerForKey:@"periodselected"];
	
	// format strings and populate
	ticker.text = tickerValue;
	strike_price.text = [NSString stringWithFormat:@"%.2f", strikePriceValue];
	current_price.text = [NSString stringWithFormat:@"%.2f", curPriceValue];
	shares_held.text = [NSString stringWithFormat:@"%d", sharesheldValue];
	shares_sold.text = [NSString stringWithFormat:@"%d", sharessoldValue];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];	

	if (grantDate)
		[grant_date setTitle:[dateFormatter stringFromDate:grantDate] forState:UIControlStateNormal ];

	if (endDate)
		[end_date setTitle:[dateFormatter stringFromDate:endDate] forState:UIControlStateNormal ];

	[dateFormatter release];
	
	 
	// switches and segmeneted controls
	firstyearcliff.on = firstyearValue;
	period.selectedSegmentIndex = periodValue;
	
	// Done button is locked out until everything is valid
	doneBtn.enabled = [self validateForm];
	
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];      
}


- (IBAction)done:(id)sender {
	// update prefs and close the view
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// store preferences
	[defaults setBool:TRUE forKey:@"setupDone"];

	[defaults setObject:ticker.text forKey:@"ticker"];
	[defaults setInteger:[shares_held.text intValue] forKey:@"shares_held"];
	[defaults setInteger:[shares_sold.text intValue] forKey:@"shares_sold"];

	[defaults setFloat:[strike_price.text floatValue] forKey:@"strike_price"];
	[defaults setFloat:[current_price.text floatValue] forKey:@"current_price"];

	[defaults setInteger:period.selectedSegmentIndex forKey:@"periodselected"];
	[defaults setBool:firstyearcliff.isOn forKey:@"firstyearcliff"];
	
	[self.delegate flipsideViewControllerDidFinish:self];	
}


-(IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

-(IBAction)backgroundTouched:(id)sender {
	// clicking on the background will release the keyboard from the view
	[ticker resignFirstResponder];
	[shares_held resignFirstResponder];
	[shares_sold resignFirstResponder];
	[end_date resignFirstResponder];
	[grant_date resignFirstResponder];
	[strike_price resignFirstResponder];
	[current_price resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (IBAction)showVestingStartDatePicker:(id)sender {
	
	NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:[NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"Select Vesting Start Date", @"")]
								  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Ok", nil];
	[actionSheet showInView:self.view];
	UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];
	[datePicker setTag: kDatePickerTag];
	datePicker.datePickerMode = UIDatePickerModeDate;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *gDate = [defaults objectForKey:@"grant_date"];


	if (gDate)
		[datePicker setDate:gDate];
	
	[actionSheet addSubview:datePicker];


	
}

- (IBAction)showVestingEndDatePicker:(id)sender {
	
	NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:[NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"Select Vesting End Date", @"")]
								  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Ok", nil];
	[actionSheet showInView:self.view];
	UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *veDate = [defaults objectForKey:@"end_date"];
					  
	if (veDate)
		[datePicker setDate:veDate];
	
	[datePicker setTag: kDatePickerTag];
	datePicker.datePickerMode = UIDatePickerModeDate;

	[actionSheet addSubview:datePicker];
		
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	//set Date formatter
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
        
	//Gets our picker
	UIDatePicker *ourDatePicker = (UIDatePicker *) [actionSheet viewWithTag:kDatePickerTag];
        
	NSDate *selectedDate = [ourDatePicker date];	


	if ([actionSheet.title hasSuffix:@"Vesting Start Date"]) {
		[defaults setObject:selectedDate forKey:@"grant_date"];
		[grant_date setTitle:[dateFormatter stringFromDate:selectedDate] forState:UIControlStateNormal];
	}

	if ([actionSheet.title hasSuffix:@"Vesting End Date"]) {
		[defaults setObject:selectedDate forKey:@"end_date"];
		[end_date setTitle:[dateFormatter stringFromDate:selectedDate] forState:UIControlStateNormal];
		
	}
	
	doneBtn.enabled = [self validateForm];
	
	[dateFormatter release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	// fancy decimal inputter
	if (textField == strike_price || textField == current_price)
    {
		double currentValue = [textField.text doubleValue];
		double cents = round(currentValue * 100.0f);
	
		if ([string length]) {
			for (size_t i = 0; i < [string length]; i++) {
				unichar c = [string characterAtIndex:i];
				if (isnumber(c)) {
					cents *= 10;
					cents += c - '0'; 
				}            
			}
		} else {
			// back Space
			cents = floor(cents / 10);
		}
	
		textField.text = [NSString stringWithFormat:@"%.2f", cents / 100.0f];
		return NO;
	}	
	
	doneBtn.enabled = [self validateForm];

    return TRUE;
}

- (void)dealloc {
	[super dealloc];
}


@end
