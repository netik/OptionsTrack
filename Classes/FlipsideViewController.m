//
//  FlipsideViewController.m
//  worth-utility
//
//  Created by John Adams on 2/28/11.
//  Copyright 2011 Twitter. All rights reserved.
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
	// returns TRUE if all fields validate. 
	
	if (grant_date.text.length < 8) 
		return FALSE;
	
	if (end_date.text.length < 8)  
		return FALSE;
	
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
	NSString *grantDate			= [defaults stringForKey:@"grant_date"];
	NSString *endDate			= [defaults stringForKey:@"end_date"];
	BOOL firstyearValue			= [defaults boolForKey:@"firstyearcliff"];
	NSInteger periodValue		= [defaults integerForKey:@"periodselected"];
	
	
	// format strings and populate
	ticker.text = tickerValue;
	strike_price.text = [NSString stringWithFormat:@"%.2f", strikePriceValue];
	current_price.text = [NSString stringWithFormat:@"%.2f", curPriceValue];
	shares_held.text = [NSString stringWithFormat:@"%d", sharesheldValue];
	shares_sold.text = [NSString stringWithFormat:@"%d", sharessoldValue];
	grant_date.text = grantDate;
	end_date.text = endDate;

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

	[defaults setObject:grant_date.text forKey:@"grant_date"];
	[defaults setObject:end_date.text forKey:@"end_date"];

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

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];

	NSDate *gDate = [dateFormatter dateFromString:grant_date.text];		

	if (gDate)
		[datePicker setDate:gDate];
	
	[actionSheet addSubview:datePicker];

	[dateFormatter release];
	
}

- (IBAction)showVestingEndDatePicker:(id)sender {
	
	NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:[NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"Select Vesting End Date", @"")]
								  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Ok", nil];
	[actionSheet showInView:self.view];
	UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	NSDate *veDate = [dateFormatter dateFromString:end_date.text];		
	
	if (veDate)
		[datePicker setDate:veDate];
	
	[datePicker setTag: kDatePickerTag];
	datePicker.datePickerMode = UIDatePickerModeDate;

	[actionSheet addSubview:datePicker];
	[dateFormatter release];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	//set Date formatter
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MM/dd/yyyy"];
        
	//Gets our picker
	UIDatePicker *ourDatePicker = (UIDatePicker *) [actionSheet viewWithTag:kDatePickerTag];
        
	NSDate *selectedDate = [ourDatePicker date];	

	if ([actionSheet.title hasSuffix:@"Vesting End Date"]) {
		end_date.text = [formatter stringFromDate:selectedDate];
	}

	if ([actionSheet.title hasSuffix:@"Vesting Start Date"]) {
		grant_date.text = [formatter stringFromDate:selectedDate];
	}
	
	doneBtn.enabled = [self validateForm];
	
	[formatter release];
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
