//
//  Enemy.h
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/26/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Enemy : SKSpriteNode

@property (nonatomic) float health;
@property (nonatomic) float healthMax;
@property (strong, nonatomic) NSArray *resonantArray;
@property (strong, nonatomic) SKLabelNode *healthLabel;
@property (strong, nonatomic) NSString *type;
@property (nonatomic) int arrayPosition;
@property (nonatomic) BOOL canMove;
@property (nonatomic) BOOL canShoot;
@property (nonatomic) int sleepChance;
@property (nonatomic) float attackDamage;
@end
