//
//  Interactable.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 2/10/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "Interactable.h"

@implementation Interactable

-(id)init{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
    }
    return self;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSLog(@"Screen Size: %@", NSStringFromCGSize(screenSize));
    
    for (UITouch *touch in touches) {

        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        
        UITouch *touch = [[event allTouches] anyObject];
        
        if ([[n class] isSubclassOfClass:[Interactable class]]) {
            Interactable *interactable = (Interactable *)n;
            
            if(![self childNodeWithName:@"signLabel"] && ![self childNodeWithName:@"signPost"] && [interactable.type isEqualToString:@"sign"]){
                SKLabelNode *signLabel = [[SKLabelNode alloc] init];
                if(interactable.displayText){
                    signLabel.text = interactable.displayText;
                }
                signLabel.fontName = @"MorrisRoman-Black";
                signLabel.fontColor = [UIColor whiteColor];
                signLabel.alpha = 1.0f;
                signLabel.position = CGPointMake(screenSize.width/2 - self.position.x, screenSize.height/2 - self.position.y);
                signLabel.zPosition = 2.0f;
                signLabel.name = @"signLabel";
                [self addChild:signLabel];
                SKSpriteNode *signPost = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"brownPost.png"] size:CGSizeMake(screenSize.width/1.2, screenSize.height/2)];
                signPost.alpha = 1.0f;
                signPost.zPosition = 2.0f;
                signPost.position = CGPointMake(screenSize.width/2 - self.position.x, screenSize.height/2 - self.position.y);
                signPost.name = @"signPost";
                [self addChild:signPost];
            }else{
                [self removeSign];
            }
        }else if([self childNodeWithName:@"signLabel"] || ([self childNodeWithName:@"signPost"])){
            [self removeSign];
        }

    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        
        Interactable *n = (Interactable *)[self nodeAtPoint:[touch locationInNode:self]];
    }
}

-(void)removeSign{
    [self childNodeWithName:@"signLabel"].alpha = 0.0f;
    [[self childNodeWithName:@"signLabel"] removeFromParent];
    [self childNodeWithName:@"signPost"].alpha = 0.0f;
    [[self childNodeWithName:@"signPost"] removeFromParent];
    
}

@end
