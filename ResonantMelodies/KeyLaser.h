//
//  KeyLaser.h
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/27/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface KeyLaser : SKSpriteNode

@property (nonatomic) float damage;
@property (strong, nonatomic) NSString *note;

-(void)setNote:(NSString *)note;
@end
