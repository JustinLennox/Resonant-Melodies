//
//  CustomProgressBar.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 2/22/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "CustomProgressBar.h"

@implementation CustomProgressBar

- (id)init{
    if (self = [super init]) {

        self.maskNode = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(300,20)];
    }

    return self;
}

-(void)setBarType:(NSString *) type{
    
    if([type isEqualToString:@"health"])
    {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar_weapon_fill.png"];
        [self addChild:sprite];
    }
    
}

- (void) setProgress:(CGFloat) progress {
    self.maskNode.xScale = progress;
}

@end
