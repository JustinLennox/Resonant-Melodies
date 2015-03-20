//
//  Interactable.h
//  ResonantMelodies
//
//  Created by Justin Lennox on 2/10/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Interactable : SKSpriteNode

@property (strong, nonatomic) NSString *keyNode;
@property (strong, nonatomic) NSString *displayText;
@property (strong, nonatomic) NSArray *textArray;
@property (strong, nonatomic) NSString *type;

@end
