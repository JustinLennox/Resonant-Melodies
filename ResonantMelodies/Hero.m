//
//  Hero.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 9/13/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

#import "Hero.h"

@implementation Hero

- (instancetype) init {
        if (self == [super init]) {
            NSLog(@"PLAYERINIT");
            [self setTexture:[SKTexture textureWithImageNamed:@"dalf1.png"]];
            [self setSize:CGSizeMake(100, 100)];
            self.name = @"player";
            [self setUpAnimations];
        }
    return self;
}

#pragma mark- Hero Animations
-(void)setUpAnimations{
    //Setup the array to hold the walking frames
    NSMutableArray *walkFrames = [NSMutableArray array];
    NSMutableArray *idleFrames = [NSMutableArray arrayWithObjects:[SKTexture textureWithImageNamed:@"musicModeAdagioIdle1"], [SKTexture textureWithImageNamed:@"musicModeAdagioIdle2"], [SKTexture textureWithImageNamed:@"musicModeAdagioIdle1"], nil];
    NSMutableArray *fireIdleFrames = [NSMutableArray arrayWithObjects:[SKTexture textureWithImageNamed:@"fireModeAdagioIdle1"], [SKTexture textureWithImageNamed:@"fireModeAdagioIdle2"], [SKTexture textureWithImageNamed:@"fireModeAdagioIdle1"], nil];
    
    //Load the TextureAtlas for the bear
    SKTextureAtlas *musicModeAtlas = [SKTextureAtlas atlasNamed:@"musicModeAdagio"];
    
    //Load the animation frames from the TextureAtlas
    int numImages = musicModeAtlas.textureNames.count;
    NSLog(@"num images:%d", numImages);
    for (int i=1; i <= numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"dalfWalk%d.png", i];
        NSLog(@"Texture name:%@", textureName);
        SKTexture *temp = [musicModeAtlas textureNamed:textureName];
        [walkFrames addObject:temp];
        NSLog(@"Yo");
    }
    self.musicModeAdagioWalkingFrames = walkFrames;
    self.musicModeAdagioIdleFrames =idleFrames;
    self.fireModeAdagioIdleFrames = fireIdleFrames;
    self.changeModeFireFrames = @[[SKTexture textureWithImageNamed:@"smoke_puff_0001.png"],
                              [SKTexture textureWithImageNamed:@"smoke_puff_0002.png"],
                              [SKTexture textureWithImageNamed:@"smoke_puff_0003.png"],
                              [SKTexture textureWithImageNamed:@"smoke_puff_0004.png"],
                              [SKTexture textureWithImageNamed:@"smoke_puff_0005.png"],
                              [SKTexture textureWithImageNamed:@"smoke_puff_0006.png"],
                              [SKTexture textureWithImageNamed:@"smoke_puff_0007.png"],
                              [SKTexture textureWithImageNamed:@"smoke_puff_0008.png"],
                              [SKTexture textureWithImageNamed:@"smoke_puff_0009.png"],
                              [SKTexture textureWithImageNamed:@"smoke_puff_0010.png"],
                              ];

}

-(void)changeModeAnimation{
    SKSpriteNode *tempPlayer = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:self.size];
    tempPlayer.position = CGPointMake(0, 0);
    tempPlayer.zPosition = self.zPosition + 0.1;
    [self addChild:tempPlayer];
    
    [self removeActionForKey:@"changeModesAnimation"];
    
    if([self.mode isEqualToString:@"Fire"]){
        SKAction *fireAnimation =  [SKAction animateWithTextures:self.changeModeFireFrames
                                                    timePerFrame:0.05f
                                                          resize:NO
                                                         restore:YES];
        SKAction *finishChangeModes = [SKAction performSelector:@selector(finishChangeModes) onTarget:self];
        SKAction *animationPlusFinish = [SKAction group:@[fireAnimation, finishChangeModes]];
        
        
        [tempPlayer runAction:animationPlusFinish withKey:@"changeModesAnimation"];
        
    }else if([self.mode isEqualToString:@"Wind"]){
        self.texture = [SKTexture textureWithImageNamed:@"windModeAdagioIdle1.png"];
        
        SKAction *fireAnimation =  [SKAction animateWithTextures:self.changeModeFireFrames
                                                    timePerFrame:0.05f
                                                          resize:NO
                                                         restore:YES];
        SKAction *finishChangeModes = [SKAction performSelector:@selector(finishChangeModes) onTarget:self];
        SKAction *animationPlusFinish = [SKAction group:@[fireAnimation, finishChangeModes]];
        
        
        [tempPlayer runAction:animationPlusFinish withKey:@"changeModesAnimation"];
        
        
        
    }else if([self.mode isEqualToString:@"Water"]){
        self.texture = [SKTexture textureWithImageNamed:@"waterModeAdagioIdle1.png"];
        
        SKAction *fireAnimation =  [SKAction animateWithTextures:self.changeModeFireFrames
                                                    timePerFrame:0.05f
                                                          resize:NO
                                                         restore:YES];
        SKAction *finishChangeModes = [SKAction performSelector:@selector(finishChangeModes) onTarget:self];
        SKAction *animationPlusFinish = [SKAction group:@[fireAnimation, finishChangeModes]];
        
        
        [tempPlayer runAction:animationPlusFinish withKey:@"changeModesAnimation"];
        
        
    }else if([self.mode isEqualToString:@"Earth"]){
        self.texture = [SKTexture textureWithImageNamed:@"earthModeAdagioIdle1.png"];
        
        SKAction *fireAnimation =  [SKAction animateWithTextures:self.changeModeFireFrames
                                                    timePerFrame:0.05f
                                                          resize:NO
                                                         restore:YES];
        SKAction *finishChangeModes = [SKAction performSelector:@selector(finishChangeModes) onTarget:self];
        SKAction *animationPlusFinish = [SKAction group:@[fireAnimation, finishChangeModes]];
        
        
        [tempPlayer runAction:animationPlusFinish withKey:@"changeModesAnimation"];
        
        
        
    }else if([self.mode isEqualToString:@"Music"]){
        self.texture = [SKTexture textureWithImageNamed:@"musicModeAdagioIdle1.png"];
        
        SKAction *fireAnimation =  [SKAction animateWithTextures:self.changeModeFireFrames
                                                    timePerFrame:0.05f
                                                          resize:NO
                                                         restore:YES];
        SKAction *finishChangeModes = [SKAction performSelector:@selector(finishChangeModes) onTarget:self];
        SKAction *animationPlusFinish = [SKAction group:@[fireAnimation, finishChangeModes]];
        
        
        [tempPlayer runAction:animationPlusFinish withKey:@"changeModesAnimation"];
    }
    
}

-(void)fireballAnimation:(SKSpriteNode *)fireSprite{
    
    NSMutableArray *fireballFrames = [NSMutableArray arrayWithObjects:
                                      [SKTexture textureWithImageNamed:@"fireball_0001"],
                                      [SKTexture textureWithImageNamed:@"fireball_0002"],
                                      [SKTexture textureWithImageNamed:@"fireball_0003"],
                                      [SKTexture textureWithImageNamed:@"fireball_0004"],
                                      [SKTexture textureWithImageNamed:@"fireball_0005"],
                                      [SKTexture textureWithImageNamed:@"fireball_0006"],
                                      nil];
    
    SKAction *fireAnimation =  [SKAction animateWithTextures:fireballFrames
                                                timePerFrame:0.05f
                                                      resize:NO
                                                     restore:YES];
    [fireSprite runAction:[SKAction repeatActionForever:fireAnimation]];
}

-(void)whiplashAnimation:(SKSpriteNode *)whiplashSprite{
    
    NSMutableArray *whiplashFrames = [NSMutableArray arrayWithObjects:
                                      [SKTexture textureWithImageNamed:@"cut_b_0001"],
                                      [SKTexture textureWithImageNamed:@"cut_b_0002"],
                                      [SKTexture textureWithImageNamed:@"cut_b_0003"],
                                      [SKTexture textureWithImageNamed:@"cut_b_0004"],
                                      [SKTexture textureWithImageNamed:@"cut_b_0005"],
                                      nil];
    
    SKAction *whiplashAnimation =  [SKAction animateWithTextures:whiplashFrames
                                                    timePerFrame:0.05f
                                                          resize:NO
                                                         restore:YES];
    [whiplashSprite runAction:whiplashAnimation];
    
    
}

-(void)watergunAnimation:(SKSpriteNode *)watergunSprite{
    
    NSMutableArray *watergunFrames = [NSMutableArray arrayWithObjects:
                                      [SKTexture textureWithImageNamed:@"watergun_0001"],
                                      [SKTexture textureWithImageNamed:@"watergun_0002"],
                                      [SKTexture textureWithImageNamed:@"watergun_0003"],
                                      [SKTexture textureWithImageNamed:@"watergun_0004"],
                                      [SKTexture textureWithImageNamed:@"watergun_0005"],
                                      [SKTexture textureWithImageNamed:@"watergun_0006"],
                                      [SKTexture textureWithImageNamed:@"watergun_0007"],
                                      [SKTexture textureWithImageNamed:@"watergun_0008"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0010"],
                                      
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0008"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0010"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0008"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0010"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0008"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0010"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0008"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0010"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0008"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0010"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0008"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0010"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0008"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0010"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      [SKTexture textureWithImageNamed:@"watergun_0008"],
                                      [SKTexture textureWithImageNamed:@"watergun_0009"],
                                      nil];
    
    //    NSMutableArray *watergunFrames2 = [NSMutableArray arrayWithObjects:
    //                                       [SKTexture textureWithImageNamed:@"watergun_0010"],
    //                                       [SKTexture textureWithImageNamed:@"watergun_0009"],
    //                                       [SKTexture textureWithImageNamed:@"watergun_0008"],
    //                                       [SKTexture textureWithImageNamed:@"watergun_0009"],
    //                                       nil];
    
    SKAction *watergunAnimation1 =  [SKAction animateWithTextures:watergunFrames
                                                     timePerFrame:0.05f
                                                           resize:NO
                                                          restore:YES];
    
    
    [watergunSprite runAction:[SKAction repeatActionForever:watergunAnimation1]];
    
    
}

-(void)finishChangeModes{
    if([self.mode isEqualToString:@"Fire"]){
        NSLog(@"Finish change modes");
        self.texture = [SKTexture textureWithImageNamed:@"fireModeAdagioIdle1.png"];
    }
    [self idleAdagio];
    
}

-(void)idleAdagio{
    
    [self removeActionForKey:@"adagioIdle"];
    
    if([self.mode isEqualToString:@"Music"]){
        
        SKAction *idleAnimation =  [SKAction animateWithTextures:self.musicModeAdagioIdleFrames
                                                    timePerFrame:0.1f
                                                          resize:NO
                                                         restore:YES];
        SKAction *waitThree = [SKAction waitForDuration:3.0f];
        
        SKAction *idleSequence = [SKAction repeatActionForever:[SKAction sequence:@[idleAnimation, waitThree]]];
        [self runAction:idleSequence withKey:@"adagioIdle"];
        
    }else if([self.mode isEqualToString:@"Fire"]){
        
        SKAction *idleAnimation =  [SKAction animateWithTextures:self.fireModeAdagioIdleFrames
                                                    timePerFrame:0.1f
                                                          resize:NO
                                                         restore:YES];
        SKAction *waitThree = [SKAction waitForDuration:3.0f];
        
        SKAction *idleSequence = [SKAction repeatActionForever:[SKAction sequence:@[idleAnimation, waitThree]]];
        [self runAction:idleSequence withKey:@"adagioIdle"];
        
    }
    
}

-(void)walkAdagio{
    //This is our general runAction method to make our bear walk.
    //By using a withKey if this gets called while already running it will remove the first action before
    //starting this again.
    if([self actionForKey:@"musicModeAdagioIdle"]){
        [self removeActionForKey:@"musicModeAdagioIdle"];
        
    }
    SKAction *walkAnimation =  [SKAction repeatActionForever:[SKAction animateWithTextures:self.musicModeAdagioWalkingFrames
                                                                              timePerFrame:0.1f
                                                                                    resize:NO
                                                                                   restore:YES]];
    
    [self runAction:walkAnimation withKey:@"musicModeAdagioWalk"];
    
}


@end
