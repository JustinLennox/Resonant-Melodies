//
//  Level1.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/26/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "Level1.h"

#define lAKeySound @"lA.caf"
#define lBKeySound @"lB.caf"
#define lCKeySound @"lC.caf"
#define lDKeySound @"lD.caf"
#define lEKeySound @"lE.caf"

#define fKeySound @"f.caf"
#define gKeySound @"g.caf"
#define aKeySound @"a.caf"
#define bKeySound @"b.caf"
#define cKeySound @"c.caf"
#define dKeySound @"d.caf"
#define eKeySound @"e.caf"

#define backgroundSound @"Level1Drums.caf"

@implementation Level1{
    SKNode *node;
    AVAudioPlayer *backgroundAudioPlayer;
    int _nextKeyLaser;
    // Sound Effects
    ALDevice* device;
    ALContext* context;
    ALChannelSource* channel;
    ALChannelSource* lowChannel;
    ALChannelSource* backgroundChannel;
    
    ALBuffer* lAKeyBuffer;
    ALBuffer* lBKeyBuffer;
    ALBuffer* lCKeyBuffer;
    ALBuffer* lDKeyBuffer;
    ALBuffer* lEKeyBuffer;
    
    ALBuffer* fKeyBuffer;
    ALBuffer* gKeyBuffer;
    ALBuffer* aKeyBuffer;
    ALBuffer* bKeyBuffer;
    ALBuffer* cKeyBuffer;
    ALBuffer* dKeyBuffer;
    ALBuffer* eKeyBuffer;
    
    ALBuffer* backgroundBuffer;
    
    // Background Music
    OALAudioTrack* musicTrack;
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
    
    
    self.shouldMove = YES;
    self.view.multipleTouchEnabled = YES;
    
#pragma mark- set up background
    SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"Sakura Forest Game Background.png"];
    backgroundImage.name = @"background";
    backgroundImage.position = CGPointMake(0,0);
    backgroundImage.anchorPoint = CGPointZero;
    backgroundImage.zPosition = -1.0f;
    [self addChild:backgroundImage];
    
    SKSpriteNode *backgroundImage2 = [SKSpriteNode spriteNodeWithImageNamed:@"Sakura Forest Game Background.png"];
    backgroundImage2.name = @"background2";
    backgroundImage2.position = CGPointMake(backgroundImage.size.width - 2,0);
    backgroundImage2.anchorPoint = CGPointZero;
    backgroundImage2.zPosition = -1.1f;
    [self addChild:backgroundImage2];
    
    //Add Right Edge Boundary
    SKSpriteNode *rightEdge = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1.0, self.frame.size.height)];
    rightEdge.name = @"rightEdge";
    rightEdge.position = CGPointMake(self.frame.size.width, CGRectGetMidY(self.frame));
    [self addChild:rightEdge];
    
    //Add Left Edge Boundary
    SKSpriteNode *leftEdge = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1.0, self.frame.size.height)];
    leftEdge.name = @"leftEdge";
    leftEdge.position = CGPointMake(0, CGRectGetMidY(self.frame));
    [self addChild:leftEdge];
#pragma mark - set Up Audio
    
    // Create the device and context.
    // Note that it's easier to just let OALSimpleAudio handle
    // these rather than make and manage them yourself.
    device = [ALDevice deviceWithDeviceSpecifier:nil];
    context = [ALContext contextOnDevice:device attributes:nil];
    [OpenALManager sharedInstance].currentContext = context;
    
    // Deal with interruptions for me!
    [OALAudioSession sharedInstance].handleInterruptions = YES;
    
    // We don't want ipod music to keep playing since
    // we have our own bg music.
    [OALAudioSession sharedInstance].allowIpod = NO;
    
    // Mute all audio if the silent switch is turned on.
    [OALAudioSession sharedInstance].honorSilentSwitch = YES;
    
    // Take all 32 sources for this channel.
    // (we probably won't use that many but what the heck!)
    channel = [ALChannelSource channelWithSources:30];
    lowChannel = [ALChannelSource channelWithSources:1];
    backgroundChannel = [ALChannelSource channelWithSources:1];
    
    // Preload the buffers so we don't have to load and play them later.
    lAKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:lAKeySound];
    lBKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:lBKeySound];
    lCKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:lCKeySound];
    lDKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:lDKeySound];
    lEKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:lEKeySound];
    
    fKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:fKeySound];
    gKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:gKeySound];
    aKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:aKeySound];
    bKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:bKeySound];
    cKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:cKeySound];
    dKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:dKeySound];
    eKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:eKeySound];
    
    backgroundBuffer = [[OpenALManager sharedInstance] bufferFromFile:backgroundSound];
    
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
    
    self.keyArray = @[[self childNodeWithName:@"lowANode"], [self childNodeWithName:@"lowBNode"], [self childNodeWithName:@"lowCNode"], [self childNodeWithName:@"lowDNode"], [self childNodeWithName:@"lowENode"], [self childNodeWithName:@"highFNode"], [self childNodeWithName:@"highGNode"], [self childNodeWithName:@"highANode"], [self childNodeWithName:@"highBNode"], [self childNodeWithName:@"highCNode"], [self childNodeWithName:@"highDNode"], [self childNodeWithName:@"highENode"]];
    
#pragma mark- set up player
    self.player = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"dalf1.png"] size:CGSizeMake(70, 70)];
    self.player.position = CGPointMake(-self.player.size.width, CGRectGetMidY(self.frame));
    self.player.name = @"player";
    self.player.zPosition = 1.0f;
    self.currentHero = @"Amos";
    [self addChild:self.player];
    

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
    self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
#pragma mark- add lasers
    self.keyLasers = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30; ++i) {
        KeyLaser *keyLaser = [KeyLaser spriteNodeWithImageNamed:@"laserbeam_blue"];
        //SKSpriteNode *shipLaser = [SKSpriteNode spriteNodeWithTexture:laserTexture];
        keyLaser.name = @"keyLaser";
        keyLaser.hidden = YES;
        [self.keyLasers addObject:keyLaser];
        [self addChild:keyLaser];
    }
    
    //self.lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    //self.lpgr.minimumPressDuration = 60/self.BPM;
    //self.lpgr.allowableMovement = 100.0f;
    
    //[self.view addGestureRecognizer:self.lpgr];
#pragma mark- add labels
    
    self.gigiHealth = 3.0;
    self.gigiHealthLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.gigiHealthLabel .name = @"gigiHealthLabel";
    self.gigiHealthLabel .text = @"Gigi Health: 3.0";
    self.gigiHealthLabel .fontSize = 20.0f;
    self.gigiHealthLabel .zPosition =1.0f;
    self.gigiHealthLabel .position = CGPointMake(self.frame.size.width*0.25, self.frame.size.height*0.9);
    self.gigiHealthLabel .fontColor = [SKColor greenColor];
    [self addChild:self.gigiHealthLabel];
    
    self.amosHealth = 3.0;
    self.amosHealthLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.amosHealthLabel .name = @"amosHealthLabel";
    self.amosHealthLabel .text = @"Amos Health: 3.0";
    self.amosHealthLabel .fontSize = 20.0f;
    self.amosHealthLabel .zPosition =1.0f;
    self.amosHealthLabel .position = CGPointMake(self.frame.size.width*0.50, self.frame.size.height*0.9);
    self.amosHealthLabel .fontColor = [SKColor greenColor];
    [self addChild:self.amosHealthLabel];
    
    self.dvonHealth = 3.0;
    self.dvonHealthLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.dvonHealthLabel .name = @"dvonHealthLabel";
    self.dvonHealthLabel .text = @"Dvon Health: 3.0";
    self.dvonHealthLabel .fontSize = 20.0f;
    self.dvonHealthLabel .zPosition =1.0f;
    self.dvonHealthLabel .position = CGPointMake(self.frame.size.width*0.75, self.frame.size.height*0.9);
    self.dvonHealthLabel .fontColor = [SKColor greenColor];
    [self addChild:self.dvonHealthLabel];
    
    //Other inits
    self.shouldShoot = YES;
    
    [self playCutscene:@"intro"];

}

#pragma mark - handle touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    double keyLaserDamage = 1.0f;
    
    for (UITouch *touch in touches) {
        double touchTime = CACurrentMediaTime();
        double rhythmMultiplier = fabs(touchTime - self.beatTime);
        if(rhythmMultiplier < 0.2){
            NSLog(@"Perfect!");
            keyLaserDamage = 1.0f;
        }else if(rhythmMultiplier > 0.2){
            NSLog(@"OK");
            keyLaserDamage = 0.8f;
        }
        
        self.touchDown = YES;
        
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        
        if([n.name isEqualToString:@"lowANode"])
        {
            [lowChannel stop];
            [lowChannel play:lAKeyBuffer loop:YES];
            self.mode = @"Attack";
            self.currentHero = @"Amos";
            
            [self.keyPressArray insertObject:@"lowANode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self changeModes];
            [self checkInteractables:@"lowANode"];
        }else if([n.name isEqualToString:@"lowBNode"])
        {
            [lowChannel stop];
            [lowChannel play:lBKeyBuffer loop:YES];
            self.mode = @"Defense";
            self.currentHero = @"Dvon";

            [self.keyPressArray insertObject:@"lowBNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self changeModes];
            [self checkInteractables:@"lowBNode"];
        }else if([n.name isEqualToString:@"lowCNode"])
        {
            [lowChannel stop];
            [lowChannel play:lCKeyBuffer loop:YES];
            
            [self getPlayerCurrentKey];

            if([[self.keyPressArray objectAtIndex:0] isEqualToString:@"lowCNode"]||[self.mode isEqualToString:@"Bag"]){
                [self movePlayer:@"lowCNode"];
            }
            
            self.mode = @"Bag";
            [self.keyPressArray insertObject:@"lowCNode" atIndex:0];
            [self changeModes];
            [self.keyPressArray removeLastObject];
            [self checkInteractables:@"lowCNode"];
        }else if([n.name isEqualToString:@"lowDNode"])
        {
            [lowChannel stop];
            [lowChannel play:lDKeyBuffer loop:YES];
            self.mode = @"Magic";
            self.currentHero = @"Gigi";
            
            [self.keyPressArray insertObject:@"lowDNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self changeModes];
            [self checkInteractables:@"lowDNode"];
        }else if([n.name isEqualToString:@"lowENode"])
        {
            [lowChannel stop];
            [lowChannel play:lEKeyBuffer loop:YES];
            self.mode = @"Resonance";
            self.currentHero = @"All";
            
            [self.keyPressArray insertObject:@"lowENode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self changeModes];
            [self checkInteractables:@"lowENode"];
        }else if([n.name isEqualToString:@"highFNode"])
        {
            [channel play:fKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highFNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highFNode"];
            [self checkInteractables:@"highFNode"];
        }else if([n.name isEqualToString:@"highGNode"])
        {
            [channel play:gKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highGNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highGNode"];
            [self checkInteractables:@"highGNode"];
        }else if([n.name isEqualToString:@"highANode"])
        {
            [channel play:aKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highANode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highANode"];
            [self checkInteractables:@"highANode"];
        }else if([n.name isEqualToString:@"highBNode"])
        {
            [channel play:bKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highBNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highBNode"];
            [self checkInteractables:@"highBNode"];
        }else if([n.name isEqualToString:@"highCNode"])
        {
            [channel play:cKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highCNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highCNode"];
            [self checkInteractables:@"highCNode"];
        }else if([n.name isEqualToString:@"highDNode"])
        {
            [channel play:dKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highDNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highDNode"];
            [self checkInteractables:@"highDNode"];
        }else if([n.name isEqualToString:@"highENode"])
        {
            [channel play:eKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highENode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highENode"];
            [self checkInteractables:@"highENode"];
        }
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchDown = NO;
    [self checkInteractables:@""];
}

-(void)checkInteractables:(NSString *)keyNode{
    
    if(self.touchDown)
    {
        if(![self childNodeWithName:@"sign1Label"]){
            if(([self childNodeWithName:@"sign1"].position.x > CGRectGetMinX([self childNodeWithName:keyNode].frame))&&([self childNodeWithName:@"sign1"].position.x < CGRectGetMaxX([self childNodeWithName:keyNode].frame))){
                    SKLabelNode *sign1Label;
                    sign1Label.hidden = NO;
                    sign1Label.alpha = 1.0f;
                    sign1Label = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
                    sign1Label.name = @"sign1Label";
                    sign1Label.text = @"Try pressing the lower keys to switch characters!";
                    sign1Label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                    sign1Label.zPosition = 1.1f;
                    sign1Label.fontColor = [SKColor redColor];
                    [self addChild:sign1Label];
            }
        }else if(([self childNodeWithName:@"sign1"].position.x > CGRectGetMinX([self childNodeWithName:keyNode].frame))&&([self childNodeWithName:@"sign1"].position.x < CGRectGetMaxX([self childNodeWithName:keyNode].frame))){
                        [self childNodeWithName:@"sign1Label"].alpha = 1.0f;
            
        }
    }else{
        if([self childNodeWithName:@"sign1Label"]){
            [self childNodeWithName:@"sign1Label"].alpha = 0.0f;
            if(![self childNodeWithName:@"sign1"].hidden){
                self.shouldMove = YES;
            }
        }
    }
    
    if(self.touchDown){
        if(![self childNodeWithName:@"sign2Label"]){
            if(([self childNodeWithName:@"sign2"].position.x > CGRectGetMinX([self childNodeWithName:keyNode].frame))&&([self childNodeWithName:@"sign2"].position.x < CGRectGetMaxX([self childNodeWithName:keyNode].frame))){
                SKLabelNode *sign2Label;
                sign2Label.hidden = NO;
                sign2Label.alpha = 1.0f;
                sign2Label = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
                sign2Label.name = @"sign2Label";
                sign2Label.text = @"Use the upper keys for combos!\rTry ABC!";
                sign2Label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                sign2Label.zPosition = 1.1f;
                sign2Label.fontColor = [SKColor redColor];
                [self addChild:sign2Label];
            }
        }else if(([self childNodeWithName:@"sign2"].position.x > CGRectGetMinX([self childNodeWithName:keyNode].frame))&&([self childNodeWithName:@"sign2"].position.x < CGRectGetMaxX([self childNodeWithName:keyNode].frame))){
            [self childNodeWithName:@"sign2Label"].alpha = 1.0f;
            
        }
    }else{
        if([self childNodeWithName:@"sign2Label"]){
            [self childNodeWithName:@"sign2Label"].alpha = 0.0f;
            if(![self childNodeWithName:@"sign2"].hidden){
                self.shouldMove = YES;
            }
        }
    }

    
}

-(void)changeModes{
    if([self.mode isEqualToString:@"Magic"]){
        self.player.texture = [SKTexture textureWithImageNamed:@"gaia1.png"];
        SKLabelNode *gigiLabel;
        gigiLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        gigiLabel.name = @"gigiLabel";
        gigiLabel.text = @"Magic!";
        gigiLabel.fontSize = 80;
        gigiLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        gigiLabel.fontColor = [SKColor greenColor];
        [self addChild:gigiLabel];
        
        SKAction *fadeAction = [SKAction fadeAlphaTo:0.0f duration:0.5];
        SKAction *moveUp = [SKAction moveToY:gigiLabel.position.y+10 duration:0.5];
        SKAction *fadeUp = [SKAction group:@[moveUp, fadeAction]];
        [gigiLabel runAction:fadeUp];

    }else if([self.mode isEqualToString:@"Attack"]){
        self.player.texture = [SKTexture textureWithImageNamed:@"dalf1.png"];
        
        SKLabelNode *amosLabel;
        amosLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        amosLabel.name = @"amosLabel";
        amosLabel.text = @"Attack!";
        amosLabel.fontSize = 80;
        amosLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        amosLabel.fontColor = [SKColor redColor];
        [self addChild:amosLabel];
        
        SKAction *fadeAction = [SKAction fadeAlphaTo:0.0f duration:0.5];
        SKAction *moveUp = [SKAction moveToY:amosLabel.frame.origin.y+10 duration:0.5];
        SKAction *fadeUp = [SKAction group:@[moveUp, fadeAction]];
        [amosLabel runAction:fadeUp];
    }else if([self.mode isEqualToString:@"Defense"]){
        self.player.texture = [SKTexture textureWithImageNamed:@"aragon1.png"];
        
        SKLabelNode *dvonLabel;
        dvonLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        dvonLabel.name = @"dvonLabel";
        dvonLabel.text = @"Defense!";
        dvonLabel.fontSize = 80;
        dvonLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        dvonLabel.fontColor = [SKColor blueColor];
        [self addChild:dvonLabel];
        
        SKAction *fadeAction = [SKAction fadeAlphaTo:0.0f duration:0.5];
        SKAction *moveUp = [SKAction moveToY:dvonLabel.frame.origin.y+10 duration:0.5];
        SKAction *fadeUp = [SKAction group:@[moveUp, fadeAction]];
        [dvonLabel runAction:fadeUp];
    }else if([self.mode isEqualToString:@"Bag"]){
        SKLabelNode *bagLabel;
        bagLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        bagLabel.name = @"bagLabel";
        bagLabel.text = @"Bag!";
        bagLabel.fontSize = 80;
        bagLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        bagLabel.fontColor = [SKColor brownColor];
        [self addChild:bagLabel];
        
        SKAction *fadeAction = [SKAction fadeAlphaTo:0.0f duration:0.5];
        SKAction *moveUp = [SKAction moveToY:bagLabel.frame.origin.y+10 duration:0.5];
        SKAction *fadeUp = [SKAction group:@[moveUp, fadeAction]];
        [bagLabel runAction:fadeUp];
        
        //TO DO:
        //ADD MOVE SCENE LEFT AND MOVE SCENE RIGHT NODES
        
    }else if([self.mode isEqualToString:@"Resonance"]){
        SKLabelNode *resonanceLabel;
        resonanceLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        resonanceLabel.name = @"bagLabel";
        resonanceLabel.text = @"Resonance!";
        resonanceLabel.fontSize = 80;
        resonanceLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        resonanceLabel.fontColor = [SKColor whiteColor];
        [self addChild:resonanceLabel];
        
        SKAction *fadeAction = [SKAction fadeAlphaTo:0.0f duration:0.5];
        SKAction *moveUp = [SKAction moveToY:resonanceLabel.frame.origin.y+10 duration:0.5];
        SKAction *fadeUp = [SKAction group:@[moveUp, fadeAction]];
        [resonanceLabel runAction:fadeUp];
        
    }
}

-(void)shootLaser:(float)keyLaserDamage{
    if(self.shouldShoot){
        KeyLaser *keyLaser = [self.keyLasers objectAtIndex:_nextKeyLaser];
        _nextKeyLaser++;
        if (_nextKeyLaser >= self.keyLasers.count) {
            
            _nextKeyLaser = 0;
        }
        keyLaser.damage = keyLaserDamage;
        keyLaser.position = CGPointMake(self.player.position.x+keyLaser.size.width/2,self.player.position.y+0);
        keyLaser.hidden = NO;
        [keyLaser removeAllActions];
        
        
        CGPoint location = CGPointMake(self.frame.size.width, self.player.position.y);
        SKAction *laserMoveAction = [SKAction moveTo:location duration:0.5];
        SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
            //NSLog(@"Animation Completed");
            keyLaser.hidden = YES;
        }];
        
        SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
        
        [keyLaser runAction:moveLaserActionWithDone withKey:@"laserFired"];
    }
}

#pragma mark- setting enemy positions

-(void)setEnemyPositions{
    
    SKSpriteNode *sign1 = [SKSpriteNode spriteNodeWithImageNamed:@"signPost.jpg"];
    sign1.name = @"sign1";
    sign1.position = CGPointMake((self.frame.size.width+([[UIScreen mainScreen] bounds].size.width/12)), CGRectGetMidY(self.frame));
    sign1.size = CGSizeMake(30,30);
    sign1.zPosition = 0.0f;
    [self addChild:sign1];
    
    SKSpriteNode *sign2 = [SKSpriteNode spriteNodeWithImageNamed:@"signPost.jpg"];
    sign2.name = @"sign2";
    sign2.position = CGPointMake(1.5*(self.frame.size.width+([[UIScreen mainScreen] bounds].size.width/12)), CGRectGetMidY(self.frame));
    sign2.size = CGSizeMake(30,30);
    sign2.zPosition = 0.0f;
    [self addChild:sign2];
    
    Enemy *enemy1 = [Enemy spriteNodeWithImageNamed:@"orc01.png"];
    enemy1.name = @"enemy1";
    enemy1.position = CGPointMake(2*(self.frame.size.width+sign1.size.width), CGRectGetMidY(self.frame));
    enemy1.size = CGSizeMake(70,70);
    enemy1.zPosition = 1.0f;
    enemy1.health = 30;
    [self addChild:enemy1];
    
    self.enemyArray = [NSArray arrayWithObjects:enemy1, nil];
    self.moveablesArray = [NSArray arrayWithObjects:sign1, sign2, enemy1, nil];
    self.interactableArray = [NSArray arrayWithObjects:sign1, sign2, nil];
    
    for(Enemy *enemy in self.enemyArray){
        if(enemy.health){
            SKLabelNode *enemyHealthLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
            enemyHealthLabel.text = [NSString stringWithFormat:@"%.2f", enemy.health];
            enemyHealthLabel.position = CGPointMake(CGRectGetMidX(enemy.frame), enemy.position.y + 30);
            enemyHealthLabel.color = [SKColor redColor];
            enemyHealthLabel.fontColor = [SKColor redColor];
            enemyHealthLabel.name = [NSString stringWithFormat:@"%@Label", enemy.name];
            enemyHealthLabel.fontSize = 20;
            [self addChild:enemyHealthLabel];
        }
    }
    
}

#pragma mark- update

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // Stop view from moving if a sign is present
    if(([[self childNodeWithName:@"rightEdge"] intersectsNode:[self childNodeWithName:@"sign1"]] ) || ([[self childNodeWithName:@"rightEdge"] intersectsNode:[self childNodeWithName:@"sign2"]] ) ){
        self.shouldMove = NO;
    }

    //Watch the enemy's movement
    for(SKSpriteNode *enemy in self.moveablesArray){
        if([enemy intersectsNode:[self childNodeWithName:@"player"]]&&!enemy.hidden&&(enemy.zPosition==1.0f))
        {
            if([self.currentHero isEqualToString:@"Gigi"]){
                self.gigiHealth--;
                self.gigiHealthLabel.text = [NSString stringWithFormat:@"Gigi Health: %.2f", self.gigiHealth];
            }else if([self.currentHero isEqualToString:@"Amos"]){
                self.amosHealth--;
                self.amosHealthLabel.text = [NSString stringWithFormat:@"Amos Health: %.2f", self.amosHealth];
            }else if([self.currentHero isEqualToString:@"Dvon"]){
                self.dvonHealth--;
                self.dvonHealthLabel.text = [NSString stringWithFormat:@"Dvon Health: %.2f", self.dvonHealth];
            }
            enemy.hidden = YES;
            [self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]].hidden = YES;
        }else if([[self childNodeWithName:@"rightEdge"] intersectsNode:enemy])
        {
            SKAction *moveEnemy = [SKAction moveToX:CGRectGetMidX([self childNodeWithName:@"highENode"].frame) duration:0.2f];
            [enemy runAction:moveEnemy];
        }else if([[self childNodeWithName:@"leftEdge"] intersectsNode:enemy])
        {
            enemy.hidden = YES;
            [self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]].hidden = YES;
        }
    }
    
    for (Enemy *enemy in _enemyArray)
    {
        if (enemy.hidden) {
            continue;
        }
        for (KeyLaser *keyLaser in _keyLasers)
        {
            if (keyLaser.hidden) {
                continue;
            }

            if([keyLaser intersectsNode:enemy])
            {
                NSLog(@"Hit the enemy!");
                if(!keyLaser.hidden){
                    enemy.health -= keyLaser.damage;
                    NSLog(@"Hit the enemy & hidden !");
                    keyLaser.hidden = YES;
                    if(enemy.health <= 0)
                    {
                        enemy.hidden = YES;
                    }
                }
                
            }else if([keyLaser intersectsNode:[self childNodeWithName:@"rightEdge"]])
            {
                if(!keyLaser.hidden){
                    keyLaser.hidden = YES;
                }
            }
            
        }

        
        //Change Enemy Health Label
        if(enemy.health > 0){
            SKLabelNode *healthLabel = (SKLabelNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]];
            healthLabel.text = [NSString stringWithFormat:@"%.2f", enemy.health];
            healthLabel.position = CGPointMake(CGRectGetMidX(enemy.frame), enemy.position.y + 30);
        }else{
            SKLabelNode *healthLabel = (SKLabelNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]];
            healthLabel.hidden = YES;
        }
    }
    
    //Update Background
    SKSpriteNode *background = (SKSpriteNode*)[self childNodeWithName:@"background"];
    SKSpriteNode *background2 = (SKSpriteNode*)[self childNodeWithName:@"background2"];
    
    if (background.position.x < -background.size.width){
        background.position = CGPointMake(background2.position.x + background2.size.width - 2, background.position.y);
    }
    
    if (background2.position.x < -background2.size.width) {
        background2.position = CGPointMake(background.position.x + background.size.width - 2, background2.position.y);
    }

    
}


#pragma mark- tempo methods

-(void)beat{

    if(self.firstBeat){
        [backgroundChannel play:backgroundBuffer loop:YES];
        NSLog(@"start the drums");
        
    }
    
    self.beatTime = CACurrentMediaTime();
    self.beatCount++;
    if(self.beatCount%4 == 0){
        self.measureCount++;
        SKSpriteNode *background = (SKSpriteNode*)[self childNodeWithName:@"background"];
        SKSpriteNode *background2 = (SKSpriteNode*)[self childNodeWithName:@"background2"];
        
        SKAction *moveBackground = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
        if(self.shouldMove){
            [background runAction:moveBackground];
            [background2 runAction:moveBackground];
            //background.position = CGPointMake(background.position.x-([[UIScreen mainScreen] bounds].size.width/12), background.position.y);
            //background2.position = CGPointMake(background2.position.x-([[UIScreen mainScreen] bounds].size.width/12), background2.position.y);
            [self moveEnemies];
        }
    }
    
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

#pragma mark- Move Player
-(void)movePlayer:(NSString *)keyNode{

    if([self.mode isEqualToString:@"Bag"] && self.shouldPlayerMove){
        
        if([self.player actionForKey:@"movePlayer"]){
            [self.player removeActionForKey:@"movePlayer"];
        }
        
        SKSpriteNode *keySprite = (SKSpriteNode *)[self childNodeWithName:keyNode];
        double distance = fabs(CGRectGetMidX(keySprite.frame) - self.player.position.x);
        
        //calculate your new duration based on the distance
        float moveDuration = 0.01*distance;
        
        SKAction *movePlayer = [SKAction moveTo:CGPointMake(CGRectGetMidX(keySprite.frame), CGRectGetMidY(self.frame)) duration:moveDuration];
        
        [self.player runAction:movePlayer withKey:@"movePlayer"];
    }
    
}

-(void)getPlayerCurrentKey{
    for(SKSpriteNode *key in self.keyArray){
        if((self.player.position.x > CGRectGetMinX(key.frame))&&(self.player.position.x < CGRectGetMaxX(key.frame))){
            self.currentPlayerKey = key.name;
            NSLog(@"current player key: %@", key.name);
        }
    }
}
#pragma mark- Enemy Methods
-(void)moveEnemies{
    
    
    // SKNode *enemy1 = [self childNodeWithName:@"enemy1"];
    //SKNode *enemy2 = [self childNodeWithName:@"enemy2"];
    
    for(SKSpriteNode *enemy in self.moveablesArray){
        SKAction *moveEnemy = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
        [enemy runAction:moveEnemy];
    }
    
    for(Enemy *enemy in self.enemyArray){
        SKLabelNode *enemyHealthLabel = (SKLabelNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]];
        SKAction *moveLabel = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
        [enemyHealthLabel runAction:moveLabel];
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

#pragma mark- cutscenes

-(void)playCutscene: (NSString *)sceneName{
    self.cutscene = YES;
    self.shouldMove = NO;
    self.shouldShoot = NO;
    self.shouldPlayerMove = NO;
    
    if([sceneName isEqualToString:@"intro"]){
        SKAction *moveToPositions = [SKAction moveToX:CGRectGetMidX([self childNodeWithName:@"lowCNode"].frame) duration:2.0f];
        //SKAction *cutsceneSequence = [SKAction sequence:@[moveToPositions, [self performSelector:@selector(endCutscene) withObject:nil afterDelay:2.0f]]];
        [self.player runAction:moveToPositions completion:^{
             [self endCutscene];
        }];
    }
    
}

-(void)endCutscene{
    NSLog(@"Cutscene ended");
    self.cutscene = NO;
    self.shouldMove = YES;
    self.shouldShoot = YES;
    self.shouldPlayerMove = YES;
    
}
@end
