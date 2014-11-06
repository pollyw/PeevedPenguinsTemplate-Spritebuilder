//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Polly Wu on 11/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
}

//is called when ccb file has completed loading
- (void)didLoadFromCCB {
    //tell this scene to accept touches
    self.userInteractionEnabled = true;
    
    //load level 1
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    //visualize physics bodies & joints
    _physicsNode.debugDraw = true;
    
    //nothing shall collide with our invisible nodes
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
}

//called on every touch in this scene
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //[self launchPenguin];
    
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    //start catapult dragging when a touch inside of the catapultArm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        
        //move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        //set up a spring joint between the mouseJointNode and the catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(0,0) restLength:0.f stiffness:3000.f damping:150.f];
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    //whenever touches move,update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

-(void)releaseCatapult {
    if (_mouseJoint != nil) {
        //releases the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
    }
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    //when touches end, meaning the user releases their finer, release the catapult
    [self releaseCatapult];
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    //when touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult
    [self releaseCatapult];
}

- (void)launchPenguin {
    //loads the Penguid.ccb we have set up in spritebuilder
    CCNode *penguin = [CCBReader load:@"Penguin"];
    
    //position the penguin at the bowl of the catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16,50));
    
    //add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:penguin];
    
    //manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    //ensure followed object is in visible are when starting
    self.position = ccp(0,0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    
    //scroll the whole scene
    //[self runAction:follow];
    
    //scroll only the contentNode
    [_contentNode runAction:follow];
}

-(void)retry {
    //relaod this level
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}

@end
