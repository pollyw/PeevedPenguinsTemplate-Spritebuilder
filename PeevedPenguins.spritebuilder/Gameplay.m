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
    CCNode *_currentPenguin;
    CCPhysicsJoint*_penguinCatapultJoint;
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
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,138) restLength:0.f stiffness:1000.f damping:100.f];
        
        //PENGUIN IN BOWL
        //create a penguin from the ccb-file
        _currentPenguin = [CCBReader load:@"Penguin"];
        
        //initially position it on the scoop. 34,138 is the position in the node space of the catapultArm
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34, 138)];
        
        //transform the world position to the node space to which the penguin will be added (_physicsNode)
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        
        //add it to the physics world
        [_physicsNode addChild:_currentPenguin];
        
        //we dont want the penguin to rotate in the scoop
        _currentPenguin.physicsBody.allowsRotation = false;
        
        //create a join to keep the penguin fixed to the scoop until the catapult is released
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
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
        
        //release the joint and let the penguin fly
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        
        //after snapping rotation is fine
        _currentPenguin.physicsBody.allowsRotation = true;
        
        //follow the flying penguin
        CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:follow];
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
