//
//  WaitingPenguin.m
//  PeevedPenguins
//
//  Created by Polly Wu on 11/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "WaitingPenguin.h"

@implementation WaitingPenguin

-(void)didLoadFromCCB {
    //generate a random number between 0.0 and 2.0
    float delay = (arc4random() % 2000) / 1000.f;
    
    //call method to start animation after random delay
    [self performSelector:@selector(startBlinkAndJump) withObject:nil afterDelay:delay];
    
}



@end
