//
//  MainViewController.m
//  worth-utility
//
//  Created by John Adams on 2/28/11.
//  Copyright 2011 John Adams. All rights reserved.
//

//  Adapted from Worth.pl by Jamie Zawinski

//
// limitations:                                                                                                             
// only handles stock from one company;                                                                                    
// assumes all shares vest at the same rate;                                                                               
// assumes vesting rate is linear;                                                                                         
//

#import "MainViewController.h"

#define PERIOD_DAILY 0
#define PERIOD_MONTHLY 1

@implementation MainViewController

@synthesize ticker;
@synthesize curval;
@synthesize valueline;
@synthesize valueline_togo;
@synthesize exercisecost;
@synthesize progresspcnt;
@synthesize progressline;

- (IBAction)showInfo:(id)sender {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
		[self calculateStock];
		[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL setupDone	= [defaults boolForKey:@"setupDone"];
	
	// fire up the view if we haven't conf'd yet. unfortunately the user gets a quick view of the 
	if (setupDone == FALSE) {
		FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
		controller.delegate = self;
		controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:controller animated:NO]; 
		[controller release];
	}
}

- (void)calculateStock { 
	// load defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
	NSString *tickerValue		= [defaults stringForKey:@"ticker"];
	float strikePriceValue		= [defaults floatForKey:@"strike_price"];
	float curPriceValue			= [defaults floatForKey:@"current_price"];
	NSInteger sharesheldValue	= [defaults integerForKey:@"shares_held"];
	NSInteger sharessoldValue	= [defaults integerForKey:@"shares_sold"];
	NSDate *gDate				= [defaults objectForKey:@"grant_date"];
	NSDate *veDate				= [defaults objectForKey:@"end_date"];
	BOOL firstyearValue			= [defaults boolForKey:@"firstyearcliff"];
	BOOL livequoteValue			= [defaults boolForKey:@"livequote"];
	NSInteger periodValue		= [defaults integerForKey:@"periodselected"];
	
	float vestedSharesValue = 0;
	
	NSDate *nowDate = [NSDate date];
	
	NSTimeInterval edinterval = [nowDate timeIntervalSinceDate: gDate];
	NSTimeInterval vcinterval = [veDate timeIntervalSinceDate: gDate];

	int elapsed_days = edinterval / 86400;
	int vesting_cycle = vcinterval / 86400;
	
	// if monthly, restrict to nearest 30 days. 
	if (periodValue == PERIOD_MONTHLY) { 
		elapsed_days = elapsed_days - (elapsed_days % 30); 
	}
	
	// one year cliff, then vesting every 30 days. 
	if ((elapsed_days > 365) || (firstyearValue == FALSE)) {
		vestedSharesValue = (int)((float)sharesheldValue * ((float)elapsed_days / (float)vesting_cycle));
	} 
	
	// setup currency formatters
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setAllowsFloats:YES];	
	[currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];	
	
	// Percent Style
	NSNumberFormatter *percentStyle = [[NSNumberFormatter alloc] init];
	[percentStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[percentStyle setNumberStyle:NSNumberFormatterPercentStyle];
	
	//Decimal Style
	NSNumberFormatter *decimalStyle = [[NSNumberFormatter alloc] init];
	[decimalStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[decimalStyle setNumberStyle:NSNumberFormatterDecimalStyle];
	[decimalStyle setRoundingMode:NSNumberFormatterRoundFloor];
	[decimalStyle setRoundingIncrement:[NSNumber numberWithInt:1]];
	
	
	// populate view with current data
	// do we need to fetch the stock price? 
	if (livequoteValue) { 
		NSString *yahooFinance = [NSString stringWithFormat:@"http://download.finance.yahoo.com/d/quotes.csv?s=%@&f=sl1d1t1c1ohgv&e=.csv", tickerValue];
		NSURLRequest *theRequest = [ NSURLRequest requestWithURL:[NSURL URLWithString:yahooFinance]
												   cachePolicy:NSURLRequestUseProtocolCachePolicy
											   timeoutInterval:5.0];
		
		NSError        *error = nil;
		NSURLResponse  *response = nil;
		NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		NSLog(@"\n\nCONNECTION:   %@", theConnection);
		
		NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse: &response error:&error]; 
		if (!error) { 
			NSString *tickerString = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];   
			NSLog(@"\n\nQUOTE:   %@", tickerString);
		
			// yahoo quotes look like this
			// "MSFT",25.9525,"3/4/2011","4:00pm",-0.2475,26.22,26.24,25.80,70415600
			NSArray *chunks = [tickerString componentsSeparatedByString: @","];
			if ([[chunks objectAtIndex:2] isEqualToString:@"\"N/A\""]) { 
				valueline.text = @"Error: Symbol does not exist.";
				valueline_togo.text = @"";				
			} else { 
				NSLog(@"Price %@", [chunks objectAtIndex:1]);
				curPriceValue = [[chunks objectAtIndex:1] floatValue];	
				valueline.text = [NSString stringWithFormat:@"@ %.3f per share, market, as of %@ at %@", 
									curPriceValue,
									[[chunks objectAtIndex:2] stringByReplacingOccurrencesOfString:@"\"" withString:@""],
									[[chunks objectAtIndex:3] stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
				valueline_togo.text = [NSString stringWithFormat:@"Leave now and you walk away from %@", 
									   [currencyFormatter stringFromNumber:[NSNumber numberWithFloat:((sharesheldValue - sharessoldValue - vestedSharesValue) * curPriceValue)  ]]];

			}
		} else {
			valueline.text = @"Unable to fetch current market price from Internet.";
			valueline_togo.text = @"";

		}
	} else {
		valueline.text = [NSString stringWithFormat:@"@ %.3f per share, manually entered", curPriceValue];
		valueline_togo.text = [NSString stringWithFormat:@"Leave now and you walk away from %@", 
							   [currencyFormatter stringFromNumber:[NSNumber numberWithFloat:((sharesheldValue - sharessoldValue - vestedSharesValue) * curPriceValue)  ]]];
	}
	
	ticker.text = tickerValue;
	curval.text = [currencyFormatter stringFromNumber:[NSNumber numberWithFloat:(float)(curPriceValue * (vestedSharesValue - sharessoldValue))]];

	exercisecost.text = [currencyFormatter stringFromNumber:[NSNumber numberWithFloat:(float)(strikePriceValue * (vestedSharesValue - sharessoldValue))]];
	progresspcnt.text = [percentStyle stringFromNumber:[NSNumber numberWithFloat:(float)(vestedSharesValue / sharesheldValue)]];
	progressline.text = [NSString stringWithFormat:@"%@ of %@", 
						 [decimalStyle stringFromNumber:[NSNumber numberWithFloat:vestedSharesValue]], 
						 [decimalStyle stringFromNumber:[NSNumber numberWithInt:sharesheldValue]]];
	
	
	// done with these...
	[currencyFormatter dealloc];
	[percentStyle dealloc];
	[decimalStyle dealloc];
	
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
	[self calculateStock];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
	[ticker dealloc];
	[curval dealloc];
	[valueline dealloc];
	[valueline_togo dealloc];
	[exercisecost dealloc];
	[progressline dealloc];
	[progresspcnt dealloc];
	
    [super dealloc];
}


@end
