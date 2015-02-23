//
//  WorldOverview.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/26/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "WorldOverview.h"

@implementation WorldOverview

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        SKLabelNode *level1Label;
        level1Label = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        level1Label.name = @"level1Label";
        level1Label.text = @"Level 1";
        level1Label.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/2);
        level1Label.fontColor = [SKColor whiteColor];
        [self addChild:level1Label];
        
        SKLabelNode *level2Label;
        level2Label = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        level2Label.name = @"level2Label";
        level2Label.text = @"Level 2";
        level2Label.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        level2Label.fontColor = [SKColor whiteColor];
        [self addChild:level2Label];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    // if next button touched, start transition to next scene
    if ([node.name isEqualToString:@"level1Label"]) {
        NSLog(@"nextButton pressed");
        /*SKScene *sampleScene = [[Level1 alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition fadeWithDuration:0.5f];
        [self.view presentScene:sampleScene transition:transition];*/
        
        SKScene *introScene = [[Intro alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition fadeWithDuration:1.0f];
        [self.view presentScene:introScene transition:transition];
        
        
    }else if([node.name isEqualToString:@"level2Label"]) {
        NSLog(@"nextButton pressed");
        SKScene *sampleScene = [[GameScene alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition fadeWithDuration:0.5f];
        [self.view presentScene:sampleScene transition:transition];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

@end
