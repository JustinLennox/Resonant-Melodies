//
//  Intro.h
//  ResonantMelodies
//
//  Created by Justin Lennox on 2/6/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Level1.h"

@interface Intro : SKScene

@property (strong, nonatomic) SKSpriteNode *backgroundImage;
@property (strong, nonatomic) SKSpriteNode *ostinato;
@property (strong, nonatomic) SKSpriteNode *textBox;
@property (strong, nonatomic) SKSpriteNode *textString;
@property (strong, nonatomic) UILabel *textLabel;
@property (nonatomic) int sceneNumber;
@property (nonatomic) int letterInt;
@property (nonatomic) BOOL dialogueIsTyping;
@property (strong, nonatomic) SKEffectNode *effectNode;

@property (strong, nonatomic) NSMutableAttributedString *string1;
@property (strong, nonatomic) NSMutableAttributedString *string2;
@property (strong, nonatomic) NSMutableAttributedString *string3;
@property (strong, nonatomic) NSMutableAttributedString *string4;
@property (strong, nonatomic) NSMutableAttributedString *string5;
@property (strong, nonatomic) NSMutableAttributedString *string6;

@property (strong, nonatomic) NSArray *noteArray;

@property (strong, nonatomic) NSTimer *typeText;

@property (nonatomic) BOOL firstTime;


@end
