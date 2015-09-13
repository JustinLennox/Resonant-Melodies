//
//  Hero.h
//  ResonantMelodies
//
//  Created by Justin Lennox on 9/13/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Hero : SKSpriteNode

@property (strong, nonatomic) NSString *mode;

//Character animation arrays
@property (strong, nonatomic) NSArray *musicModeAdagioWalkingFrames;
@property (strong, nonatomic) NSArray *musicModeAdagioIdleFrames;
@property (strong, nonatomic) NSArray *fireModeAdagioIdleFrames;
@property (strong, nonatomic) NSArray *changeModeFireFrames;

//Character Animation Methods
-(void)changeModeAnimation;
-(void)fireballAnimation:(SKSpriteNode *)fireSprite;
-(void)whiplashAnimation:(SKSpriteNode *)whiplashSprite;
-(void)watergunAnimation:(SKSpriteNode *)watergunSprite;
-(void)finishChangeModes;
-(void)walkAdagio;
    
@end
