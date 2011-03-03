//
//  worth_utilityAppDelegate.h
//  worth-utility
//
//  Created by John Adams on 2/28/11.
//  Copyright 2011 John Adams. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface worth_utilityAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end

