//
//  Intro.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 2/6/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "Intro.h"
#import "Level1.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end


@implementation Intro

-(void)didMoveToView:(SKView *)view {
    self.dialogueIsTyping = YES;
    
    self.backgroundColor = [SKColor blackColor];

    self.backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"introBackground1.png"];
    self.backgroundImage.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.backgroundImage.position = CGPointMake(0, CGRectGetMinX(self.frame));
    self.backgroundImage.anchorPoint = CGPointZero;
    self.backgroundImage.name = @"backgroundImage";
    [self addChild:self.backgroundImage];
    
    self.ostinato = [SKSpriteNode spriteNodeWithImageNamed:@"Ostinato.png"];
    self.ostinato.size = CGSizeMake(150, 200);
    self.ostinato.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.ostinato.name = @"ostinato";
    self.ostinato.alpha = 0.0f;
    [self addChild:self.ostinato];
    
    self.backgroundImage = (SKSpriteNode *)[self childNodeWithName:@"backgroundImage"];
    self.backgroundImage.texture = nil;
    
    //Add Ostinato's Aura
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"OstinatoParticle" ofType:@"sks"];
    SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    myParticle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    myParticle.name = @"ostinatoParticle";
    myParticle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:myParticle];
    myParticle.alpha = 0.0f;
    
    //Create Text Box
    SKTexture *textBoxTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"flatBlueTextBox.png"]];
    self.textBox = [SKSpriteNode spriteNodeWithTexture:textBoxTexture size:CGSizeMake(self.frame.size.width, self.frame.size.height/3)];
    self.textBox.zPosition = 2.0f;
    self.textBox.position = CGPointMake(self.textBox.size.width/2, self.textBox.size.height/2);
    self.textBox.alpha = 0.9f;
    [self addChild:self.textBox];
    
    //Create Text Box label
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.textBox.frame.origin.x+15, CGRectGetMaxY(self.view.frame) - self.textBox.size.height +10, self.frame.size.width-20, self.textBox.size.height-40)];
    [self.textLabel setText:@""];
    self.textLabel.alpha = 1.0f;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.textLabel.font = [UIFont fontWithName:@"MorrisRoman-Black" size:30];
    }else{
        self.textLabel.font = [UIFont fontWithName:@"MorrisRoman-Black" size:25];
    }
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.numberOfLines = 0;
    //self.textLabel.backgroundColor = [UIColor colorWithRed:(194.00f/255.00f) green:(180.00f/255.00f) blue:(154.00f/255.00f) alpha:0.8f];
    [self.view addSubview:self.textLabel];
    
    UIColor *flatGreen =[UIColor colorWithRed:(46.00f/255.00f) green:(204.00f/255.00f) blue:(113.00f/255.00f) alpha:1.0f];
    UIColor *flatRed =[UIColor colorWithRed:(231.00f/255.00f) green:(76.00f/255.00f) blue:(60.00f/255.00f) alpha:1.0f];
    UIColor *flatBlue =[UIColor colorWithRed:(52.00f/255.00f) green:(152.00f/255.00f) blue:(219.00f/255.00f) alpha:1.0f];
    
    //Set Up Strings
    self.string1 = [[NSMutableAttributedString alloc] initWithString:@"It's time you heard the story of our land..."];
    [self.string1 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, self.string1.length)];
    [self.string1 addAttribute:NSForegroundColorAttributeName value:flatGreen range:NSMakeRange(37, 4)];

    self.string2 = [[NSMutableAttributedString alloc] initWithString:@"\"A long time ago, the evil Sorcerer Ostinato invaded our kingdom...\""];
    [self.string2 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, self.string2.length)];
    [self.string2 addAttribute:NSForegroundColorAttributeName value:flatRed range:NSMakeRange(26, 18)];

    self.string3 = [[NSMutableAttributedString alloc] initWithString:@"\"He harnessed the power of Resonant Melodies- songs that can shatter an enemy to pieces in a matter of seconds- to defeat and conquer our armies.\""];
    [self.string3 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, self.string3.length)];
    [self.string3 addAttribute:NSForegroundColorAttributeName value:flatBlue range:NSMakeRange(26, 18)];

    self.string4 = [[NSMutableAttributedString alloc] initWithString:@"\"After his victory, he sealed away his one weakness in a Glass Prism that could only be destroyed if its Resonant Melody was played.\""];
    [self.string4 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, self.string4.length)];
    [self.string4 addAttribute:NSForegroundColorAttributeName value:flatRed range:NSMakeRange(56, 12)];
    [self.string4 addAttribute:NSForegroundColorAttributeName value:flatBlue range:NSMakeRange(105, 15)];

    self.string5 = [[NSMutableAttributedString alloc] initWithString:@"\"He wrote the prism's melody on the Great Score and divided it amongst his kingoms for safekeeping.\""];
    [self.string5 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, self.string5.length)];
    [self.string5 addAttribute:NSForegroundColorAttributeName value:flatGreen range:NSMakeRange(36, 11)];

    self.string6 = [[NSMutableAttributedString alloc] initWithString:@"\"So long as the Glass Prism remains intact, we have no hope of ending Ostinato's reign.\""];
    [self.string6 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, self.string6.length)];
    [self.string6 addAttribute:NSForegroundColorAttributeName value:flatGreen range:NSMakeRange(16, 11)];
    [self.string6 addAttribute:NSForegroundColorAttributeName value:flatRed range:NSMakeRange(70, 11)];

    self.sceneNumber = 1;
    self.firstTime = YES;
    [self performSelector:@selector(loadNextScene) withObject:nil afterDelay:1.0f];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        
        if(self.dialogueIsTyping){
            
            if(self.sceneNumber != 1){
                SKEmitterNode *ostinatoParticle = (SKEmitterNode *)[self childNodeWithName:@"ostinatoParticle"];
                
                [self.backgroundImage removeActionForKey:@"fadeIn"];
                //[self.backgroundImage removeActionForKey:@"fadeOut"];
                //[self.backgroundImage removeAllActions];
                self.backgroundImage.alpha = 1.0f;
                
                [self.ostinato removeActionForKey:@"fadeIn"];
                [self.ostinato removeActionForKey:@"fadeOut"];
                [self.ostinato removeAllActions];
                self.ostinato.alpha = 1.0f;
                
                [ostinatoParticle removeActionForKey:@"fadeIn"];
                [ostinatoParticle removeActionForKey:@"fadeOut"];
                [ostinatoParticle removeAllActions];
                ostinatoParticle.alpha = 1.0f;
            }
            
            switch(self.sceneNumber)
            {

                case 1:
                    self.letterInt = self.string1.length;
                    break;
                case 2:
                    self.letterInt = self.string2.length;
                    self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground1.png"]];
                    break;
                case 3:
                    self.letterInt = self.string3.length;
                    self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground2.png"]];
                    break;
                case 4:
                    self.letterInt = self.string4.length;
                    self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground2.png"]];
                    break;
                case 5:
                    self.letterInt = self.string5.length;
                    self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground2.png"]];
                    break;
                case 6:
                    self.letterInt = self.string6.length;
                    self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground2.png"]];
                    break;
                default:
                    break;
            
            }

        }else{
            self.sceneNumber++;
            [self loadNextScene];
        }
        
       // if([n.name isEqualToString:@"int])
        

    
    }
}

-(void)typeText{
    switch(self.sceneNumber)
    {
        case 1:
            if(self.letterInt <= self.string1.length){
                self.textLabel.attributedText = [self.string1 attributedSubstringFromRange:NSMakeRange(0, self.letterInt)];
                self.letterInt++;
                break;
            }else{
                self.dialogueIsTyping = NO;
            }
            break;
        case 2:
            if(self.letterInt <= self.string2.length){
                self.textLabel.attributedText = [self.string2 attributedSubstringFromRange:NSMakeRange(0, self.letterInt)];
                self.letterInt++;
                break;
            }else{
                self.dialogueIsTyping = NO;
            }
            break;
        case 3:
            if(self.letterInt <= self.string3.length){
                self.textLabel.attributedText = [self.string3 attributedSubstringFromRange:NSMakeRange(0, self.letterInt)];
                self.letterInt++;
                break;
            }else{
                self.dialogueIsTyping = NO;
            }
            break;
        case 4:
            if(self.letterInt <= self.string4.length){
                self.textLabel.attributedText = [self.string4 attributedSubstringFromRange:NSMakeRange(0, self.letterInt)];
                self.letterInt++;
                break;
            }else{
                self.dialogueIsTyping = NO;
            }
            break;
        case 5:
            if(self.letterInt <= self.string5.length){
                self.textLabel.attributedText = [self.string5 attributedSubstringFromRange:NSMakeRange(0, self.letterInt)];
                self.letterInt++;
                break;
            }else{
                self.dialogueIsTyping = NO;
            }
            break;
        case 6:
            if(self.letterInt <= self.string6.length){
                self.textLabel.attributedText = [self.string6 attributedSubstringFromRange:NSMakeRange(0, self.letterInt)];
                self.letterInt++;
                break;
            }else{
                self.dialogueIsTyping = NO;
            }
            break;
        default:
            break;
    }
    
}

-(void)loadNextScene{
    self.dialogueIsTyping = YES;
    
    SKEmitterNode *ostinatoParticle = (SKEmitterNode *)[self childNodeWithName:@"ostinatoParticle"];
    ostinatoParticle.zPosition = 0.9f;
    self.ostinato.zPosition = 1.0f;
    
    switch (self.sceneNumber) {
        case 1:
        {
            self.backgroundImage = (SKSpriteNode *)[self childNodeWithName:@"backgroundImage"];
            self.backgroundImage.texture = nil;
            self.ostinato.alpha = 0.0f;
            break;
        }
        case 2:
        {
            self.backgroundImage = (SKSpriteNode *)[self childNodeWithName:@"backgroundImage"];
            self.backgroundImage.alpha = 0.0f;
            self.ostinato.alpha = 0.0f;
            self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground1.png"]];
            SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
            [ostinatoParticle runAction:fadeIn withKey:@"fadeIn"];
            [self.ostinato runAction:fadeIn withKey:@"fadeIn"];
            [self.backgroundImage runAction:fadeIn withKey:@"fadeIn"];
            
            break;
        }
        case 3:
        {
            self.backgroundImage = (SKSpriteNode *)[self childNodeWithName:@"backgroundImage"];
            SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5];
            [self.ostinato runAction:fadeOut];
            [ostinatoParticle runAction:fadeOut];
            [self.backgroundImage runAction:fadeOut completion:^{
                self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground2.png"]];
                SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
                [self.backgroundImage runAction:fadeIn withKey:@"fadeIn"];
                [ostinatoParticle runAction:fadeIn withKey:@"fadeIn"];
                [self.ostinato runAction:fadeIn withKey:@"fadeIn"];
                CGFloat ostinatoMaxX = CGRectGetMaxX(self.ostinato.frame);
                CGFloat ostinatoMinX = CGRectGetMinX(self.ostinato.frame);
                CGFloat ostinatoY = CGRectGetMaxY(self.ostinato.frame);
                SKSpriteNode *note = [SKSpriteNode spriteNodeWithImageNamed:@"note1.png"];
                note.position = CGPointMake(ostinatoMinX-30, ostinatoY-50);
                note.size = CGSizeMake(20, 25);
                SKSpriteNode *note2 = [SKSpriteNode spriteNodeWithImageNamed:@"note2.png"];
                note2.position = CGPointMake(ostinatoMinX-10, ostinatoY + 10);
                note2.size = CGSizeMake(15, 25);
                SKSpriteNode *note3 = [SKSpriteNode spriteNodeWithImageNamed:@"note3.png"];
                note3.position = CGPointMake(ostinatoMaxX+10, ostinatoY);
                note3.size = CGSizeMake(20, 25);
                
                self.noteArray = @[note, note2, note3];
                [self addChild:note];
                [self addChild:note2];
                [self addChild:note3];
                for(SKSpriteNode *note in self.noteArray){
                    note.alpha = 0.0f;
                    [note runAction:fadeIn];
                    note.zPosition = 1.0f;
                    SKAction *moveUp = [SKAction moveToY:note.frame.origin.y+4 duration:1.0f];
                    SKAction *moveDown = [SKAction moveToY:note.frame.origin.y-4 duration:1.0f];
                    SKAction *floatAction = [SKAction sequence:@[moveUp, moveDown]];
                    [note runAction:[SKAction repeatActionForever:floatAction]];
                }
            }];
             

            break;
        }
        case 4:
        {
            self.backgroundImage = (SKSpriteNode *)[self childNodeWithName:@"backgroundImage"];
            SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5];
            [self.ostinato runAction:fadeOut];
            for(SKSpriteNode *note in self.noteArray){
                [note runAction:fadeOut];
            }
            [ostinatoParticle runAction:fadeOut];
            [self.backgroundImage runAction:fadeOut completion:^{
                self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground2.png"]];
                SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
                [self.backgroundImage runAction:fadeIn withKey:@"fadeIn"];
                [ostinatoParticle runAction:fadeIn withKey:@"fadeIn"];
                [self.ostinato runAction:fadeIn withKey:@"fadeIn"];
            }];

            break;
        }
        case 5:
        {

            self.backgroundImage = (SKSpriteNode *)[self childNodeWithName:@"backgroundImage"];
            SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5];
            [self.ostinato runAction:fadeOut];
            [ostinatoParticle runAction:fadeOut];
            [self.backgroundImage runAction:fadeOut completion:^{
                self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground2.png"]];
                SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
                [self.backgroundImage runAction:fadeIn withKey:@"fadeIn"];
                [ostinatoParticle runAction:fadeIn withKey:@"fadeIn"];
                [self.ostinato runAction:fadeIn withKey:@"fadeIn"];
            }];

            break;
        }
        case 6:
        {
            self.backgroundImage = (SKSpriteNode *)[self childNodeWithName:@"backgroundImage"];
            SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5];
            [self.ostinato runAction:fadeOut];
            [ostinatoParticle runAction:fadeOut];
            [self.backgroundImage runAction:fadeOut completion:^{
                self.backgroundImage.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"introBackground2.png"]];
                SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
                [self.backgroundImage runAction:fadeIn withKey:@"fadeIn"];
                [ostinatoParticle runAction:fadeIn withKey:@"fadeIn"];
                [self.ostinato runAction:fadeIn withKey:@"fadeIn"];
            }];

            break;
        }
        case 7:
        {
            [self toLevel1];
            break;
        }
        default:
            break;
    }
    
    self.letterInt = 0;
    if(self.firstTime){
    self.typeText = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(typeText) userInfo:nil repeats:YES];
        self.firstTime = NO;
    }
}

-(void)toLevel1{
    [self removeAllChildren];
    [self removeAllActions];
    [UIView animateWithDuration:0.3f animations:^{
        self.textLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.textLabel removeFromSuperview];
    }];
    //NSString *scenePath = [[NSBundle mainBundle] pathForResource:@"SceneOne" ofType:@"sks"];
    //SKScene *scene = [NSKeyedUnarchiver unarchiveObjectWithFile:scenePath];
    //SKScene *level1 = scene;//[[Level1 alloc] initWithSize:self.size];
    Level1 *level1 = [Level1 unarchiveFromFile:@"SceneOne"];
    SKTransition *transition = [SKTransition fadeWithDuration:2.0f];
    level1.scaleMode = SKSceneScaleModeResizeFill;
    //level1.scaleMode = SKSceneScaleModeAspectFit;
    [self.view presentScene:level1 transition:transition];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}
            
@end
