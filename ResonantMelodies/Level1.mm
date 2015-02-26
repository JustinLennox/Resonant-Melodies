//
//  Level1.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/26/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "Level1.h"

#import "SuperpoweredAdvancedAudioPlayer.h"
#import "SuperpoweredAudiofilePlayer.h"
#import "SuperpoweredFilter.h"
#import "SuperpoweredRoll.h"
#import "SuperpoweredFlanger.h"
#import "SuperpoweredIOSAudioOutput.h"
#import "SuperpoweredMixer.h"
#import <stdlib.h>
#import <pthread.h>
#import "SuperpoweredAnalyzer.h"
#import "Interactable.h"
#import "EnemyShot.h"

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
#define bowtieSound @"Crash-Cymbal-2.wav"

#define HEADROOM_DECIBEL 3.0f
static const float headroom = powf(10.0f, -HEADROOM_DECIBEL * 0.025);

/*@implementation SKScene (Unarchive)


+ (instancetype)unarchiveFromFile:(NSString *)file {
    Retrieve scene file path from the application bundle
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
     Unarchive the file to an SKScene object
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end*/

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
    ALBuffer* bowtieBuffer;
    
    ALBuffer* backgroundBuffer;
    
    // Background Music
    OALAudioTrack* musicTrack;
    
    //Superpowered
    SuperpoweredAdvancedAudioPlayer *playerBack, *playerC, *playerD, *playerE, *playerF, *playerG;
    SuperpoweredIOSAudioOutput *output;
    SuperpoweredRoll *roll;
    SuperpoweredFilter *filter;
    SuperpoweredFlanger *flanger;
    SuperpoweredStereoMixer *mixer;
    SuperpoweredAudiofilePlayer *highC;
    unsigned char activeFx;
    float *stereoBuffer, crossValue, volBack, volC, volD, volE, volF, volG;
    unsigned int lastSamplerate;
    pthread_mutex_t mutex;
    
}

#pragma mark- beginning init
-(void)didMoveToView:(SKView *)view {
    //Level1 *scene = [Level1 unarchiveFromFile:@"Level1Scene"];
    
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
    backgroundImage.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    backgroundImage.position = CGPointMake(0,0);
    backgroundImage.anchorPoint = CGPointZero;
    backgroundImage.zPosition = -1.0f;
    [self addChild:backgroundImage];
    
    SKSpriteNode *backgroundImage2 = [SKSpriteNode spriteNodeWithImageNamed:@"Sakura Forest Game Background.png"];
    backgroundImage2.name = @"background2";
    backgroundImage2.position = CGPointMake(backgroundImage.size.width - 2,0);
    backgroundImage2.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
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
    bowtieBuffer = [[OpenALManager sharedInstance] bufferFromFile:bowtieSound];
    
    channel.volume = 0.4f;
    
    
#pragma mark- add keys
    self.yPositionIncrement = [[UIScreen mainScreen] bounds].size.width/12;
    
    [self addChild: [self lowCNode]];
    [self addChild: [self lowDNode]];
    [self addChild: [self lowENode]];
    [self addChild: [self lowFNode]];
    [self addChild: [self lowGNode]];
    [self addChild: [self highANode]];
    [self addChild: [self highBNode]];
    [self addChild: [self highCNode]];
    [self addChild: [self highDNode]];
    [self addChild: [self highENode]];
    [self addChild: [self highFNode]];
    [self addChild: [self highGNode]];
    
    self.keyArray = @[[self childNodeWithName:@"lowCNode"], [self childNodeWithName:@"lowDNode"], [self childNodeWithName:@"lowENode"], [self childNodeWithName:@"lowFNode"], [self childNodeWithName:@"lowGNode"], [self childNodeWithName:@"highANode"], [self childNodeWithName:@"highBNode"], [self childNodeWithName:@"highCNode"], [self childNodeWithName:@"highDNode"], [self childNodeWithName:@"highENode"], [self childNodeWithName:@"highFNode"], [self childNodeWithName:@"highGNode"]];
    
#pragma mark- set up player
    self.player = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"dalf1.png"] size:CGSizeMake(70, 70)];
    self.player.position = CGPointMake(-self.player.size.width, CGRectGetMidY(self.frame)-5);
    self.player.name = @"player";
    self.player.zPosition = 1.0f;
    self.currentHero = @"Amos";
    [self addChild:self.player];
    
    self.bowTie = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"BowTie1.png"] size:CGSizeMake(40, 40)];
    self.bowTie.position = CGPointMake(CGRectGetMinX(self.player.frame) - 10, CGRectGetMaxY(self.player.frame));
    self.bowTie.name = @"bowTie";
    [self addChild:self.bowTie];

    self.playerLevel = 1;
    self.playerExperience = 0;
    self.playerHealth = 10;
    self.playerHealthMax = 10;
    self.playerToNextLevel = 100;
    
    self.attackMP = 3;
    self.attackMPMax = 3;
    
    self.defenseMP = 3;
    self.defenseMPMax = 3;
    
    self.magicMP = 3;
    self.magicMPMax = 3;
    
#pragma mark- set tempo
    
    self.BPM = 125;
        
    //Start rhythm
    self.firstBeat = YES;
    NSTimer *beat = [NSTimer scheduledTimerWithTimeInterval:(60/self.BPM) target:self selector:@selector(beat) userInfo:nil repeats:YES];
    self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
#pragma mark- add lasers
    self.keyLasers = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30; ++i) {
        KeyLaser *keyLaser = [KeyLaser spriteNodeWithImageNamed:@"laserbeam_blue"];
        keyLaser.size = CGSizeMake(25, 10);
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
    
    self.playerHealth = 3.0;
    self.playerHealthMax = 3.0;
    self.playerHealthLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.playerHealthLabel.name = @"playerHealthLabel";
    self.playerHealthLabel.text = @"Player Health: 10.0";
    self.playerHealthLabel.fontSize = 20.0f;
    self.playerHealthLabel.zPosition =1.0f;
    self.playerHealthLabel.position = CGPointMake(self.frame.size.width*0.50, self.frame.size.height*0.9);
    self.playerHealthLabel.fontColor = [SKColor greenColor];
    [self addChild:self.playerHealthLabel];
    

    SKSpriteNode *healthBarBack = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar_health"];
    healthBarBack.position = CGPointMake(self.frame.size.width*0.10, self.frame.size.height*0.9);
    healthBarBack.size = CGSizeMake(150, 40);
    [self addChild:healthBarBack];
    self.healthBar = [SKSpriteNode spriteNodeWithImageNamed:@"loader_bar_red_fill.png"];
    self.healthBar.position = CGPointMake(5, 5);
    self.healthBar.size = CGSizeMake(self.playerHealth/self.playerHealthMax * 100, 10);
    self.healthBar.anchorPoint = CGPointMake(0.0, 0.5);
    [healthBarBack addChild:self.healthBar];
    
    self.attackMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.attackMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.attackMPLabel.name = @"attackMPLabel";
    self.attackMPLabel.text = @"Adagio MP: 3.0";
    self.attackMPLabel.fontSize = 20.0f;
    self.attackMPLabel.zPosition =1.0f;
    self.attackMPLabel.position = CGPointMake(self.frame.size.width*0.50, self.frame.size.height*0.9 - +10);
    self.attackMPLabel.fontColor = [SKColor greenColor];
    [self addChild:self.attackMPLabel];
    
    self.defenseMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.defenseMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.defenseMPLabel.name = @"defenseMPLabel";
    self.defenseMPLabel.text = @"Brio MP: 3.0";
    self.defenseMPLabel.fontSize = 20.0f;
    self.defenseMPLabel.zPosition =1.0f;
    self.defenseMPLabel.position = CGPointMake(self.frame.size.width*0.75, self.frame.size.height*0.9 - +10);
    self.defenseMPLabel.fontColor = [SKColor greenColor];
    [self addChild:self.defenseMPLabel];
    
#pragma mark- Superpowered init
    lastSamplerate = activeFx = 0;
    crossValue = 1.0f;
    volC = volD = volE = volF = volG =  1.0f * headroom;
    volBack = 0.8 * headroom;
    pthread_mutex_init(&mutex, NULL); // This will keep our player volumes and playback states in sync.
    if (posix_memalign((void **)&stereoBuffer, 16, 4096 + 128) != 0) abort(); // Allocating memory, aligned to 16.
    
    playerBack = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackBack, 44100, 0);
    playerBack->open([[[NSBundle mainBundle] pathForResource:@"Level1Back" ofType:@"aif"] fileSystemRepresentation]);
    playerC = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackC, 44100, 0);
    playerC->open([[[NSBundle mainBundle] pathForResource:@"Bass1C" ofType:@"aif"] fileSystemRepresentation]);
    playerD = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackD, 44100, 0);
    playerD->open([[[NSBundle mainBundle] pathForResource:@"Bass1D" ofType:@"aif"] fileSystemRepresentation]);
    playerE = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackE, 44100, 0);
    playerE->open([[[NSBundle mainBundle] pathForResource:@"Bass1E" ofType:@"aif"] fileSystemRepresentation]);
    playerF = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackF, 44100, 0);
    playerF->open([[[NSBundle mainBundle] pathForResource:@"Bass1F" ofType:@"aif"] fileSystemRepresentation]);
    playerG = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackG, 44100, 0);
    playerG->open([[[NSBundle mainBundle] pathForResource:@"Bass1G" ofType:@"aif"] fileSystemRepresentation]);
    
    playerBack->syncMode = playerC->syncMode = playerD->syncMode = playerE->syncMode = playerF->syncMode = playerG->syncMode = SuperpoweredAdvancedAudioPlayerSyncMode_TempoAndBeat;
    
    playerC->waitForNextBeatWithBeatSync = YES;
    playerD->waitForNextBeatWithBeatSync = YES;
    playerE->waitForNextBeatWithBeatSync = YES;
    playerF->waitForNextBeatWithBeatSync = YES;
    playerG->waitForNextBeatWithBeatSync = YES;
    
    roll = new SuperpoweredRoll(44100);
    filter = new SuperpoweredFilter(SuperpoweredFilter_Resonant_Lowpass, 44100);
    flanger = new SuperpoweredFlanger(44100);
    
    mixer = new SuperpoweredStereoMixer();
    
    output = [[SuperpoweredIOSAudioOutput alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredMinimumSamplerate:44100 audioSessionCategory:AVAudioSessionCategoryPlayback multiChannels:2 fixReceiver:true];
    [output start];
    
#pragma mark- create room transitioners
    SKSpriteNode *rightArrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrowRight.png"];
    rightArrow.name = @"rightArrow";
    rightArrow.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highGNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highENode"].frame) + 20);
    rightArrow.size = CGSizeMake(40, 40);
    [self addChild:rightArrow];
    rightArrow.alpha = 0.0f;
    rightArrow.hidden = YES;
    
    SKSpriteNode *leftArrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrowLeft.png"];
    leftArrow.name = @"leftArrow";
    leftArrow.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowCNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowCNode"].frame) + 20);
    leftArrow.size = CGSizeMake(40, 40);
    [self addChild:leftArrow];
    leftArrow.alpha = 0.0f;
    leftArrow.hidden = YES;
    
    self.currentRoomNumber = 1;
    [self loadRoom:1];
    
#pragma mark- add key icons
    SKSpriteNode *attackSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"weaponSymbol.png"];
    attackSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
    attackSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowCNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowCNode"].frame) - attackSymbol.size.height/2 - 10);
    attackSymbol.name = @"lowCNode";
    attackSymbol.zPosition = 1.1f;
    [self addChild:attackSymbol];
    
    SKSpriteNode *defenseSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"defenseSymbol.png"];
    defenseSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
    defenseSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowDNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowDNode"].frame) - attackSymbol.size.height/2 - 10);
    defenseSymbol.name = @"lowDNode";
    defenseSymbol.zPosition = 1.1f;
    [self addChild:defenseSymbol];
    
    SKSpriteNode *magicSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"magicSymbol.png"];
    magicSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
    magicSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowFNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowFNode"].frame) - attackSymbol.size.height/2 - 10);
    magicSymbol.name = @"lowFNode";
    magicSymbol.zPosition = 1.1f;
    [self addChild:magicSymbol];
    
    SKSpriteNode *moveSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"moveSymbol.png"];
    moveSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
    moveSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowENode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowENode"].frame) - attackSymbol.size.height/2 - 10);
    moveSymbol.name = @"lowENode";
    moveSymbol.zPosition = 1.1f;
    [self addChild:moveSymbol];
    
    SKSpriteNode *resonantSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"resonantSymbol.png"];
    resonantSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
    resonantSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowGNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowGNode"].frame) - attackSymbol.size.height/2 - 10);
    resonantSymbol.name = @"lowGNode";
    resonantSymbol.zPosition = 1.1f;
    [self addChild:resonantSymbol];

#pragma mark- declare other stuff
    
    SKLabelNode *signLabel;
    signLabel.alpha = 0.0f;
    signLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    signLabel.name = @"signLabel";
    signLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    signLabel.zPosition = -2.0f;
    signLabel.fontColor = [SKColor redColor];
    [self addChild:signLabel];
    
    SKSpriteNode *signPost;
    signPost.alpha = 0.0f;
    signPost.hidden = YES;
    signPost = [SKSpriteNode spriteNodeWithImageNamed:@"brownPost.png"];
    signPost.size = CGSizeMake(self.size.width-80, self.size.height-80);
    signPost.name = @"signPost";
    signPost.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    signPost.zPosition = -2.0f;
    [self addChild:signPost];
    signPost.hidden = YES;

    self.touchDown = NO;
    
    [self loadCombos];
    
    self.fireballArray = [[NSMutableArray alloc] init];
    self.enemyShotArray = [[NSMutableArray alloc] init];
    
    self.playerMaxX = CGRectGetMaxX(self.player.frame);
    
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
        self.lastBeat = playerBack->msElapsedSinceLastBeat;
        if(self.lastBeat <= 30.0 || self.lastBeat >= 470.0){
            keyLaserDamage = 1.0f;
        }else if(self.lastBeat <= 50.0 || self.lastBeat >= 450.0){
            keyLaserDamage = 0.5f;
        }else if(self.lastBeat <= 80.0 || self.lastBeat >= 420.0){
            keyLaserDamage = 0.25f;
        }else{
            keyLaserDamage = 0.1f;
        }
        
        self.touchDown = YES;
        
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        NSLog(@"Touch registered");
        NSLog(@"%@", n.name);
        if([n.name isEqualToString:@"lowCNode"])
        {
            //[lowChannel stop];
            //[lowChannel play:lAKeyBuffer loop:YES];
            self.mode = @"Attack";
            self.currentHero = @"Amos";
            //playerC->exitLoop();
            //playerC->open([[[NSBundle mainBundle] pathForResource:@"Bass1.1" ofType:@"aif"] fileSystemRepresentation]);
            pthread_mutex_lock(&mutex);
            playerC->loop(0, 8000, YES, 255, YES);
            playerD->exitLoop();
            playerE->exitLoop();
            playerF->exitLoop();
            playerG->exitLoop();
            playerD->pause();
            playerE->pause();
            playerF->pause();
            playerG->pause();
            pthread_mutex_unlock(&mutex);
            
            [self.keyPressArray insertObject:@"lowCNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self changeModes];
            self.currentKeyDown = @"lowCNode";
        }else if([n.name isEqualToString:@"lowDNode"])
        {
            //[lowChannel stop];
            //[lowChannel play:lBKeyBuffer loop:YES];
            pthread_mutex_lock(&mutex);
            playerC->exitLoop();
            playerD->loop(0, 8000, YES, 255, YES);
            playerE->exitLoop();
            playerF->exitLoop();
            playerG->exitLoop();
            playerC->pause();
            playerE->pause();
            playerF->pause();
            playerG->pause();
            pthread_mutex_unlock(&mutex);
            self.mode = @"Defense";
            self.currentHero = @"Dvon";

            [self.keyPressArray insertObject:@"lowDNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self changeModes];
            self.currentKeyDown = @"lowDNode";
        }else if([n.name isEqualToString:@"lowENode"])
        {
            //[lowChannel stop];
            //[lowChannel play:lCKeyBuffer loop:YES];
            //STOP ALL OTHER LOW NODE SOUNDS
            pthread_mutex_lock(&mutex);
            playerC->exitLoop();
            playerD->exitLoop();
            playerE->loop(0, 8000, YES, 255, YES);
            playerF->exitLoop();
            playerG->exitLoop();
            playerD->pause();
            playerC->pause();
            playerF->pause();
            playerG->pause();
            pthread_mutex_unlock(&mutex);
            [self getPlayerCurrentKey];

            if([[self.keyPressArray objectAtIndex:0] isEqualToString:@"lowENode"]||[self.mode isEqualToString:@"Bag"]){
                [self movePlayer:@"lowENode"];
            }
            
            self.mode = @"Bag";
            [self.keyPressArray insertObject:@"lowENode" atIndex:0];
            [self changeModes];
            [self.keyPressArray removeLastObject];
            self.currentKeyDown = @"lowENode";
        }else if([n.name isEqualToString:@"lowFNode"])
        {
            //[lowChannel stop];
            //[lowChannel play:lDKeyBuffer loop:YES];
            pthread_mutex_lock(&mutex);
            playerC->exitLoop();
            playerD->exitLoop();
            playerE->exitLoop();
            playerF->loop(0, 8000, YES, 255, YES);
            playerG->exitLoop();
            playerD->pause();
            playerE->pause();
            playerC->pause();
            playerG->pause();
            pthread_mutex_unlock(&mutex);
            self.mode = @"Magic";
            self.currentHero = @"Gigi";
            
            [self.keyPressArray insertObject:@"lowFNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self changeModes];
            self.currentKeyDown = @"lowFNode";
        }else if([n.name isEqualToString:@"lowGNode"])
        {
            //[lowChannel stop];
            pthread_mutex_lock(&mutex);
            playerC->exitLoop();
            playerD->exitLoop();
            playerE->exitLoop();
            playerF->exitLoop();
            playerG->loop(0, 8000, YES, 255, YES);
            playerD->pause();
            playerE->pause();
            playerF->pause();
            playerC->pause();
            pthread_mutex_unlock(&mutex);
            //[lowChannel play:lEKeyBuffer loop:YES];
            self.mode = @"Resonance";
            self.currentHero = @"All";
            
            [self.keyPressArray insertObject:@"lowGNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self changeModes];
            self.currentKeyDown = @"lowGNode";
        }else if([n.name isEqualToString:@"highANode"])
        {
            [channel play:aKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highANode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highANode"];
            self.currentKeyDown = @"highANode";
        }else if([n.name isEqualToString:@"highBNode"])
        {
            [channel play:bKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highBNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highBNode"];
            self.currentKeyDown = @"highBNode";
        }else if([n.name isEqualToString:@"highCNode"])
        {
            [channel play:cKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highCNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highCNode"];
            self.currentKeyDown = @"highCNode";
        }else if([n.name isEqualToString:@"highDNode"])
        {
            [channel play:dKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highDNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highDNode"];
            self.currentKeyDown = @"highDNode";
        }else if([n.name isEqualToString:@"highENode"])
        {
            [channel play:eKeyBuffer];
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highENode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highENode"];
            self.currentKeyDown = @"highENode";
        }else if([n.name isEqualToString:@"highFNode"])
        {
            [channel play:fKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highFNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highFNode"];
            self.currentKeyDown = @"highFNode";
        }else if([n.name isEqualToString:@"highGNode"])
        {
            [channel play:gKeyBuffer];
            
            [self shootLaser:keyLaserDamage];
            [self.keyPressArray insertObject:@"highGNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highGNode"];
            self.currentKeyDown = @"highGNode";
        }else if([n.name isEqualToString:@"rightArrow"])
        {
            if([self childNodeWithName:@"rightArrow"].hidden == NO){
                [self loadNextRoom:(self.currentRoomNumber + 1)];
            }
            [self.keyPressArray insertObject:@"rightArrow" atIndex:0];
            [self.keyPressArray removeLastObject];
        }else if([n.name isEqualToString:@"leftArrow"])
        {
            if([self childNodeWithName:@"leftArrow"].hidden == NO){
                [self loadPreviousRoom:(self.currentRoomNumber - 1)];
            }
            [self.keyPressArray insertObject:@"leftArrow" atIndex:0];
            [self.keyPressArray removeLastObject];
        }else if([n.name isEqualToString:@"bowTie"]){
            [channel play:bowtieBuffer];
            if((self.attackMP < self.attackMPMax) && self.bowTieIncrement == 3)
            {
                if([self.mode isEqualToString:@"Attack"]){
                    self.attackMP++;
                    self.bowTieIncrement = 0;
                }else if([self.mode isEqualToString:@"Defense"]){
                    self.defenseMP++;
                    self.bowTieIncrement = 0;
                }else if([self.mode isEqualToString:@"Magic"]){
                    self.magicMP++;
                    self.bowTieIncrement = 0;
                }

            }
            [self.keyPressArray insertObject:@"bowTie" atIndex:0];
            [self.keyPressArray removeLastObject];
        }else{
            [self.keyPressArray insertObject:@"blank" atIndex:0];
            [self.keyPressArray removeLastObject];
        }
        
    }
    
    self.touchBegan = CACurrentMediaTime();
    [self checkCombo];
    if(!self.isAnimating){
        [self animateCharacter];
    }

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchDown = NO;
    [self hideInteractables];
    [self checkResonantMelody];
}

#pragma mark- animations
-(void)animateCharacter{
    self.isAnimating = YES;
    if([self.mode isEqualToString:@"Attack"]){
        NSArray *animatedImages = [NSArray arrayWithObjects:
                                   [SKTexture textureWithImageNamed:@"dalf1.png"],
                                   [SKTexture textureWithImageNamed:@"dalf03.png"],
                                   [SKTexture textureWithImageNamed:@"dalf02.png"],
                                   [SKTexture textureWithImageNamed:@"dalf02.png"],
                                   [SKTexture textureWithImageNamed:@"dalf03.png"],
                                   [SKTexture textureWithImageNamed:@"dalf1.png"],
                                   nil];
        SKAction *animate = [SKAction animateWithTextures:animatedImages timePerFrame: 0.075];
        [self.player runAction:animate withKey:@"dalfAnimation"];
        self.isAnimating = NO;
    }else{
        self.isAnimating = NO;
    }

}

-(void)animateBowTie{
    
    SKAction *moveUp = [SKAction moveByX:0 y:3 duration:1.0f];
    SKAction *moveDown = [SKAction moveByX:0 y:-3 duration:1.0f];
    SKAction *floatAction = [SKAction sequence:@[moveUp, moveDown]];
    [self.bowTie runAction:[SKAction repeatActionForever:floatAction]];
    
  /* NSArray *animatedImages = [NSArray arrayWithObjects:
                               [SKTexture textureWithImageNamed:@"Botie1.png"],
                               [SKTexture textureWithImageNamed:@"Botie8.png"],
                               [SKTexture textureWithImageNamed:@"Botie9.png"],
                               [SKTexture textureWithImageNamed:@"Botie10.png"],
                               [SKTexture textureWithImageNamed:@"Botie11.png"],
                              [SKTexture textureWithImageNamed:@"Botie12.png"],
                              [SKTexture textureWithImageNamed:@"Botie13.png"],
                              [SKTexture textureWithImageNamed:@"Botie14.png"],
                              [SKTexture textureWithImageNamed:@"Botie15.png"],
                              [SKTexture textureWithImageNamed:@"Botie16.png"],
                              [SKTexture textureWithImageNamed:@"Botie17.png"],
                              [SKTexture textureWithImageNamed:@"Botie16.png"],
                              [SKTexture textureWithImageNamed:@"Botie15.png"],
                              [SKTexture textureWithImageNamed:@"Botie14.png"],
                              [SKTexture textureWithImageNamed:@"Botie13.png"],
                              [SKTexture textureWithImageNamed:@"Botie12.png"],
                              [SKTexture textureWithImageNamed:@"Botie11.png"],
                              [SKTexture textureWithImageNamed:@"Botie10.png"],
                              [SKTexture textureWithImageNamed:@"Botie9.png"],
                              [SKTexture textureWithImageNamed:@"Botie8.png"],
                              [SKTexture textureWithImageNamed:@"Botie1.png"],
                               nil];
    SKAction *animateB = [SKAction animateWithTextures:animatedImages timePerFrame: 0.05 resize:NO restore:NO];
    [self.bowTie runAction:[SKAction repeatActionForever:animateB]];*/

    
}

#pragma mark- checks

-(void)checkInteractables:(NSString *)keyNode{
    
    for(Interactable *interactable in self.interactableArray)
    {
        double playerMidX = CGRectGetMidX(self.player.frame);
        double keyMidX = CGRectGetMidX([self childNodeWithName:keyNode].frame);
    
        if([keyNode isEqualToString:interactable.keyNode] && self.touchDown &&
           (
            ((playerMidX - keyMidX < [self childNodeWithName:@"highCNode"].frame.size.width)&&(playerMidX-keyMidX > -10))
            ||
            ((keyMidX - playerMidX < [self childNodeWithName:@"highCNode"].frame.size.width)&&(keyMidX-playerMidX > -10))
            ))
        {
            NSLog(@"It's happening");
            SKLabelNode *signLabel = (SKLabelNode *)[self childNodeWithName:@"signLabel"];
            signLabel.text = interactable.displayText;
            signLabel.fontColor = [UIColor whiteColor];
            signLabel.alpha = 1.0f;
            signLabel.zPosition = 2.0f;
            SKSpriteNode *signPost = (SKSpriteNode *)[self childNodeWithName:@"signPost"];
            signPost.hidden = NO;
            signPost.alpha = 1.0f;
            signPost.zPosition = 2.0f;
        }

    }
}

-(void)checkResonantMelody{
    for(Enemy *enemy in self.enemyArray){
        BOOL shatter = NO;
        NSUInteger length = enemy.resonantArray.count;
        switch (length) {
            case 1:
                shatter = (([[self.keyPressArray objectAtIndex:0] isEqualToString:[enemy.resonantArray objectAtIndex:0]]) && [self.mode isEqualToString:@"Resonance"]);
                break;
            case 2:
                shatter = (([[self.keyPressArray objectAtIndex:0] isEqualToString:[enemy.resonantArray objectAtIndex:1]]) && ([[self.keyPressArray objectAtIndex:1] isEqualToString:[enemy.resonantArray objectAtIndex:0]]) && [self.mode isEqualToString:@"Resonance"]);
                break;
            case 3:
                shatter = (([[self.keyPressArray objectAtIndex:0] isEqualToString:[enemy.resonantArray objectAtIndex:2]]) && ([[self.keyPressArray objectAtIndex:1] isEqualToString:[enemy.resonantArray objectAtIndex:1]]) && ([[self.keyPressArray objectAtIndex:2] isEqualToString:[enemy.resonantArray objectAtIndex:0]]) && [self.mode isEqualToString:@"Resonance"]);
                break;
            case 4:
            shatter = (([[self.keyPressArray objectAtIndex:0] isEqualToString:[enemy.resonantArray objectAtIndex:3]]) && ([[self.keyPressArray objectAtIndex:1] isEqualToString:[enemy.resonantArray objectAtIndex:2]]) && ([[self.keyPressArray objectAtIndex:2] isEqualToString:[enemy.resonantArray objectAtIndex:1]]) && ([[self.keyPressArray objectAtIndex:3] isEqualToString:[enemy.resonantArray objectAtIndex:0]]) && [self.mode isEqualToString:@"Resonance"]);
                
            
            default:
                break;
        }
        if(shatter)
        {
            NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"shatter" ofType:@"aif"];
            SystemSoundID soundID;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &soundID);
            AudioServicesPlaySystemSound(soundID);
            enemy.hidden = YES;
            SKLabelNode *enemyHealthLabel = (SKLabelNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]];
            enemyHealthLabel.alpha = 1.0f;
            enemyHealthLabel.hidden = YES;
            
           // NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"glassShatter" ofType:@"sks"];
            //SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
            //myParticle.position = self.boss.position;
           // [self addChild:myParticle];
            //ADD A HUGE SHATTERING LABEL HERE
        }
    }
}

-(void)checkRoomTransitions{
    
    SKSpriteNode *rightArrow = (SKSpriteNode *)[self childNodeWithName:@"rightArrow"];
    SKSpriteNode *leftArrow = (SKSpriteNode *)[self childNodeWithName:@"leftArrow"];
    if([self.mode isEqualToString: @"Bag"])
    {
        
        rightArrow.hidden = NO;
        leftArrow.hidden = NO;
        rightArrow.alpha = 1.0f;
        leftArrow.alpha = 1.0f;
        
        if(self.currentRoomNumber == 1){
            
            leftArrow.alpha = 0.0f;
            leftArrow.hidden = YES;
            
        }else if(self.currentRoomNumber == 2){
            
            if([self childNodeWithName:@"enemy1"] && ([self childNodeWithName:@"enemy1"].hidden == NO) && !(self.roomCleared >= 2)){
                rightArrow.alpha = 0.0f;
                rightArrow.hidden = YES;
            }
            
        }else if(self.currentRoomNumber == 3){
            if([self childNodeWithName:@"enemy2"] && ([self childNodeWithName:@"enemy2"].hidden == NO) && !(self.roomCleared >= 3)){
                rightArrow.alpha = 0.0f;
                rightArrow.hidden = YES;
            }
        }else if(self.currentRoomNumber == 4){
            if([self childNodeWithName:@"enemy3"] && ([self childNodeWithName:@"enemy3"].hidden == NO) && !(self.roomCleared >= 4)){
                rightArrow.alpha = 0.0f;
                rightArrow.hidden = YES;
            }
        }
        
    }
    
}


-(void)hideInteractables{
    [self childNodeWithName:@"signLabel"].alpha = 0.0f;
    [self childNodeWithName:@"signLabel"].zPosition = -2.0f;
    [self childNodeWithName:@"signPost"].alpha = 0.0f;
    [self childNodeWithName:@"signPost"].zPosition = -2.0f;
}

-(void)changeModes{
    
    SKSpriteNode *rightArrow = (SKSpriteNode *)[self childNodeWithName:@"rightArrow"];
    SKSpriteNode *leftArrow = (SKSpriteNode *)[self childNodeWithName:@"leftArrow"];
    rightArrow.alpha = 0.0f;
    rightArrow.hidden = YES;
    leftArrow.alpha = 0.0f;
    leftArrow.hidden = YES;

    
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
        [self checkRoomTransitions];
        
        SKAction *fadeAction = [SKAction fadeAlphaTo:0.0f duration:0.5];
        SKAction *moveUp = [SKAction moveToY:bagLabel.frame.origin.y+10 duration:0.5];
        SKAction *fadeUp = [SKAction group:@[moveUp, fadeAction]];
        [bagLabel runAction:fadeUp];
        
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
    if(self.shouldShoot && ![self.mode isEqualToString:@"Bag"] && ![self.mode isEqualToString:@"Resonance"]){
        KeyLaser *keyLaser = [self.keyLasers objectAtIndex:_nextKeyLaser];
        _nextKeyLaser++;
        if (_nextKeyLaser >= self.keyLasers.count) {
            
            _nextKeyLaser = 0;
        }
        
        if(keyLaserDamage < 0.5f){
            keyLaser.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"laserbeam_red.png"]];
        }else{
            keyLaser.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"laserbeam_blue.png"]];

        }
        keyLaser.damage = keyLaserDamage;
        keyLaser.position = CGPointMake(self.player.position.x+keyLaser.size.width/2,self.player.position.y+0);
        keyLaser.hidden = NO;
        [keyLaser removeAllActions];
        
        
        CGPoint location = CGPointMake(self.frame.size.width, self.player.position.y);
        SKAction *laserMoveAction = [SKAction moveByX:self.frame.size.width y:0 duration:0.75f];
        SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
            keyLaser.hidden = YES;
        }];
        
        SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
        
        [keyLaser runAction:moveLaserActionWithDone withKey:@"laserFired"];
    }
}


#pragma mark- combos

-(void)checkCombo{
    if(self.shouldShoot && ![self.mode isEqualToString:@"Bag"]){
        
        if([self.mode isEqualToString: @"Attack"])
        {
            NSArray *combo1 = self.attackArray[0];
            if((self.attackMP >= 1) &&([self.keyPressArray[0] isEqualToString:combo1[2]]) && ([self.keyPressArray[1] isEqualToString:combo1[1]]) && ([self.keyPressArray[2] isEqualToString:combo1[0]])){
                SKSpriteNode *fireball = [SKSpriteNode spriteNodeWithImageNamed:@"orc01.png"];
                fireball.size = CGSizeMake(50, 50);
                fireball.position = CGPointMake(self.player.position.x+fireball.size.width/2,self.player.position.y+0);
                fireball.name = @"fireball";
                [self addChild:fireball];
                SKAction *laserMoveAction = [SKAction moveByX:self.frame.size.width y:0 duration:1.2f];
                SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
                    fireball.hidden = YES;
                }];
                
                SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
                
                [fireball runAction:moveLaserActionWithDone withKey:@"laserFired"];
                if(self.fireballArray.count > 10){
                    [self.fireballArray removeObjectAtIndex:0];
                }
                [self.fireballArray addObject:fireball];
                
                self.attackMP -= 1;
            }
            
            NSArray *combo2 = self.attackArray[1];
            if((self.attackMP >= 2) &&([self.keyPressArray[1] isEqualToString:combo2[2]]) && ([self.keyPressArray[2] isEqualToString:combo2[1]]) && ([self.keyPressArray[3] isEqualToString:combo2[0]]) && !self.flameOn)
               {
                   self.flameOn = YES;
                   SKSpriteNode *flame = [SKSpriteNode spriteNodeWithImageNamed:@"orc01.png"];
                   flame.size = CGSizeMake([self childNodeWithName:@"highCNode"].frame.size.width, 1);
                   flame.position = CGPointMake(CGRectGetMidX([self childNodeWithName:[NSString stringWithFormat:@"%@", self.keyPressArray[0]]].frame), CGRectGetMaxY([self childNodeWithName:@"highCNode"].frame));
                   flame.name = @"flame";
                   [self addChild:flame];
                   SKAction *growAction = [SKAction resizeToHeight:self.frame.size.height duration:0.2f];
                   SKAction *shrinkAction = [SKAction resizeToHeight:0 duration:0.2f];
                   
                   SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
                       flame.hidden = YES;
                       [flame removeFromParent];
                       self.flameOn = NO;
                   }];
                   
                   SKAction *moveLaserActionWithDone = [SKAction sequence:@[growAction, shrinkAction, doneAction]];
                   
                   [flame runAction:moveLaserActionWithDone withKey:@"laserFired"];
                   self.attackMP -= 2;

               }
        }
        if([self.mode isEqualToString: @"Defense"])
        {
            NSArray *combo1 = self.defenseArray[0];
            if((self.defenseMP >= 1) &&([self.keyPressArray[0] isEqualToString:combo1[2]]) && ([self.keyPressArray[1] isEqualToString:combo1[1]]) && ([self.keyPressArray[2] isEqualToString:combo1[0]]))
            {
                if(![self childNodeWithName:@"wall"])
                {
                    SKSpriteNode *wall = [SKSpriteNode spriteNodeWithImageNamed:@"orc01.png"];
                    wall.size = CGSizeMake(50, 50);
                    wall.position = CGPointMake(self.player.position.x+wall.size.width/2,self.player.position.y);
                    wall.name = @"wall";
                    [self addChild:wall];
                    self.defenseMP -= 1;
                }
            }
        }
        if([self.mode isEqualToString: @"Magic"])
        {
            NSArray *combo1 = self.magicArray[0];
            if((self.magicMP >= 1) &&([self.keyPressArray[0] isEqualToString:combo1[2]]) && ([self.keyPressArray[1] isEqualToString:combo1[1]]) && ([self.keyPressArray[2] isEqualToString:combo1[0]]))
            {
                NSLog(@"MAGIC");
                filter->enable(true);
                self.filterInt = 0;
                self.magicMP-= 1;
            
            }
        }
    }
}

-(void)loadCombos{
    
    NSArray *attackCombo0 = @[@"highCNode", @"highDNode", @"highENode"];
    NSArray *attackCombo1 = @[@"highCNode", @"highENode", @"highGNode"];
    self.attackArray = @[attackCombo0, attackCombo1];
    
    NSArray *defenseCombo0 = @[@"highENode", @"highDNode", @"highCNode"];
    self.defenseArray = @[defenseCombo0];
    
    NSArray *magicCombo0 =  @[@"highENode", @"highFNode", @"highGNode"];
    self.magicArray = @[magicCombo0];
}


#pragma mark- update

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // Stop view from moving if a sign is present
   /* if(([[self childNodeWithName:@"rightEdge"] intersectsNode:[self childNodeWithName:@"sign1"]] ) || ([[self childNodeWithName:@"rightEdge"] intersectsNode:[self childNodeWithName:@"sign2"]] ) ){
        self.shouldMove = NO;
    }*/

    //Watch the enemy's movement
    for(SKSpriteNode *enemy in self.moveablesArray){
        if([enemy intersectsNode:[self childNodeWithName:@"player"]]&&!enemy.hidden&&(enemy.zPosition==1.0f))
        {
            self.playerHealth--;
            enemy.hidden = YES;
            [self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]].hidden = YES;
        }else if([[self childNodeWithName:@"rightEdge"] intersectsNode:enemy])
        {
            SKAction *moveEnemy = [SKAction moveToX:CGRectGetMidX([self childNodeWithName:@"highGNode"].frame) duration:0.2f];
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
                if(!keyLaser.hidden){
                    enemy.health -= keyLaser.damage;
                    keyLaser.hidden = YES;

                }
                
            }else if([keyLaser intersectsNode:[self childNodeWithName:@"rightEdge"]])
            {
                if(!keyLaser.hidden){
                    keyLaser.hidden = YES;
                }
            }

        }
        
        if([[self childNodeWithName:@"flame"] intersectsNode:enemy])
        {
            enemy.health -= 1.7;
        }
        
        for (SKSpriteNode *fireball in self.fireballArray)
        {
            if (fireball.hidden) {
                continue;
            }
            
            if([fireball intersectsNode:enemy])
            {
                if(!fireball.hidden){
                    enemy.health -= 30;
                    fireball.hidden = YES;
                }
            }
        }
        
        for (EnemyShot *shot in self.enemyShotArray)
        {
            if (shot.hidden) {
                continue;
            }
            
            if([shot intersectsNode:self.player])
            {
                if(!shot.hidden){
                    self.playerHealth -= shot.damage;
                    shot.hidden = YES;
                }
            }else if([self childNodeWithName:@"wall"] && [shot intersectsNode:[self childNodeWithName:@"wall"]])
            {
                if(!shot.hidden){
                    SKSpriteNode *wall = (SKSpriteNode *)[self childNodeWithName:@"wall"];
                    if(shot.damage <= 0.25f){
                        shot.hidden = YES;
                        wall.hidden = YES;
                        [wall removeFromParent];
                    }else{
                        shot.damage -= 0.25f;
                        wall.hidden = YES;
                        [wall removeFromParent];
                    }
                }
            }
        }


        if(enemy.health > 0){
            SKSpriteNode *enemyHealthLabel = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]];
            //enemyHealthLabel.text = [NSString stringWithFormat:@"%.2f", enemy.health];
            enemyHealthLabel.size = CGSizeMake(enemy.health/enemy.healthMax * 50, 10);
            enemyHealthLabel.position = CGPointMake(CGRectGetMidX(enemy.frame) - enemyHealthLabel.size.width/2, CGRectGetMaxY(enemy.frame) + enemyHealthLabel.size.height/2 + 5);
        }else{
            SKSpriteNode *enemyHealthLabel = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]];
            enemyHealthLabel.alpha = 1.0f;
            enemyHealthLabel.hidden = YES;
        }
        if(enemy.health <= 0)
        {
            enemy.hidden = YES;
            [self childNodeWithName:[NSString stringWithFormat:@"%@Label", enemy.name]].hidden = YES;
            [self.enemyArray removeObjectAtIndex:enemy.arrayPosition];
        }
    }

    //Update the touch held length && check interactables
    if(self.touchDown){
        self.touchLength = CACurrentMediaTime() - self.touchBegan;
        if(self.currentKeyDown){
          [self checkInteractables:self.currentKeyDown];
        }
    }else{
        self.touchLength = 0;
    }
    
    //Update Health & MP Labels
    self.healthBar.size = CGSizeMake(self.playerHealth/self.playerHealthMax * 100, 10);
    self.playerHealthLabel.text = [NSString stringWithFormat:@"Player Health: %.2f", self.playerHealth];
    self.attackMPLabel.text = [NSString stringWithFormat:@"Adagio MP: %.2f", self.attackMP];
    self.defenseMPLabel.text = [NSString stringWithFormat:@"Brio MP: %.2f", self.defenseMP];
    
    self.lastBeat = playerBack->msElapsedSinceLastBeat;
    
}


#pragma mark- tempo methods

-(void)beat{

    if(self.firstBeat){
        //[backgroundChannel play:backgroundBuffer loop:YES];

        pthread_mutex_lock(&mutex);
            playerBack->play(YES);
        pthread_mutex_unlock(&mutex);
    }
    
    if(self.filterInt < 7){
        self.filterInt++;
        if(self.filterInt <= 3){
            filter->setResonantParameters(floatToFrequency(0.4), 0.1f);
        }else{
            filter->setResonantParameters(floatToFrequency(0.4 + (self.filterInt/10.0f - 0.3)), 0.1f);
        }
    }else{
        filter->enable(false);
    }
    
    self.beatTime = CACurrentMediaTime();
    self.beatCount++;
    if(self.beatCount%4 == 0){
        self.measureCount++;
        SKSpriteNode *background = (SKSpriteNode*)[self childNodeWithName:@"background"];
        SKSpriteNode *background2 = (SKSpriteNode*)[self childNodeWithName:@"background2"];
        
        //SKAction *moveBackground = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
        if(self.shouldMove){
            //[background runAction:moveBackground];
           // [background2 runAction:moveBackground];
            //background.position = CGPointMake(background.position.x-([[UIScreen mainScreen] bounds].size.width/12), background.position.y);
            //background2.position = CGPointMake(background2.position.x-([[UIScreen mainScreen] bounds].size.width/12), background2.position.y);
            [self moveEnemies];
        }
        if(self.bowTieIncrement < 3)
        {
            self.bowTieIncrement++;
        }
    }
    
    
    if(self.beatCount%8 == 0){
        [self enemyAttack];
    }
    
    if(self.beatCount%16 == 0){
        if(self.attackMP < self.attackMPMax){
            self.attackMP++;
        }
        if(self.defenseMP < self.defenseMPMax){
            self.defenseMP++;
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
        float moveDuration = 0.005*distance;
        
        SKAction *movePlayer = [SKAction moveTo:CGPointMake(CGRectGetMidX(keySprite.frame), CGRectGetMidY(self.frame)-5) duration:moveDuration];
        
        [self.player runAction:movePlayer withKey:@"movePlayer"];
    }
    
}

-(void)getPlayerCurrentKey{
    for(SKSpriteNode *key in self.keyArray){
        if((self.player.position.x > CGRectGetMinX(key.frame))&&(self.player.position.x < CGRectGetMaxX(key.frame))){
            self.currentPlayerKey = key.name;
        }
    }
}

#pragma mark- Enemy Methods
-(void)moveEnemies{
    
    SKAction *moveAngle = [[SKAction alloc] init];
    
    switch (self.enemyMoveInt) {
        case 1:
        {
            self.enemyMoveInt++;
            moveAngle = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
            break;
        }
        case 2:
        {
            self.enemyMoveInt++;
            moveAngle = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
            break;
        }
        case 3:
        {
            self.enemyMoveInt++;
            moveAngle = [SKAction moveByX:([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
            break;
        }
        case 4:
        {
            self.enemyMoveInt = 1;
            moveAngle = [SKAction moveByX:([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
            break;
        }
        default:
            break;
    }
    
    SKAction *moveScooter = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0.2f];
    
    
    for(Enemy *enemy in self.moveablesArray){

        if([enemy.type isEqualToString:@"scooter"]){
            [enemy runAction:moveScooter];
        }else if([enemy.type isEqualToString:@"angle"]){
            [enemy runAction:moveAngle];
        }
        
    }
    
}

-(void)enemyAttack{
    for(Enemy *enemy in self.enemyArray)
    {
        if([enemy.type isEqualToString:@"angle"])
        {
            EnemyShot *spike = [EnemyShot spriteNodeWithImageNamed:@"angleShot.png"];
            spike.size = CGSizeMake(15, 10);
            spike.position = CGPointMake(enemy.position.x-spike.size.width/2,enemy.position.y);
            spike.name = @"angle";
            [self addChild:spike];
            SKAction *laserMoveAction = [SKAction moveByX:-self.frame.size.width y:0 duration:5.0f];
            SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
                spike.hidden = YES;
            }];
            spike.damage = 0.25f;
            
            SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
            
            [spike runAction:moveLaserActionWithDone withKey:@"laserFired"];
            [self.enemyShotArray addObject:spike];
            
        }
        
        
    }
}

#pragma mark - keyboard key nodes

-(SKSpriteNode *)lowCNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"cKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowCNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    
    return keyNode;
}

- (SKSpriteNode *)lowDNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"dKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(1*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowDNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)lowENode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"eKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(2*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowENode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}


-(SKSpriteNode *)lowFNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"fFKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake([[UIScreen mainScreen] bounds].size.width/12, [[UIScreen mainScreen] bounds].size.height/2.25)];
    keyNode.position = CGPointMake(3*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowFNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

-(SKSpriteNode *)lowGNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"gKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake([[UIScreen mainScreen] bounds].size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(4*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5,(self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowGNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highANode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"aKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(5*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highANode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highBNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"bKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(6*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5,(self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highBNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highCNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"cKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(7*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highCNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highDNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"dKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(8*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highDNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highENode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"eKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(9*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highENode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

- (SKSpriteNode *)highFNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"fFKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(10*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highFNode";//how the node is identified later
    keyNode.zPosition = 1.0;
    return keyNode;
}

-(SKSpriteNode *)highGNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"gKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(11*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highGNode";//how the node is identified later
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
        SKAction *moveToPositions = [SKAction moveToX:CGRectGetMidX([self childNodeWithName:@"lowENode"].frame) duration:2.0f];
        //SKAction *cutsceneSequence = [SKAction sequence:@[moveToPositions, [self performSelector:@selector(endCutscene) withObject:nil afterDelay:2.0f]]];
        SKAction *moveBowTie = [SKAction moveToX:CGRectGetMidX([self childNodeWithName:@"lowDNode"].frame) duration:2.0f];
        [self animateBowTie];
        [self.bowTie runAction:moveBowTie];
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

#pragma mark- SuperPowered

void playerEventCallbackBack(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        Level1 *self = (__bridge Level1 *)clientData;
        self->playerBack->setBpm(125.0f);
        self->playerBack->setFirstBeatMs(0);
        self->playerBack->setPosition(self->playerBack->firstBeatMs, false, false);
    };
}

void playerEventCallbackC(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        Level1 *self = (__bridge Level1 *)clientData;
        self->playerC->setBpm(125.0f);
        self->playerC->setFirstBeatMs(0);
        self->playerC->setPosition(self->playerC->firstBeatMs, false, false);
    };
}

void playerEventCallbackD(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        Level1 *self = (__bridge Level1 *)clientData;
        self->playerD->setBpm(125.0f);
        self->playerD->setFirstBeatMs(0);
        self->playerD->setPosition(self->playerD->firstBeatMs, false, false);
    };
}

void playerEventCallbackE(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        Level1 *self = (__bridge Level1 *)clientData;
        self->playerE->setBpm(125.0f);
        self->playerE->setFirstBeatMs(0);
        self->playerE->setPosition(self->playerE->firstBeatMs, false, false);
    };
}

void playerEventCallbackF(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        Level1 *self = (__bridge Level1 *)clientData;
        self->playerF->setBpm(125.0f);
        self->playerF->setFirstBeatMs(0);
        self->playerF->setPosition(self->playerF->firstBeatMs, false, false);
    };
}

void playerEventCallbackG(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        Level1 *self = (__bridge Level1 *)clientData;
        self->playerG->setBpm(125.0f);
        self->playerG->setFirstBeatMs(0);
        self->playerG->setPosition(self->playerG->firstBeatMs, false, false);
    };
}

- (void)dealloc {
    delete playerBack;
    delete playerC;
    delete playerD;
    delete playerE;
    delete playerF;
    delete playerG;
    delete mixer;
    free(stereoBuffer);
    pthread_mutex_destroy(&mutex);
#if !__has_feature(objc_arc)
    [output release];
    [super dealloc];
#endif
}

- (void)interruptionEnded { // If a player plays Apple Lossless audio files, then we need this. Otherwise unnecessary.
    playerBack->onMediaserverInterrupt();
    playerC->onMediaserverInterrupt();
    playerD->onMediaserverInterrupt();
    playerE->onMediaserverInterrupt();
    playerF->onMediaserverInterrupt();
    playerG->onMediaserverInterrupt();
    
}

// This is where the Superpowered magic happens.
- (bool)audioProcessingCallback:(float **)buffers inputChannels:(unsigned int)inputChannels outputChannels:(unsigned int)outputChannels numberOfSamples:(unsigned int)numberOfSamples samplerate:(unsigned int)samplerate hostTime:(UInt64)hostTime {
    if (samplerate != lastSamplerate) { // Has samplerate changed?
        lastSamplerate = samplerate;
        playerBack->setSamplerate(samplerate);
        playerC->setSamplerate(samplerate);
        playerD->setSamplerate(samplerate);
        playerE->setSamplerate(samplerate);
        playerF->setSamplerate(samplerate);
        playerG->setSamplerate(samplerate);
        roll->setSamplerate(samplerate);
        filter->setSamplerate(samplerate);
        flanger->setSamplerate(samplerate);
    };
    
    pthread_mutex_lock(&mutex);
    
    bool masterIsA = YES;
    float masterBpm = 125.0f; // Players will sync to this tempo.
    double msElapsedSinceLastBeatA = playerBack->msElapsedSinceLastBeat; // When playerB needs it, playerA has already stepped this value, so save it now.
    
    bool silence = !playerBack->process(stereoBuffer, false, numberOfSamples, volBack, masterBpm, playerC->msElapsedSinceLastBeat);
    if (playerC->process(stereoBuffer, !silence, numberOfSamples, volC, masterBpm, msElapsedSinceLastBeatA)) silence = false;
    
   // bool silence2 = !playerBack->process(stereoBuffer, false, numberOfSamples, volBack, masterBpm, playerD->msElapsedSinceLastBeat);
    //if (playerD->process(stereoBuffer, !silence, numberOfSamples, volD, masterBpm, msElapsedSinceLastBeatA)) silence2 = false;
    
    playerD->process(stereoBuffer, !silence, numberOfSamples, volD, masterBpm, msElapsedSinceLastBeatA);
    playerE->process(stereoBuffer, !silence, numberOfSamples, volD, masterBpm, msElapsedSinceLastBeatA);
    playerF->process(stereoBuffer, !silence, numberOfSamples, volD, masterBpm, msElapsedSinceLastBeatA);
    playerG->process(stereoBuffer, !silence, numberOfSamples, volD, masterBpm, msElapsedSinceLastBeatA);
    
    roll->bpm = flanger->bpm = masterBpm; // Syncing fx is one line.
    
    if (roll->process(silence ? NULL : stereoBuffer, stereoBuffer, numberOfSamples) && silence) silence = false;
    if (!silence) {
        filter->process(stereoBuffer, stereoBuffer, numberOfSamples);
        flanger->process(stereoBuffer, stereoBuffer, numberOfSamples);
    };
   // self->playerB->waitForNextBeatWithBeatSync = YES;
    pthread_mutex_unlock(&mutex);
    
    // The stereoBuffer is ready now, let's put the finished audio into the requested buffers.
    /*float *mixerInputs[4] = { stereoBuffer, NULL, NULL, NULL };
    float mixerInputLevels[8] = { 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
    float mixerOutputLevels[2] = { 1.0f, 1.0f };
    if (!silence) mixer->process(mixerInputs, buffers, mixerInputLevels, mixerOutputLevels, NULL, NULL, numberOfSamples);*/
    
    float *mixerInputs[4] = { stereoBuffer, NULL, NULL, NULL };
    float mixerInputLevels[8] = { 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
    float mixerOutputLevels[2] = { 1.0f, 1.0f };

    if (!silence) mixer->process(mixerInputs, buffers, mixerInputLevels, mixerOutputLevels, NULL, NULL, numberOfSamples);
    
    return !silence;
}

static inline float floatToFrequency(float value) {
    static const float min = logf(20.0f) / logf(10.0f);
    static const float max = logf(20000.0f) / logf(10.0f);
    static const float range = max - min;
    return powf(10.0f, value * range + min);
}

#pragma mark- Room Loading

-(void)loadNextRoom:(int)roomNumber{
    [self removeChildrenInArray:self.enemyArray];
    [self removeChildrenInArray:self.interactableArray];
    self.enemyArray = [NSArray arrayWithObjects: nil];
    self.interactableArray = [NSArray arrayWithObjects: nil];
    for(SKLabelNode *enemyHealthLabel in self.enemyHealthLabelArray){
        enemyHealthLabel.hidden = YES;
    }
    if (!self.enemyHealthLabelArray) {
        self.enemyHealthLabelArray = [[NSMutableArray alloc] init];
    }else{
        [self removeChildrenInArray:self.enemyHealthLabelArray];
        [self.enemyHealthLabelArray removeAllObjects];
    }

    
    SKSpriteNode *rightArrow = (SKSpriteNode *)[self childNodeWithName:@"rightArrow"];
    SKSpriteNode *leftArrow = (SKSpriteNode *)[self childNodeWithName:@"leftArrow"];
    leftArrow.alpha = 0.0f;
    leftArrow.hidden = YES;
    rightArrow.alpha = 0.0f;
    rightArrow.hidden = YES;
    
    self.shouldShoot = NO;
    self.shouldMove = NO;
    self.shouldPlayerMove = NO;
    self.currentRoomNumber++;
    
    if([self.player actionForKey:@"movePlayer"]){
        [self.player removeActionForKey:@"movePlayer"];
    }
    
    SKSpriteNode *background = (SKSpriteNode *)[self childNodeWithName:@"background"];
    SKSpriteNode *background2 = (SKSpriteNode *)[self childNodeWithName:@"background2"];
    SKAction *movePlayerRoom = [SKAction moveToX:CGRectGetMidX([self childNodeWithName:@"lowENode"].frame) duration:1.0f];
    SKAction *moveBackground = [SKAction moveByX:-(self.view.frame.size.width) y:0 duration:1.0f];
    [self.player runAction:movePlayerRoom completion:^{
        self.shouldMove = YES;
        self.shouldShoot = YES;
        self.shouldPlayerMove = YES;
    }];
    [background runAction:moveBackground completion:^{
        [self loadRoom:self.currentRoomNumber];
        background.position = CGPointMake(0,0);
    }];
    
    background2.position = CGPointMake(background2.size.width -3, background2.position.y);
    [background2 runAction:moveBackground];
    
}

-(void)loadPreviousRoom:(int)roomNumber{
    [self removeChildrenInArray:self.enemyArray];
    [self removeChildrenInArray:self.interactableArray];
    self.enemyArray = [NSMutableArray arrayWithObjects: nil];
    self.interactableArray = [NSArray arrayWithObjects: nil];
    for(SKLabelNode *enemyHealthLabel in self.enemyHealthLabelArray){
        enemyHealthLabel.hidden = YES;
    }
    if (!self.enemyHealthLabelArray) {
        self.enemyHealthLabelArray = [[NSMutableArray alloc] init];
    }else{
        [self removeChildrenInArray:self.enemyHealthLabelArray];
        [self.enemyHealthLabelArray removeAllObjects];
    }

    
    SKSpriteNode *rightArrow = (SKSpriteNode *)[self childNodeWithName:@"rightArrow"];
    SKSpriteNode *leftArrow = (SKSpriteNode *)[self childNodeWithName:@"leftArrow"];
    leftArrow.alpha = 0.0f;
    leftArrow.hidden = YES;
    rightArrow.alpha = 0.0f;
    rightArrow.hidden = YES;
    
    self.shouldShoot = NO;
    self.shouldMove = NO;
    self.shouldPlayerMove = NO;
    self.currentRoomNumber--;
    
    if([self.player actionForKey:@"movePlayer"]){
        [self.player removeActionForKey:@"movePlayer"];
    }
    
    SKSpriteNode *background = (SKSpriteNode *)[self childNodeWithName:@"background"];
    SKSpriteNode *background2 = (SKSpriteNode *)[self childNodeWithName:@"background2"];
    SKAction *movePlayerRoom = [SKAction moveToX:CGRectGetMidX([self childNodeWithName:@"lowENode"].frame) duration:1.0f];
    SKAction *moveBackground = [SKAction moveByX:(self.view.frame.size.width) y:0 duration:1.0f];
    [self.player runAction:movePlayerRoom completion:^{
        self.shouldMove = YES;
        self.shouldShoot = YES;
        self.shouldPlayerMove = YES;
    }];
    [background runAction:moveBackground completion:^{
        [self loadRoom:self.currentRoomNumber];
        background.position = CGPointMake(0,0);
    }];
    
    background2.position = CGPointMake(-background2.size.width+ 3, background2.position.y);
    [background2 runAction:moveBackground];
    
}

-(void)loadRoom:(int)roomNumber{
    
    if(self.currentRoomNumber == 1){
        
        Interactable *sign1 = [Interactable spriteNodeWithImageNamed:@"signPost.jpg"];
        sign1.name = @"sign1";
        sign1.displayText = @"Welcome to the Pink Forest";
        sign1.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highENode"].frame), CGRectGetMidY(self.frame));
        sign1.keyNode = @"highDNode";
        sign1.size = CGSizeMake(30,30);
        sign1.zPosition = 0.0f;
        [self addChild:sign1];
        
        self.interactableArray = [NSArray arrayWithObjects:sign1, nil];
        
        
    }else if(self.currentRoomNumber == 2){
        if(self.roomCleared < 2){
            self.roomCleared = 1;
        }
        
        Interactable *sign2 = [Interactable spriteNodeWithImageNamed:@"signPost.jpg"];
        sign2.name = @"sign2";
        sign2.displayText = @"WATCH OUT FOR THE ORCS!";
        sign2.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highDNode"].frame),
        CGRectGetMidY(self.frame));
        sign2.keyNode = @"highCNode";
        sign2.size = CGSizeMake(30,30);
        sign2.zPosition = 0.0f;
        [self addChild:sign2];
        self.interactableArray = [NSArray arrayWithObjects:sign2, nil];
        
        Enemy *enemy1 = [Enemy spriteNodeWithImageNamed:@"scooter.png"];
        enemy1.name = @"enemy1";
        enemy1.size = CGSizeMake(50,50);
        enemy1.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highGNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highGNode"].frame) + enemy1.size.height/2 + 10);
        enemy1.zPosition = 1.0f;
        enemy1.health = 100;
        enemy1.healthMax = 100;
        enemy1.hidden = NO;
        enemy1.type = @"scooter";
        enemy1.resonantArray = @[@"highANode", @"highBNode", @"highCNode", @"highDNode"];
        [self addChild:enemy1];
        self.enemyArray = [NSMutableArray arrayWithObjects:enemy1, nil];
        enemy1.arrayPosition = 0;
        self.moveablesArray = [NSArray arrayWithObjects:enemy1, nil];
        
    }else if(self.currentRoomNumber == 3){
        if(self.roomCleared < 2)
        {
            self.roomCleared = 2;
        }
        
        self.enemyMoveInt = 1;
        
        Enemy *enemy2 = [Enemy spriteNodeWithImageNamed:@"angle.png"];
        enemy2.name = @"enemy2";
        enemy2.size = CGSizeMake(50,50);
        enemy2.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highDNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highDNode"].frame) + enemy2.frame.size.height/2.3);
        enemy2.zPosition = 1.0f;
        enemy2.health = 150;
        enemy2.healthMax = 150;
        enemy2.hidden = NO;
        enemy2.type = @"angle";
        enemy2.resonantArray = @[@"highANode", @"highBNode", @"highCNode", @"highDNode"];
        [self addChild:enemy2];
        self.enemyArray = [NSMutableArray arrayWithObjects:enemy2, nil];
        enemy2.arrayPosition = 0;
        self.moveablesArray = [NSArray arrayWithObjects:enemy2, nil];
        
    }else if(self.currentRoomNumber == 4){
        if(self.roomCleared < 3){
            self.roomCleared = 3;
        }
        
        Enemy *enemy3 = [Enemy spriteNodeWithImageNamed:@"evilBowtie.png"];
        enemy3.name = @"enemy3";
        enemy3.size = CGSizeMake(40,40);
        enemy3.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highDNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highDNode"].frame) + enemy3.frame.size.height/2.3 + 10);
        enemy3.zPosition = 1.0f;
        enemy3.health = 1000;
        enemy3.healthMax = 1000;
        enemy3.hidden = NO;
        enemy3.type = @"bowTie";
        enemy3.resonantArray = @[@"highANode", @"highBNode", @"highCNode"];
        [self addChild:enemy3];
        self.enemyArray = [NSMutableArray arrayWithObjects:enemy3, nil];
        enemy3.arrayPosition = 0;
        self.moveablesArray = [NSArray arrayWithObjects:enemy3, nil];
        SKAction *moveUp = [SKAction moveByX:0 y:3 duration:1.0f];
        SKAction *moveDown = [SKAction moveByX:0 y:-3 duration:1.0f];
        SKAction *floatAction = [SKAction sequence:@[moveUp, moveDown]];
        [enemy3 runAction:[SKAction repeatActionForever:floatAction]];
    }
    
    for(Enemy *enemy in self.enemyArray){
        if(enemy.health > 0){
            /*SKLabelNode *enemyHealthLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
            enemyHealthLabel.text = [NSString stringWithFormat:@"%.2f", enemy.health];
            enemyHealthLabel.position = CGPointMake(CGRectGetMidX(enemy.frame), enemy.position.y + 30);
            enemyHealthLabel.color = [SKColor redColor];
            enemyHealthLabel.fontColor = [SKColor redColor];
            enemyHealthLabel.name = [NSString stringWithFormat:@"%@Label", enemy.name];
            enemyHealthLabel.fontSize = 20;*/
            SKSpriteNode *enemyHealthLabel = [SKSpriteNode spriteNodeWithImageNamed:@"loader_bar_red_fill.png"];
            enemyHealthLabel.name = [NSString stringWithFormat:@"%@Label", enemy.name];
            enemyHealthLabel.size = CGSizeMake(50, 10);
            enemyHealthLabel.position = CGPointMake(CGRectGetMidX(enemy.frame) - enemyHealthLabel.size.width/2, CGRectGetMaxY(enemy.frame) + enemyHealthLabel.size.height/2 + 5);
            enemyHealthLabel.anchorPoint = CGPointMake(0.0, 0.5);
            [self addChild:enemyHealthLabel];
            [self.enemyHealthLabelArray addObject:enemyHealthLabel];
            
        }
    }
    [self checkRoomTransitions];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

@end
