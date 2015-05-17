//
//  Enemy.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/26/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy

/*-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    self.healthLabel.text = [NSString stringWithFormat:@"%.2d", self.health];
    self.healthLabel.position = CGPointMake(self.position.x, self.position.y + self.frame.size.height + 10);
    self.healthLabel.color = [SKColor redColor];
    self.healthLabel.fontColor = [SKColor redColor];
    self.healthLabel.fontSize = 20;
    [self addChild:self.healthLabel];
}*/

-(void)moveEnemy: (int) moveInt withBPM: (float)BPM{
    if(self.canMove){
        if([self.type isEqualToString:@"scooter"])
        {
            NSLog(@"Oh he can move");
            SKAction *moveScooter = [[SKAction alloc] init];
            switch (moveInt) {
                case 1:
                {
                    moveScooter = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:(60.0f/BPM)/2.0f];
                    self.xScale = 1.0f;
                    break;
                }
                case 2:
                {
                    moveScooter = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:(60.0f/BPM)/2.0f];
                    self.xScale = 1.0f;
                    break;
                }
                case 3:
                {
                    moveScooter = [SKAction moveByX:([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:(60.0f/BPM)/2.0f];
                    self.xScale = -1.0f;
                    break;
                }
                case 4:
                {
                    moveScooter = [SKAction moveByX:([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:(60.0f/BPM)/2.0f];
                    self.xScale = -1.0f;
                    break;
                }
                default:
                {
                    break;
                    
                }
            }
            [self runAction:moveScooter];
            
        }
    }
}

@end
