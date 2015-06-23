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
        self.speechBubble = [[UILabel alloc] init];
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
            
            if([interactable.type isEqualToString:@"sign"] && ![self childNodeWithName:@"signLabel"] && ![self childNodeWithName:@"signPost"]){
                SKLabelNode *signLabel = [[SKLabelNode alloc] init];
                if(interactable.displayText){
                    signLabel.text = interactable.displayText;
                }
                signLabel.fontName = @"MorrisRoman-Black";
                signLabel.fontColor = [UIColor whiteColor];
                signLabel.alpha = 1.0f;
                signLabel.position = CGPointMake(screenSize.width/2 - self.position.x, screenSize.height/2 - self.position.y);
                signLabel.zPosition = 21.0f;
                signLabel.name = @"signLabel";
                [self addChild:signLabel];
                SKSpriteNode *signPost = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"brownPost.png"] size:CGSizeMake(screenSize.width/1.2, screenSize.height/2)];
                signPost.alpha = 1.0f;
                signPost.zPosition = 20.0f;
                signPost.position = CGPointMake(screenSize.width/2 - self.position.x, screenSize.height/2 - self.position.y);
                signPost.name = @"signPost";
                [self addChild:signPost];
            }else if([interactable.type isEqualToString:@"cycleNPC"] && ![self childNodeWithName:@"signLabel"] && ![self.parent.scene childNodeWithName:@"textBox"]){
                
                SKSpriteNode *signPost = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"textBox.png"] size:CGSizeMake(screenSize.width/2, screenSize.height/2 - interactable.size.height)];
                signPost.alpha = 1.0f;
                signPost.position = CGPointMake(CGRectGetMidX(self.parent.scene.frame), CGRectGetMidY(self.parent.scene.frame));
                signPost.zPosition = 2.0f;
                signPost.name = @"textBox";
                [self.parent.scene addChild:signPost];
                
                if(interactable.textArray){
                    self.speechBubble.text = [interactable.textArray objectAtIndex:interactable.cycleInt];
                    if(interactable.cycleInt < interactable.textArray.count - 1){
                        interactable.cycleInt++;
                    }else{
                        interactable.cycleInt = 0;
                    }
                }
                [self.speechBubble setFont:[UIFont fontWithName:@"MorrisRoman-Black" size:20.0f]];
                //self.speechBubble.frame = CGRectMake(CGRectGetMidX(signPost.frame) + signPost.frame.size.width/2, signPost.position.y - signPost.size.height/2, signPost.frame.size.width, signPost.frame.size.height);
                self.speechBubble.frame = CGRectMake(CGRectGetMidX(self.parent.scene.frame) - signPost.frame.size.width/2, CGRectGetMidY(self.parent.scene.view.frame)- self.speechBubble.frame.size.height/2.0f, signPost.frame.size.width - 40.0f, signPost.frame.size.height - 40.0f);
                self.speechBubble.frame = CGRectMake(CGRectGetMidX(self.parent.scene.frame) -  self.speechBubble.frame.size.width/2, CGRectGetMidY(self.parent.scene.view.frame)- self.speechBubble.frame.size.height/2.0f, self.speechBubble.frame.size.width, self.speechBubble.frame.size.height);

                self.speechBubble.textColor = [UIColor whiteColor];
                self.speechBubble.alpha = 1.0f;
                self.speechBubble.textAlignment = NSTextAlignmentCenter;
                self.speechBubble.numberOfLines = 0;
                self.speechBubble.lineBreakMode = NSLineBreakByWordWrapping;
                if(![self.speechBubble isDescendantOfView:self.parent.scene.view]){
                    [self.parent.scene.view addSubview:self.speechBubble];
                    [self.parent.scene.view bringSubviewToFront:self.speechBubble];
                }


            }else if([interactable.type isEqualToString:@"cycleNPC"] && [self.parent.scene childNodeWithName:@"textBox"]){
                
                if(interactable.textArray){
                    self.speechBubble.text = [interactable.textArray objectAtIndex:interactable.cycleInt];
                    if(interactable.cycleInt < interactable.textArray.count - 1){
                        interactable.cycleInt++;
                    }else{
                        interactable.cycleInt = 0;
                    }
                }
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
    [[self.parent.scene childNodeWithName:@"textBox"] removeFromParent];
    if(self.speechBubble.alpha == 1.0f){
        self.speechBubble.alpha = 0.0f;
    }
    
}

@end
