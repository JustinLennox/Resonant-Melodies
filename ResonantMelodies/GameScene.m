//
//  GameScene.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/22/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene{
    SKNode *node;
    AVAudioPlayer *backgroundAudioPlayer;
}

#pragma mark- beginning init
-(void)didMoveToView:(SKView *)view {
    
#pragma mark- set up camera
    self.anchorPoint = CGPointMake (0,0);
    SKNode *myWorld = [SKNode node];
    [self addChild:myWorld];
    SKNode *camera = [SKNode node];
    camera.name = @"camera";
    [myWorld addChild:camera];
    
    self.view.multipleTouchEnabled = YES;

#pragma mark- set up background
    SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"Sakura Forest Game Background.png"];
    backgroundImage.name = @"background";
    backgroundImage.position = CGPointMake(self.size.width/2, self.size.height/2);
    backgroundImage.zPosition = -1.0f;
    [self addChild:backgroundImage];
    
#pragma mark- set up player
    self.player = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"dalf1.png"] size:CGSizeMake(70, 70)];
    self.player.position = CGPointMake((([[UIScreen mainScreen] bounds].size.width/12)), CGRectGetMidY(self.frame));
    self.player.name = @"player";
    self.currentHero = @"dalf";
    [self addChild:self.player];

    
#pragma mark- add keys
    [self addChild: [self lowANode]];
    [self addChild: [self lowBNode]];
    [self addChild: [self lowCNode]];
    [self addChild: [self lowDNode]];
    [self addChild: [self lowENode]];
    [self addChild: [self highFNode]];
    [self addChild: [self highGNode]];
    [self addChild: [self highANode]];
    [self addChild: [self highBNode]];
    [self addChild: [self highCNode]];
    [self addChild: [self highDNode]];
    [self addChild: [self highENode]];
    
#pragma mark- set up enemies
    [self setEnemyPositions];
    
#pragma mark- set difficulty and tempo
    
    self.difficulty = @"medium";
    
    if([self.difficulty isEqualToString:@"easy"]){
        self.BPM = 60;
    }else if([self.difficulty isEqualToString:@"medium"]){
        self.BPM = 90;
    }else if([self.difficulty isEqualToString:@"hard"]){
        self.BPM = 120;
    }
    
    //Set up background music
    NSError *err;
    NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"90 dwams.m4a" ofType:nil]];
    backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
    if (err) {
        NSLog(@"error in audio play %@",[err userInfo]);
        return;
    }
    [backgroundAudioPlayer prepareToPlay];
    
    // this will play the music infinitely
    backgroundAudioPlayer.numberOfLoops = -1;
    [backgroundAudioPlayer setVolume:1.0];
    
    //Start rhythm
    self.firstBeat = YES;
    NSTimer *beat = [NSTimer scheduledTimerWithTimeInterval:(60/self.BPM) target:self selector:@selector(beat) userInfo:nil repeats:YES];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        double touchTime = CACurrentMediaTime();
        double rhythmMultiplier = fabs(touchTime - self.beatTime);
        NSLog(@"%f", rhythmMultiplier);
        if(rhythmMultiplier < 0.2){
            NSLog(@"Perfect!");
        }else if(rhythmMultiplier > 0.2){
            NSLog(@"OK");
        }
        
        

    }
}

-(void)setEnemyPositions{
    
    SKSpriteNode *enemy1 = [SKSpriteNode spriteNodeWithImageNamed:@"orc01.png"];
    enemy1.name = @"enemy1";
    enemy1.position = CGPointMake((self.frame.size.width+enemy1.size.width), CGRectGetMidY(self.frame));
    enemy1.size = CGSizeMake(70,70);
    enemy1.zPosition = 1.0f;
    [self addChild:enemy1];
    
    SKSpriteNode *enemy2 = [SKSpriteNode spriteNodeWithImageNamed:@"orc01.png"];
    enemy2.name = @"enemy2";
    enemy2.position = CGPointMake(2*(self.frame.size.width+enemy1.size.width), CGRectGetMidY(self.frame));
    enemy2.size = CGSizeMake(70,70);
    enemy2.zPosition = 1.0f;
    [self addChild:enemy2];
    
     self.enemyArray = [NSArray arrayWithObjects:enemy1, enemy2, nil];
    
}

#pragma mark- update

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
   // Remove enemies from view if they touch the left edge; This may not be necessary as apparently SpriteKit only renders nodes on the screen?
    for(SKNode *enemy in self.enemyArray){
        if([enemy intersectsNode:[self childNodeWithName:@"player"]]&&!enemy.hidden){
            enemy.hidden = YES;
            NSLog(@"remove dat shit");
        }
    }
    
}

#pragma mark- tempo methods

-(void)beat{

    if(self.firstBeat){
        [backgroundAudioPlayer play];
        NSLog(@"start the drums");
        
    }
    
    self.beatTime = CACurrentMediaTime();
    self.beatCount++;
    if(self.beatCount%4 == 0){
        NSLog(@"measure");
        self.measureCount++;
        SKNode *background = [self childNodeWithName:@"background"];
        SKAction *moveBackground = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
        
        [background runAction:moveBackground];
        [self moveEnemies];
    }
    
    NSLog(@"beat");
    
    self.firstBeat = NO;
    
    
    /*SKNode *camera = [self childNodeWithName:@"//camera"];
    SKAction *moveCamera = [SKAction moveByX:([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0];
    [camera runAction:moveCamera];
    [self centerOnNode:camera];*/
}

- (void) centerOnNode: (SKNode *) node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x -
                                       cameraPositionInScene.x,
                                       node.parent.position.y - cameraPositionInScene.y);
}

#pragma mark- Enemy Methods
-(void)moveEnemies{
    
    
   // SKNode *enemy1 = [self childNodeWithName:@"enemy1"];
    //SKNode *enemy2 = [self childNodeWithName:@"enemy2"];
    
    SKAction *moveEnemy = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
    
    for(SKSpriteNode *enemy in self.enemyArray){
        [enemy runAction:moveEnemy];
    }
    
}

#pragma mark - keyboard key nodes

-(SKSpriteNode *)lowANode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"aKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake([[UIScreen mainScreen] bounds].size.width/12, [[UIScreen mainScreen] bounds].size.height/2.25)];
    keyNode.position = CGPointMake(([[UIScreen mainScreen] bounds].size.width/12)*0.5,(self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowANode";//how the node is identified later
    keyNode.zPosition = 1.0;
        self.yPositionIncrement = [[UIScreen mainScreen] bounds].size.width/12;
    return keyNode;
}

-(SKSpriteNode *)lowBNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"bKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake([[UIScreen mainScreen] bounds].size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(1*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5,(self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowBNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

-(SKSpriteNode *)lowCNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"cKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(2*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5,(self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowCNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}


- (SKSpriteNode *)lowDNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"dKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(3*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowDNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)lowENode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"eKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(4*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowENode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}


- (SKSpriteNode *)highFNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"fFKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(5*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highFNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highGNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"gKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(6*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5,(self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highGNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highANode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"aKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    NSLog(@"width: %f, height: %f", self.frame.size.width/12, self.frame.size.height);
    keyNode.position = CGPointMake(7*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highANode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highBNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"bKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(8*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highBNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highCNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"cKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(9*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highCNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highDNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"dKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(10*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highDNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

-(SKSpriteNode *)highENode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"eKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(11*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highENode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}


@end
