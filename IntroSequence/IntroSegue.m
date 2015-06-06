//
//  IntroSegue.m
//  IntroSequence
//
//  Created by Sarah Allen on 6/6/15.
//  Copyright (c) 2015 Mightyverse. All rights reserved.
//

#import "IntroSegue.h"

@implementation IntroSegue

- (void)perform
{
    [[self sourceViewController] presentModalViewController:[self destinationViewController] animated:NO];
}

@end

