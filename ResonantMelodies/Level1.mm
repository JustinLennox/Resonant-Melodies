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

#define aKeySound @"Level1A.aif"
#define bKeySound @"Level1B.aif"
#define cKeySound @"Level1C.aif"
#define dKeySound @"Level1D.aif"
#define eKeySound @"Level1E.aif"
#define fKeySound @"Level1F.aif"
#define gKeySound @"Level1G.aif"

#define bowtieSound @"Crash-Cymbal-2.wav"

#define HEADROOM_DECIBEL 3.0f
static const float headroom = powf(10.0f, -HEADROOM_DECIBEL * 0.025);

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

@implementation Level1{
    
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
    
    NSLog(@"Before %@", NSStringFromCGSize(self.size));
    self.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    NSLog(@"After %@", NSStringFromCGSize(self.size));

#pragma mark- set up camera
   // self.anchorPoint = CGPointMake (0,0);
    SKNode *myWorld = [SKNode node];
    [self addChild:myWorld];
    SKNode *camera = [SKNode node];
    camera.name = @"camera";
    [myWorld addChild:camera];
    
    
    self.shouldMove = YES;
    self.view.multipleTouchEnabled = YES;
    
#pragma mark- set up background
    
    SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"Forest.png"];
    backgroundImage.name = @"background";
    backgroundImage.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    backgroundImage.position = CGPointMake(0,0);
    backgroundImage.anchorPoint = CGPointZero;
    backgroundImage.zPosition = -1.0f;
    [self addChild:backgroundImage];
    
    SKSpriteNode *backgroundImage2 = [SKSpriteNode spriteNodeWithImageNamed:@"Forest.png"];
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
//    lAKeyBuffer = [[OpenALManager sharedInstance] bufferFromFile:lAKeySound];
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
    
    channel.volume = 0.8f;
    
    
#pragma mark- add keys
    self.yPositionIncrement = [[UIScreen mainScreen] bounds].size.width/12;
    
    [self addChild: [self lowCNode]];
    [self addKeyNameLabel:@"lowCNode"];
    [self addChild: [self lowDNode]];
    [self addKeyNameLabel:@"lowDNode"];
    [self addChild: [self lowENode]];
    [self addKeyNameLabel:@"lowENode"];
    [self addChild: [self lowFNode]];
    [self addKeyNameLabel:@"lowFNode"];
    [self addChild: [self lowGNode]];
    [self addKeyNameLabel:@"lowGNode"];
    [self addChild: [self highANode]];
    [self addKeyNameLabel:@"highANode"];
    [self addChild: [self highBNode]];
    [self addKeyNameLabel:@"highBNode"];
    [self addChild: [self highCNode]];
    [self addKeyNameLabel:@"highCNode"];
    [self addChild: [self highDNode]];
    [self addKeyNameLabel:@"highDNode"];
    [self addChild: [self highENode]];
    [self addKeyNameLabel:@"highENode"];
    [self addChild: [self highFNode]];
    [self addKeyNameLabel:@"highFNode"];
    [self addChild: [self highGNode]];
    [self addKeyNameLabel:@"highGNode"];

    
    self.keyArray = @[[self childNodeWithName:@"lowCNode"], [self childNodeWithName:@"lowDNode"], [self childNodeWithName:@"lowENode"], [self childNodeWithName:@"lowFNode"], [self childNodeWithName:@"lowGNode"], [self childNodeWithName:@"highANode"], [self childNodeWithName:@"highBNode"], [self childNodeWithName:@"highCNode"], [self childNodeWithName:@"highDNode"], [self childNodeWithName:@"highENode"], [self childNodeWithName:@"highFNode"], [self childNodeWithName:@"highGNode"]];
    
#pragma mark- set up player
    self.player = [[Hero alloc] init];
    self.player.position = CGPointMake(-self.player.size.width, CGRectGetMaxY([self childNodeWithName:@"lowENode"].frame) + 31);
    self.player.zPosition = [self childNodeWithName:@"lowENode"].zPosition + 0.1;
    [self addChild:self.player];
    
    self.bowTie = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"BowTie1.png"] size:CGSizeMake(40, 40)];
    self.bowTie.position = CGPointMake(CGRectGetMinX(self.player.frame) - 10, CGRectGetMaxY(self.player.frame));
    self.bowTie.name = @"bowTie";
    [self addChild:self.bowTie];
    
    
#pragma  mark- MP

    float barAlpha = 0.5f;
    SKSpriteNode *fireBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:(231.0f/255.0f) green:(76.0f/255.0f) blue:(60.0f/255.0f) alpha:1.0f] size:[self childNodeWithName:@"highANode"].frame.size];
    fireBar.zPosition = [self childNodeWithName:@"lowCNode"].zPosition - 0.1;
    fireBar.position = CGPointMake([self childNodeWithName:@"lowCNode"].position.x,[self childNodeWithName:@"lowCNode"].position.y  - fireBar.frame.size.height/2.0f);
    fireBar.name = @"lowCNodeMPBAR";
    fireBar.alpha = barAlpha;
    fireBar.anchorPoint = CGPointMake(0.5, 0);
    [self addChild:fireBar];
    
    SKSpriteNode *windBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:(236.0f/255.0f) green:(240.0f/255.0f) blue:(241.0f/255.0f) alpha:1.0f] size:[self childNodeWithName:@"highANode"].frame.size];
    windBar.zPosition = [self childNodeWithName:@"lowDNode"].zPosition - 0.1;
    windBar.position = CGPointMake([self childNodeWithName:@"lowDNode"].position.x,[self childNodeWithName:@"lowDNode"].position.y  - fireBar.frame.size.height/2.0f);
    windBar.name = @"lowDNodeMPBAR";
    windBar.alpha = barAlpha;
    windBar.anchorPoint = CGPointMake(0.5, 0);
    [self addChild:windBar];
    
    SKSpriteNode *waterBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:(52.0f/255.0f) green:(152.0f/255.0f) blue:(219.0f/255.0f) alpha:1.0f] size:[self childNodeWithName:@"highANode"].frame.size];
    waterBar.zPosition = [self childNodeWithName:@"lowENode"].zPosition - 0.1;
    waterBar.position = CGPointMake([self childNodeWithName:@"lowENode"].position.x,[self childNodeWithName:@"lowENode"].position.y  - fireBar.frame.size.height/2.0f);
    waterBar.name = @"lowENodeMPBAR";
    waterBar.alpha = barAlpha;
    waterBar.anchorPoint = CGPointMake(0.5, 0);
    [self addChild:waterBar];
    
    SKSpriteNode *earthBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:(46.0f/255.0f) green:(204.0f/255.0f) blue:(113.0f/255.0f) alpha:1.0f] size:[self childNodeWithName:@"highANode"].frame.size];
    earthBar.zPosition = [self childNodeWithName:@"lowFNode"].zPosition - 0.1;
    earthBar.position = CGPointMake([self childNodeWithName:@"lowFNode"].position.x,[self childNodeWithName:@"lowFNode"].position.y  - fireBar.frame.size.height/2.0f);
    earthBar.name = @"lowFNodeMPBAR";
    earthBar.anchorPoint = CGPointMake(0.5, 0);
    earthBar.alpha = barAlpha;
    [self addChild:earthBar];
    
    SKSpriteNode *musicBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:(155.0f/255.0f) green:(89.0f/255.0f) blue:(182.0f/255.0f) alpha:1.0f] size:[self childNodeWithName:@"highANode"].frame.size];
    musicBar.zPosition = [self childNodeWithName:@"lowGNode"].zPosition - 0.1;
    musicBar.position = CGPointMake([self childNodeWithName:@"lowGNode"].position.x,[self childNodeWithName:@"lowGNode"].position.y  - fireBar.frame.size.height/2.0f);
    musicBar.name = @"lowGNodeMPBAR";
    musicBar.alpha = barAlpha;
    musicBar.anchorPoint = CGPointMake(0.5, 0);
    [self addChild:musicBar];
    
    
#pragma mark- set tempo
    
    self.BPM = 125;
        
    //Start rhythm
    self.firstBeat = YES;
//    NSTimer *beat = [NSTimer scheduledTimerWithTimeInterval:(60/self.BPM) target:self selector:@selector(beat) userInfo:nil repeats:YES];
    self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
#pragma mark- add lasers
    self.keyLasers = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30; ++i) {
        KeyLaser *keyLaser = [KeyLaser spriteNodeWithImageNamed:@"note1.png"];
        keyLaser.size = CGSizeMake(16, 27);
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
    
    self.playerHealthLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.playerHealthLabel.name = @"playerHealthLabel";
    self.playerHealthLabel.text = @"Player Health: 10.0";
    self.playerHealthLabel.fontSize = 20.0f;
    self.playerHealthLabel.zPosition =1.0f;
    self.playerHealthLabel.position = CGPointMake(self.frame.size.width*0.50, self.frame.size.height*0.9);
    self.playerHealthLabel.alpha = 0.0f;
    self.playerHealthLabel.fontColor = [SKColor greenColor];
    [self addChild:self.playerHealthLabel];
    

    self.healthBarBack = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar_health.png"];
    self.healthBarBack.size = CGSizeMake(200, 60);
    self.healthBarBack.position = CGPointMake(10, self.frame.size.height - self.healthBarBack.size.height - 10);
    [self addChild:self.healthBarBack];
    self.healthBarBack.anchorPoint = CGPointMake(0, 0);
    
    self.healthBarFill = [SKSpriteNode spriteNodeWithImageNamed:@"loader_bar_red_fill.png"];
    self.healthBarFill.size = CGSizeMake(self.healthBarBack.size.width * (447.00f/762.00f), self.healthBarBack.size.height * (47.00f/252.00f));
    [self.healthBarBack addChild:self.healthBarFill];
    self.healthBarFill.position = CGPointMake(((self.healthBarBack.size.width * (265.00f/762.00f))), (self.healthBarBack.size.height * (132.00f/252.00f)));
    self.healthBarFillMaxWidth = self.healthBarFill.size.width;
    self.healthBarFill.anchorPoint = CGPointMake(0, 0.5);
    
    self.mpBarBack = [SKSpriteNode spriteNodeWithImageNamed:@"status_barpower"];
    self.mpBarBack.size = CGSizeMake(150, 40);
    self.mpBarBack.position = CGPointMake(self.healthBarBack.position.x + self.healthBarBack.size.width + 20, self.frame.size.height - self.healthBarBack.size.height/2 - self.mpBarBack.size.height/2 - 10 );

    [self addChild:self.mpBarBack];
    self.mpBarBack.anchorPoint = CGPointMake(0, 0);
    
    self.mpBarFill = [SKSpriteNode spriteNodeWithImageNamed:@"loader_bar_green_fill.png"];
    self.mpBarFill.size = CGSizeMake(self.mpBarBack.size.width * (447.00f/762.00f), self.mpBarBack.size.height * (47.00f/252.00f));
    [self.mpBarBack addChild:self.mpBarFill];
    self.mpBarFill.position = CGPointMake(((self.mpBarBack.size.width * (265.00f/762.00f))), (self.mpBarBack.size.height * (132.00f/252.00f)));
    self.mpBarFill.anchorPoint = CGPointMake(0, 0.5);
    self.mpBarFillMaxWidth = self.mpBarFill.size.width;


    
    /*[self addChild:healthBarBack];
    self.healthBar = [SKSpriteNode spriteNodeWithImageNamed:@"loader_bar_red_fill.png"];
    self.healthBar.position = CGPointMake(5, 5);
    self.healthBar.size = CGSizeMake(self.playerHealth/self.playerHealthMax * 100, 10);
    self.healthBar.anchorPoint = CGPointMake(0.0, 0.5);
    //[healthBarBack addChild:self.healthBar];*/
    
    self.attackMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.attackMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.attackMPLabel.name = @"attackMPLabel";
    self.attackMPLabel.text = @"Adagio MP: 3.0";
    self.attackMPLabel.fontSize = 20.0f;
    self.attackMPLabel.zPosition =1.0f;
    self.attackMPLabel.position = CGPointMake(self.frame.size.width*0.25, self.frame.size.height*0.9 - +10);
    self.attackMPLabel.alpha = 0.0f;
    self.attackMPLabel.fontColor = [SKColor greenColor];
    [self addChild:self.attackMPLabel];
    
    self.defenseMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.defenseMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.defenseMPLabel.name = @"defenseMPLabel";
    self.defenseMPLabel.text = @"Brio MP: 3.0";
    self.defenseMPLabel.fontSize = 20.0f;
    self.defenseMPLabel.zPosition =1.0f;
    self.defenseMPLabel.position = CGPointMake(self.frame.size.width*0.50, self.frame.size.height*0.9 - +10);
    self.defenseMPLabel.fontColor = [SKColor greenColor];
    self.defenseMPLabel.alpha = 0.0f;
    [self addChild:self.defenseMPLabel];
    
    self.magicMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.magicMPLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    self.magicMPLabel.name = @"magicMPLabel";
    self.magicMPLabel.text = @"Vif MP: 3.0";
    self.magicMPLabel.fontSize = 20.0f;
    self.magicMPLabel.zPosition =1.0f;
    self.magicMPLabel.alpha = 0.0f;
    self.magicMPLabel.position = CGPointMake(self.frame.size.width*0.75, self.frame.size.height*0.9 - +10);
    self.magicMPLabel.fontColor = [SKColor greenColor];
    [self addChild:self.magicMPLabel];
    
#pragma mark- Superpowered init
    lastSamplerate = activeFx = 0;
    crossValue = 1.0f;
    volC = volD = volE = volF = volG =  0.5f * headroom;
    volBack = 0.85 * headroom;
    pthread_mutex_init(&mutex, NULL); // This will keep our player volumes and playback states in sync.
    if (posix_memalign((void **)&stereoBuffer, 16, 4096 + 128) != 0) abort(); // Allocating memory, aligned to 16.
    
    playerBack = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackBack, 44100, 0);
    playerBack->open([[[NSBundle mainBundle] pathForResource:@"Back1" ofType:@"mp3"] fileSystemRepresentation]);
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
    rightArrow.zPosition = 3.0f;
    rightArrow.hidden = YES;
    
    SKSpriteNode *leftArrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrowLeft.png"];
    leftArrow.name = @"leftArrow";
    leftArrow.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowCNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowCNode"].frame) + 20);
    leftArrow.size = CGSizeMake(40, 40);
    [self addChild:leftArrow];
    leftArrow.alpha = 0.0f;
    leftArrow.hidden = YES;
#pragma mark- set initial room
    self.currentRoomNumber = 1;
    [self loadRoom:self.currentRoomNumber];
    
#pragma mark- add key icons
//    SKSpriteNode *attackSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"weaponSymbol.png"];
//    attackSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
//    attackSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowCNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowCNode"].frame) - attackSymbol.size.height/2 - 10);
//    attackSymbol.name = @"lowCNode";
//    attackSymbol.zPosition = 3.1f;
//    [self addChild:attackSymbol];
//    
//    SKSpriteNode *defenseSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"defenseSymbol.png"];
//    defenseSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
//    defenseSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowDNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowDNode"].frame) - attackSymbol.size.height/2 - 10);
//    defenseSymbol.name = @"lowDNode";
//    defenseSymbol.zPosition = 3.1f;
//    [self addChild:defenseSymbol];
//    
//    SKSpriteNode *magicSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"magicSymbol.png"];
//    magicSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
//    magicSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowFNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowFNode"].frame) - attackSymbol.size.height/2 - 10);
//    magicSymbol.name = @"lowFNode";
//    magicSymbol.zPosition = 3.1f;
//    [self addChild:magicSymbol];
//    
//    SKSpriteNode *moveSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"moveSymbol.png"];
//    moveSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
//    moveSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowENode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowENode"].frame) - attackSymbol.size.height/2 - 10);
//    moveSymbol.name = @"lowENode";
//    moveSymbol.zPosition = 3.1f;
//    [self addChild:moveSymbol];
//    
//    SKSpriteNode *resonantSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"resonantSymbol.png"];
//    resonantSymbol.size = CGSizeMake((self.frame.size.width/12)/1.5,(self.frame.size.height/2.25)/4);
//    resonantSymbol.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"lowGNode"].frame), CGRectGetMaxY([self childNodeWithName:@"lowGNode"].frame) - attackSymbol.size.height/2 - 10);
//    resonantSymbol.name = @"lowGNode";
//    resonantSymbol.zPosition = 3.1f;
//    [self addChild:resonantSymbol];

#pragma mark- Miscellaneous Properties
    
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
    
    double beatInterval = 60.0f/self.BPM;
    NSTimer *beatTimer = [NSTimer scheduledTimerWithTimeInterval:beatInterval target:self selector:@selector(beatTimer:) userInfo:nil repeats:false];
    
    self.touchDown = NO;
    
    [self loadCombos];
    
    self.fireballArray = [[NSMutableArray alloc] init];
    self.enemyShotArray = [[NSMutableArray alloc] init];
    self.enemyToDeleteArray = [[NSMutableArray alloc] init];
    self.propArray = [[NSMutableArray alloc] init];
    
    self.playerMaxX = CGRectGetMaxX(self.player.frame);
    
    self.shouldShoot = YES;
    self.filterInt = 100;
    [self playCutscene:@"intro"];
    
    self.availableComboBlockArray = [[NSMutableArray alloc] init];
    
    [self.player setTexture:self.player.musicModeAdagioIdleFrames[0]];
    self.player.mode = @"Fire";
    [self changeModes];
    self.gameOver = NO;
    self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
    [self hideDefenseMarkers];

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
        NSLog(@"Mode:%@", self.player.mode);
        if([n.name containsString:@"lowCNode"])
        {
            [self childNodeWithName:@"lowCNode"].alpha = 0.7f;
            [self silenceLowKeys];
            volC = 0.5f;
            self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
            if(![self.player.mode isEqualToString:@"Fire"]){
                self.player.mode = @"Fire";
                NSLog(@"self.player.mode:%@", self.player.mode);
                [self changeModes];
            }
            self.currentKeyDown = @"lowCNode";
        }else if([n.name containsString:@"lowDNode"])
        {
            [self childNodeWithName:@"lowDNode"].alpha = 0.7f;

            if(![self.player.mode isEqualToString:@"Wind"]){
                self.player.mode = @"Wind";
                NSLog(@"self.player.mode:%@", self.player.mode);
                [self changeModes];
            }
            [self silenceLowKeys];
            volD = 0.5f;

            self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];

            self.currentKeyDown = @"lowDNode";
        }else if([n.name containsString:@"lowENode"])
        {
            [self childNodeWithName:@"lowENode"].alpha = 0.7f;

            if(![self.player.mode isEqualToString:@"Water"]){
                self.player.mode = @"Water";
                NSLog(@"self.player.mode:%@", self.player.mode);
                [self changeModes];
            }
            [self silenceLowKeys];
            volE = 0.5f;
            [self getPlayerCurrentKey];

            self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];

            self.currentKeyDown = @"lowENode";
        }else if([n.name containsString:@"lowFNode"])
        {
            [self childNodeWithName:@"lowFNode"].alpha = 0.7f;

            if(![self.player.mode isEqualToString:@"Earth"]){
                self.player.mode = @"Earth";
                NSLog(@"self.player.mode:%@", self.player.mode);
                [self changeModes];
            }
            //[lowChannel stop];
            //[lowChannel play:lDKeyBuffer loop:YES];
//            pthread_mutex_lock(&mutex);
//            playerC->exitLoop();
//            playerD->exitLoop();
//            playerE->exitLoop();
//            playerF->loop(0, 8000, YES, 255, YES);
//            playerG->exitLoop();
//            playerD->pause();
//            playerE->pause();
//            playerC->pause();
//            playerG->pause();
//            pthread_mutex_unlock(&mutex);
            [self silenceLowKeys];
            volF = 0.5f;
            
            self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];

            self.currentKeyDown = @"lowFNode";
        }else if([n.name containsString:@"lowGNode"])
        {
            [self childNodeWithName:@"lowGNode"].alpha = 0.7f;

            if(![self.player.mode isEqualToString:@"Music"]){
                self.player.mode = @"Music";
                NSLog(@"self.player.mode:%@", self.player.mode);
                [self changeModes];
            }

            [self silenceLowKeys];
            volG = 0.5f;
            
            
            self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];

            self.currentKeyDown = @"lowGNode";
        }else if([n.name containsString:@"highANode"])
        {
            [self childNodeWithName:@"highANode"].alpha = 0.7f;

            [channel play:aKeyBuffer];
            [self checkDefenseForKey:@"A"];
            [self shootLaser:keyLaserDamage withNote:@"A"];
            [self.keyPressArray insertObject:@"highANode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highANode"];
            self.currentKeyDown = @"highANode";
        }else if([n.name containsString:@"highBNode"])
        {
            [self childNodeWithName:@"highBNode"].alpha = 0.7f;

            [channel play:bKeyBuffer];
            
            [self shootLaser:keyLaserDamage withNote:@"B"];
            [self checkDefenseForKey:@"B"];
            [self.keyPressArray insertObject:@"highBNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highBNode"];
            self.currentKeyDown = @"highBNode";
        }else if([n.name containsString:@"highCNode"])
        {
            [self childNodeWithName:@"highCNode"].alpha = 0.7f;

            [channel play:cKeyBuffer];
            
            [self shootLaser:keyLaserDamage withNote:@"C"];
            [self checkDefenseForKey:@"C"];
            [self.keyPressArray insertObject:@"highCNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highCNode"];
            self.currentKeyDown = @"highCNode";
        }else if([n.name containsString:@"highDNode"])
        {
            [self childNodeWithName:@"highDNode"].alpha = 0.7f;

            [channel play:dKeyBuffer];
            
            [self shootLaser:keyLaserDamage withNote:@"D"];
            [self checkDefenseForKey:@"D"];
            [self.keyPressArray insertObject:@"highDNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highDNode"];
            self.currentKeyDown = @"highDNode";
        }else if([n.name containsString:@"highENode"])
        {
            [self childNodeWithName:@"highENode"].alpha = 0.7f;

            [channel play:eKeyBuffer];
            [self shootLaser:keyLaserDamage withNote:@"E"];
            [self.keyPressArray insertObject:@"highENode" atIndex:0];
            [self checkDefenseForKey:@"E"];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highENode"];
            self.currentKeyDown = @"highENode";
        }else if([n.name containsString:@"highFNode"])
        {
            [self childNodeWithName:@"highFNode"].alpha = 0.7f;

            [channel play:fKeyBuffer];
            
            [self shootLaser:keyLaserDamage withNote:@"F"];
            [self checkDefenseForKey:@"F"];
            [self.keyPressArray insertObject:@"highFNode" atIndex:0];
            [self.keyPressArray removeLastObject];
            [self movePlayer:@"highFNode"];
            self.currentKeyDown = @"highFNode";
        }else if([n.name containsString:@"highGNode"])
        {
            [self childNodeWithName:@"highGNode"].alpha = 0.7f;

            [channel play:gKeyBuffer];
            
            [self shootLaser:keyLaserDamage withNote:@"G"];
            [self.keyPressArray insertObject:@"highGNode" atIndex:0];
            [self checkDefenseForKey:@"G"];
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
            
            if(self.bowTieIncrement == 3)
            {
                if(self.player.fireMP <= self.player.fireMPMax - 1){
                    self.player.fireMP++;
                }else if(self.player.waterMP <= self.player.waterMPMax - 1){
                    self.player.waterMP++;
                }else if(self.player.windMP <= self.player.windMPMax - 1){
                    self.player.windMP++;
                }else if(self.player.earthMP <= self.player.earthMPMax - 1){
                    self.player.earthMP++;
                }else if(self.player.musicMP <= self.player.musicMPMax - 1){
                    self.player.musicMP++;
                }
                self.bowTieIncrement = 0;
                
            }

            [self.keyPressArray insertObject:@"bowTie" atIndex:0];
            [self.keyPressArray removeLastObject];
        }else if(![n.name containsString:@"inter"]){
            [[self childNodeWithName:@"textBox"] removeFromParent];
            for(Interactable *inter in self.interactableArray){
                if(inter.speechBubble){
                    inter.speechBubble.alpha = 0.0f;
                }
            }

        }
        else{
            [self.keyPressArray insertObject:@"blank" atIndex:0];
            [self.keyPressArray removeLastObject];
        }
        
        
    }
    
    
    self.touchBegan = CACurrentMediaTime();
    [self checkCombo];
    [self setAvailableComboNotes];

}

-(void)silenceLowKeys{
    volC = 0.0f;
    volD = 0.0f;
    volE = 0.0f;
    volF = 0.0f;
    volG = 0.0f;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchDown = NO;
    [self hideInteractables];
    [self checkResonantMelody];
    for (UITouch *touch in touches) {
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        if([n.name containsString:@"lowCNode"])
        {
            [self childNodeWithName:@"lowCNode"].alpha = 0.0f;
        }else if([n.name containsString:@"lowDNode"]){
            [self childNodeWithName:@"lowDNode"].alpha = 0.0f;

        }else if([n.name containsString:@"lowENode"]){
            [self childNodeWithName:@"lowENode"].alpha = 0.0f;

        }else if([n.name containsString:@"lowFNode"]){
            [self childNodeWithName:@"lowFNode"].alpha = 0.0f;

        }else if([n.name containsString:@"lowGNode"]){
            [self childNodeWithName:@"lowGNode"].alpha = 0.0f;

        }else if([n.name containsString:@"highANode"]){
            [self childNodeWithName:@"highANode"].alpha = 0.3f;
            
        }else if([n.name containsString:@"highBNode"]){
            [self childNodeWithName:@"highBNode"].alpha = 0.3f;
            
        }else if([n.name containsString:@"highCNode"]){
            [self childNodeWithName:@"highCNode"].alpha = 0.3f;
            
        }else if([n.name containsString:@"highDNode"]){
            [self childNodeWithName:@"highDNode"].alpha = 0.3f;
            
        }else if([n.name containsString:@"highENode"]){
            [self childNodeWithName:@"highENode"].alpha = 0.3f;
            
        }else if([n.name containsString:@"highFNode"]){
            [self childNodeWithName:@"highFNode"].alpha = 0.3f;
            
        }else if([n.name containsString:@"highGNode"]){
            [self childNodeWithName:@"highGNode"].alpha = 0.3f;
            
        }
    }
}


/**
 * The main method behind the Guitar Hero style defense when enemies attack
 */
-(void)checkDefenseForKey:(NSString *)keyName{
    NSString *noteName = [NSString stringWithFormat:@"%@*", keyName];
    NSMutableArray *noteArray = [[NSMutableArray alloc] init];
    [self enumerateChildNodesWithName:noteName usingBlock:^(SKNode *node, BOOL *stop) {
        [noteArray addObject:node];
    }];
    
    if(noteArray.count > 0)
    {
        SKSpriteNode *enemyNote = [noteArray objectAtIndex:0];
        for(int x = 0; x < noteArray.count; x++)
        {
            
            SKSpriteNode *otherNote = (SKSpriteNode *)[noteArray objectAtIndex:x];
            if((otherNote.position.y < enemyNote.position.y && otherNote.position.y > CGRectGetMinY([self childNodeWithName:@"aMarker"].frame)) || enemyNote.position.y < CGRectGetMinY([self childNodeWithName:@"aMarker"].frame))
            {
                enemyNote = otherNote;
            }
            
        }
        
        NSMutableDictionary *attackDictionary = [[NSMutableDictionary alloc] init];
        
        for(Enemy *enemy in self.enemyArray){
            if([enemyNote.name containsString:[enemy.name uppercaseString]]){
                attackDictionary = enemy.attackDictionary;
            }
        }
//        NSLog(@"Current Attack Damage1:%@", [attackDictionary objectForKey:@"currentAttackDamage"]);

        SKSpriteNode *marker = (SKSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"%@Marker", keyName.lowercaseString]];
        SKLabelNode *quality = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica-Bold"];
        quality.fontSize = 15.0f;
        quality.zPosition = 2.0f;
        [self addChild:quality];
        quality.position = CGPointMake(marker.position.x, marker.position.y + 20);
        float currentAttackDamage = [[attackDictionary objectForKey:@"currentAttackDamage"] floatValue];
        float maxAttackDamage = [[attackDictionary objectForKey:@"maxAttackDamage"] floatValue];
        float damageStep = maxAttackDamage / (attackDictionary.count - 4.0f);
//        NSLog(@"DamageStep:%f", damageStep);
        if(fabs(enemyNote.position.y - marker.position.y)  >= 30.00f && fabs(enemyNote.position.y - marker.position.y)< 50.00f){
            [enemyNote removeFromParent];
            quality.text = @"OK";
            currentAttackDamage -= damageStep/4.0f;
            quality.fontColor = [SKColor redColor];
            
        }else if(fabs(enemyNote.position.y - marker.position.y) >= 20.00f &&  fabs(enemyNote.position.y - marker.position.y) < 30.00f){
            [enemyNote removeFromParent];
            quality.text = @"Good!";
            currentAttackDamage -= damageStep/3.0f;
            quality.fontColor = [SKColor blueColor];

        }else if(fabs(enemyNote.position.y - marker.position.y) >= 10.00f &&  fabs(enemyNote.position.y - marker.position.y) < 20.00f){
            [enemyNote removeFromParent];
            currentAttackDamage -= damageStep/2.0f;
            quality.fontColor = [SKColor greenColor];

            quality.text = @"Great!";
        }else if(fabs(enemyNote.position.y - marker.position.y) >= 0.00f &&  fabs(enemyNote.position.y - marker.position.y) < 10.00f){
            [enemyNote removeFromParent];
            currentAttackDamage -= damageStep;
            quality.fontColor = [SKColor purpleColor];

            quality.text = @"Perfect!";
        }
        
        [attackDictionary setObject:[NSNumber numberWithFloat:currentAttackDamage] forKey:@"currentAttackDamage"];
//        NSLog(@"Current Attack Damage:%@", [attackDictionary objectForKey:@"currentAttackDamage"]);
        
        SKAction *moveUp = [SKAction moveByX:0 y:10.0f duration:0.2f];
        SKAction *fade = [SKAction fadeAlphaTo:0.0f duration:0.2f];
        SKAction *moveUpAndFade = [SKAction group:@[moveUp, fade]];
        [quality runAction:moveUpAndFade completion:^{
            [quality removeFromParent];
        }];
    }

    
    
}


#pragma mark- animations

-(void)animateBowTie{
    
    SKAction *moveUp = [SKAction moveByX:0 y:3 duration:1.0f];
    SKAction *moveDown = [SKAction moveByX:0 y:-3 duration:1.0f];
    SKAction *floatAction = [SKAction sequence:@[moveUp, moveDown]];
    [self.bowTie runAction:[SKAction repeatActionForever:floatAction]];
    
}

#pragma mark- checks

/**
 * Checks to see if the user has touched a sign or NPC
 */
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


/**
 * Checks to see if the user has played an enemy's Resonant Melody back at it
 */
-(void)checkResonantMelody{
    for(Enemy *enemy in self.enemyArray){
        BOOL shatter = NO;
        NSUInteger length = enemy.resonantArray.count;
        switch (length) {
            case 1:
                shatter = (([[self.keyPressArray objectAtIndex:0] isEqualToString:[enemy.resonantArray objectAtIndex:0]]) && [self.player.mode isEqualToString:@"Resonance"]);
                break;
            case 2:
                shatter = (([[self.keyPressArray objectAtIndex:0] isEqualToString:[enemy.resonantArray objectAtIndex:1]]) && ([[self.keyPressArray objectAtIndex:1] isEqualToString:[enemy.resonantArray objectAtIndex:0]]) && [self.player.mode isEqualToString:@"Resonance"]);
                break;
            case 3:
                shatter = (([[self.keyPressArray objectAtIndex:0] isEqualToString:[enemy.resonantArray objectAtIndex:2]]) && ([[self.keyPressArray objectAtIndex:1] isEqualToString:[enemy.resonantArray objectAtIndex:1]]) && ([[self.keyPressArray objectAtIndex:2] isEqualToString:[enemy.resonantArray objectAtIndex:0]]) && [self.player.mode isEqualToString:@"Resonance"]);
                break;
            case 4:
                shatter = (([[self.keyPressArray objectAtIndex:0] isEqualToString:[enemy.resonantArray objectAtIndex:3]]) && ([[self.keyPressArray objectAtIndex:1] isEqualToString:[enemy.resonantArray objectAtIndex:2]]) && ([[self.keyPressArray objectAtIndex:2] isEqualToString:[enemy.resonantArray objectAtIndex:1]]) && ([[self.keyPressArray objectAtIndex:3] isEqualToString:[enemy.resonantArray objectAtIndex:0]]) && [self.player.mode isEqualToString:@"Resonance"]);
                break;
            case 7:
                shatter = (([[self.keyPressArray objectAtIndex:0] isEqualToString:[enemy.resonantArray objectAtIndex:6]]) && ([[self.keyPressArray objectAtIndex:1] isEqualToString:[enemy.resonantArray objectAtIndex:5]]) && ([[self.keyPressArray objectAtIndex:2] isEqualToString:[enemy.resonantArray objectAtIndex:4]]) && ([[self.keyPressArray objectAtIndex:3] isEqualToString:[enemy.resonantArray objectAtIndex:3]]) && ([[self.keyPressArray objectAtIndex:4] isEqualToString:[enemy.resonantArray objectAtIndex:2]]) && ([[self.keyPressArray objectAtIndex:5] isEqualToString:[enemy.resonantArray objectAtIndex:1]]) && ([[self.keyPressArray objectAtIndex:6] isEqualToString:[enemy.resonantArray objectAtIndex:0]]) && [self.player.mode isEqualToString:@"Resonance"]);
                break;
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
            [enemy removeFromParent];
            SKLabelNode *enemyHealthBar = (SKLabelNode*)[enemy childNodeWithName:[NSString stringWithFormat:@"%@Bar", enemy.name]];
            enemyHealthBar.alpha = 0.0f;
            enemyHealthBar.hidden = YES;
            
            if(self.currentRoomNumber == 7){
                [self childNodeWithName:@"treeSprite"].hidden = YES;
                [[self childNodeWithName:@"treeSprite"] removeFromParent];
            }
            
           // NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"glassShatter" ofType:@"sks"];
            //SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
            //myParticle.position = self.boss.position;
           // [self addChild:myParticle];
            //ADD A HUGE SHATTERING LABEL HERE
        }
    }
}

/**
 *  Checks to see if the user has cleared all necessary flags in order to advance to the next room
 */
-(void)checkRoomTransitions{
    
    SKSpriteNode *rightArrow = (SKSpriteNode *)[self childNodeWithName:@"rightArrow"];
    SKSpriteNode *leftArrow = (SKSpriteNode *)[self childNodeWithName:@"leftArrow"];
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
        if([self childNodeWithName:@"enemy1"] && ([self childNodeWithName:@"enemy1"].hidden == NO) && [self childNodeWithName:@"enemy2"] && ([self childNodeWithName:@"enemy2"].hidden == NO) && !(self.roomCleared >= 4)){
            rightArrow.alpha = 0.0f;
            rightArrow.hidden = YES;
        }
    }else if(self.currentRoomNumber == 6){
        if([self childNodeWithName:@"bigTree"] && ([self childNodeWithName:@"bigTree"].hidden == NO) && !(self.roomCleared >= 6)){
            rightArrow.alpha = 0.0f;
            rightArrow.hidden = YES;
        }
    }else if(self.currentRoomNumber == 7){
        if([self childNodeWithName:@"boss"] && ([self childNodeWithName:@"boss"].hidden == NO) && !(self.roomCleared >= 7)){
            rightArrow.alpha = 0.0f;
            rightArrow.hidden = YES;
        }
    }
    
    
}

/**
 * Hides sign/text dialogue
 */
-(void)hideInteractables{
    [self childNodeWithName:@"signLabel"].alpha = 0.0f;
    [self childNodeWithName:@"signLabel"].zPosition = -2.0f;
    [self childNodeWithName:@"signPost"].alpha = 0.0f;
    [self childNodeWithName:@"signPost"].zPosition = -2.0f;
}

/**
 * The player has changed his elemental mode by tapping on one of the lower keys
 */
-(void)changeModes{

    [self.player changeModeAnimation];
    
}

/**
 * Called whenever the user hits an upper key
 */
-(void)shootLaser:(float)keyLaserDamage withNote:(NSString*)laserNote{
    if(self.shouldShoot && ![self.player.mode isEqualToString:@"Bag"] && ![self.player.mode isEqualToString:@"Resonance"] && self.defending == NO){
        KeyLaser *keyLaser = [_keyLasers objectAtIndex:_nextKeyLaser];
        _nextKeyLaser++;
        if (_nextKeyLaser >= self.keyLasers.count) {
            
            _nextKeyLaser = 0;
        }
        
        if(keyLaserDamage < 0.5f){
            keyLaser.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"redNote.png"]];
        }else{
            keyLaser.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"note1.png"]];
        }
        keyLaser.damage = keyLaserDamage;
        if([self.player.mode isEqualToString:@"Defense"]){
            keyLaser.note = laserNote;
        }else{
            keyLaser.note = @"";
        }
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
/**
 *  Checks to see if the user has played a correct sequence of notes on the upper keys in order to perform a combo
 */
-(void)checkCombo{
    
    if(self.shouldShoot && self.defending == NO){
        BOOL comboSuccess = NO;
        if([self.player.mode isEqualToString: @"Fire"])
        {
            NSArray *combo1 = self.fireComboArray[0];
            if((self.player.fireMP >= 1) &&([self.keyPressArray[0] isEqualToString:combo1[2]]) && ([self.keyPressArray[1] isEqualToString:combo1[1]]) && ([self.keyPressArray[2] isEqualToString:combo1[0]])){
                SKSpriteNode *fireball = [SKSpriteNode spriteNodeWithImageNamed:@"fireball_0001"];
                [self.player fireballAnimation:fireball];
                fireball.size = CGSizeMake(75, 75);
                fireball.position = CGPointMake(self.player.position.x+fireball.size.width/2,self.player.position.y+0);
                fireball.name = @"fireball";
                [self addChild:fireball];
                SKAction *laserMoveAction = [SKAction moveByX:self.frame.size.width y:0 duration:2.0f];
                SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
                    fireball.hidden = YES;
                }];
                
                SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
                
                [fireball runAction:moveLaserActionWithDone withKey:@"laserFired"];
                if(self.fireballArray.count > 10){
                    [self.fireballArray removeObjectAtIndex:0];
                }
                [self.fireballArray addObject:fireball];
                self.player.fireMP -= 1;
                comboSuccess = YES;

            }
            
            NSArray *combo2 = self.fireComboArray[1];
            if((self.player.fireMP >= 2) &&([self.keyPressArray[1] isEqualToString:combo2[2]]) && ([self.keyPressArray[2] isEqualToString:combo2[1]]) && ([self.keyPressArray[3] isEqualToString:combo2[0]]) && !self.flameOn)
               {
                   self.flameOn = YES;
                   SKSpriteNode *flame = [SKSpriteNode spriteNodeWithImageNamed:@"fireball.png"];
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
                   self.player.fireMP -= 2;
                   comboSuccess = YES;

               }
        }
        if([self.player.mode isEqualToString: @"Music"])
        {
            NSArray *combo1 = self.musicComboArray[0];
            if((self.player.musicMP >= 1) &&([self.keyPressArray[0] isEqualToString:combo1[2]]) && ([self.keyPressArray[1] isEqualToString:combo1[1]]) && ([self.keyPressArray[2] isEqualToString:combo1[0]]) && self.filterInt == 100)
            {
                //We increase the player's health by a certain amount each beat. This is done in the beat function
                filter->enable(true);
                self.filterInt = 0;
                self.player.musicMP-= 1;
                comboSuccess = YES;
            
            }
        }
        if([self.player.mode isEqualToString: @"Wind"])
        {
            NSLog(@"Wind");
            NSArray *combo1 = self.windComboArray[0];
            if((self.player.windMP >= 1) &&([self.keyPressArray[0] isEqualToString:combo1[2]]) && ([self.keyPressArray[1] isEqualToString:combo1[1]]) && ([self.keyPressArray[2] isEqualToString:combo1[0]]) && self.filterInt == 100)
            {
                
                SKSpriteNode *whiplashSprite = [SKSpriteNode spriteNodeWithImageNamed:@"cut_b_0001.png"];
                whiplashSprite.size = CGSizeMake(75, 75);
                whiplashSprite.position = CGPointMake(self.player.position.x + 20, self.player.position.y);
                whiplashSprite.zPosition = self.player.zPosition + 0.1f;
                [self addChild:whiplashSprite];
                [self.player whiplashAnimation:whiplashSprite];
                SKAction *wait = [SKAction waitForDuration:0.25f];
                [whiplashSprite runAction:wait completion:^{
                    [whiplashSprite removeFromParent];
                }];
                int firstEnemy = true;
                for(Enemy *enemy in self.enemyArray){
                    if(firstEnemy == true){
                        enemy.health -= 30.0f;
                        firstEnemy = false;
                    }
                }

                self.player.windMP -= 1;
                comboSuccess = YES;
                
            }
        }
        if([self.player.mode isEqualToString: @"Water"])
        {
            NSArray *combo1 = self.waterComboArray[0];
            if((self.player.waterMP >= 1) &&([self.keyPressArray[0] isEqualToString:combo1[2]]) && ([self.keyPressArray[1] isEqualToString:combo1[1]]) && ([self.keyPressArray[2] isEqualToString:combo1[0]])){
                SKSpriteNode *watergun = [SKSpriteNode spriteNodeWithImageNamed:@"watergun_0001.png"];
                [self.player watergunAnimation:watergun];
                watergun.name = @"watergun";
                watergun.size = CGSizeMake(75, 75);
                watergun.position = CGPointMake(self.player.position.x+watergun.size.width/2,self.player.position.y+0);
                [self addChild:watergun];
                SKAction *laserMoveAction = [SKAction moveByX:self.frame.size.width y:0 duration:1.0f];
                [watergun runAction:laserMoveAction completion:^{
                    [watergun removeFromParent];
                }];
                self.player.waterMP -= 1;
                comboSuccess = YES;
                
            }
        }
        
        if(comboSuccess){
            self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
            [self setAvailableComboNotes];
        }
    
    }
}

/**
 * The list of available combos
 */
-(void)loadCombos{
    
    NSArray *fireCombo0 = @[@"highCNode", @"highDNode", @"highENode"];
    NSArray *fireCombo1 = @[@"highCNode", @"highENode", @"highGNode"];
    self.fireComboArray = @[fireCombo0, fireCombo1];
    self.fireComboDictionary = @{@"🔥":@[@"highCNode", @"highDNode", @"highENode"]};
    
    NSArray *musicCombo0 = @[@"highENode", @"highFNode",@"highGNode"];
    self.musicComboArray = @[musicCombo0];
    self.musicComboDictionary = @{@"🎵":@[@"highENode", @"highFNode", @"highGNode"]};
    
    NSArray *windCombo0 = @[@"highDNode", @"highENode", @"highDNode"];
    self.windComboArray = @[windCombo0];
    self.windComboDictionary = @{@"💨":windCombo0};
    
    NSArray *earthCombo0 = @[@"highGNode", @"highFNode", @"highENode"];
    self.earthComboArray = @[earthCombo0];
    self.earthComboDictionary = @{@"Rock":earthCombo0};
    
    NSArray *waterCombo0 = @[@"highENode", @"highCNode", @"highCNode"];
    self.waterComboArray = @[waterCombo0];
    self.waterComboDictionary = @{@"💦":waterCombo0};

    

}

/**
 * Adds a filter sweep to the backing track and has a chance to stun enemies for a couple of beats
 */
-(void)sleepCombo{
    for(Enemy *enemy in self.enemyArray){
        int randomInt = arc4random() % enemy.sleepChance;
        if(randomInt == 0){
            enemy.canShoot = NO;
            enemy.canMove = NO;
            NSLog(@"SLEEP!");
            
            //Add a little sleep label that lets you know it hit
            SKLabelNode *sleepLabel;
            sleepLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
            sleepLabel.name = @"sleepLabel";
            sleepLabel.text = @"Sleep!";
            sleepLabel.fontSize = 20;
            sleepLabel.fontColor = [SKColor greenColor];
            [enemy addChild:sleepLabel];
            sleepLabel.position = CGPointMake(0, enemy.size.height/2 + 15);
            
            SKAction *fadeAction = [SKAction fadeAlphaTo:0.0f duration:0.5];
            SKAction *moveUp = [SKAction moveToY:sleepLabel.frame.origin.y+10 duration:0.5];
            SKAction *removeLabel = [SKAction removeFromParent];
            SKAction *hideLabel = [SKAction hide];
            SKAction *fadeUp = [SKAction group:@[moveUp, fadeAction]];
            SKAction *labelAnim = [SKAction sequence:@[fadeUp, hideLabel, removeLabel]];
            [sleepLabel runAction:labelAnim];

        }else{
            //Add a label that lets you know you missed
            SKLabelNode *sleepLabel;
            sleepLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
            sleepLabel.name = @"sleepLabel";
            sleepLabel.text = @"Miss!";
            sleepLabel.fontSize = 20;
            sleepLabel.fontColor = [SKColor greenColor];
            [enemy addChild:sleepLabel];
            sleepLabel.position = CGPointMake(0, enemy.size.height/2 + 15);

            SKAction *fadeAction = [SKAction fadeAlphaTo:0.0f duration:0.5];
            SKAction *moveUp = [SKAction moveToY:sleepLabel.frame.origin.y+10 duration:0.5];
            SKAction *removeLabel = [SKAction removeFromParent];
            SKAction *hideLabel = [SKAction hide];
            SKAction *fadeUp = [SKAction group:@[moveUp, fadeAction]];
            SKAction *labelAnim = [SKAction sequence:@[fadeUp, hideLabel, removeLabel]];
            [sleepLabel runAction:labelAnim];
            
        }
    }
    
}


-(void)endSleepCombo{
    for(Enemy *enemy in self.enemyArray){
        
        if(!enemy.hidden){
            enemy.canShoot = YES;
        }
            enemy.canMove = YES;
    }
}


/**
 * Sets the notes that the user can play on the upper keys in order to perform combos. These are dynamic with each upper key press, and change
 * depending on which mode/element the player is currently
 */
-(void)setAvailableComboNotes{
    if(self.defending == NO){
        if([self.player.mode isEqualToString:@"Fire"]){
            NSDictionary *beginningCombos = @{@"🔥":@"highCNode"};
            if([[self.keyPressArray objectAtIndex:0] isEqualToString:@""]){
                self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
            }else{
                BOOL foundAMatch = NO;
                for(id key in self.fireComboDictionary)
                {
                    NSArray *combo = [self.fireComboDictionary objectForKey:key];
                    NSString *comboName = key;
                    BOOL matchFound = NO;
                    int startingInt = 0;
                    for(int i = 0; i < combo.count - 1; i++){
                        if([self.keyPressArray[i] isEqualToString:combo[0]]){
                            if([self.keyPressArray[0] isEqualToString:self.keyPressArray[1]] && [self.keyPressArray[0] isEqualToString:combo[0]]){
                                startingInt = 0;
                                matchFound = YES;
                            }else{
                                startingInt = i;
                                NSLog(@"Starting int:%d", startingInt);
                                matchFound = YES;
                            }
                        }
                    }
                    
                    if(matchFound)
                    {
                        int x = 0;
                        int furthestInt = 0;
                        BOOL matching = YES;
                        for(int i = startingInt; i >= 0; i--){
                            matching = NO;
                            if([self.keyPressArray[i] isEqualToString:combo[x]]){
                                furthestInt = x;
                                NSLog(@"Key press array i:%@, combox:%@", self.keyPressArray[i], combo[x]);
                                NSLog(@"Furthest int:%d", furthestInt);
                                matching = YES;
                                
                            }
                            x++;
                        }
                        NSLog(@"Matchin:%d", matching);
                        if(furthestInt + 1 < combo.count && matching){
                            foundAMatch = YES;
                            NSLog(@"Combo next letter: %@", [combo objectAtIndex:furthestInt+1]);
                            [self.availableComboNoteDictionary setObject:[combo objectAtIndex:furthestInt+1] forKey:comboName];
                        }
                    }
                }
                
                if(!foundAMatch){
                    self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
                }
            }
        }else if([self.player.mode isEqualToString:@"Music"]){
            
            NSDictionary *beginningCombos = @{@"🎵":@"highENode"};
            if([[self.keyPressArray objectAtIndex:0] isEqualToString:@""]){
                self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
            }else{
                BOOL foundAMatch = NO;
                for(id key in self.musicComboDictionary)
                {
                    NSArray *combo = [self.musicComboDictionary objectForKey:key];
                    NSString *comboName = key;
                    BOOL matchFound = NO;
                    int startingInt = 0;
                    for(int i = 0; i < combo.count - 1; i++){
                        if([self.keyPressArray[i] isEqualToString:combo[0]]){
                            if([self.keyPressArray[0] isEqualToString:self.keyPressArray[1]] && [self.keyPressArray[0] isEqualToString:combo[0]]){
                                startingInt = 0;
                                matchFound = YES;
                            }else{
                                startingInt = i;
                                NSLog(@"Starting int:%d", startingInt);
                                matchFound = YES;
                            }
                        }
                    }
                    
                    if(matchFound)
                    {
                        int x = 0;
                        int furthestInt = 0;
                        BOOL matching = YES;
                        for(int i = startingInt; i >= 0; i--){
                            matching = NO;
                            if([self.keyPressArray[i] isEqualToString:combo[x]]){
                                furthestInt = x;
                                NSLog(@"Key press array i:%@, combox:%@", self.keyPressArray[i], combo[x]);
                                NSLog(@"Furthest int:%d", furthestInt);
                                matching = YES;
                                
                            }
                            x++;
                        }
                        NSLog(@"Matchin:%d", matching);
                        if(furthestInt + 1 < combo.count && matching){
                            foundAMatch = YES;
                            NSLog(@"Combo next letter: %@", [combo objectAtIndex:furthestInt+1]);
                            [self.availableComboNoteDictionary setObject:[combo objectAtIndex:furthestInt+1] forKey:comboName];
                        }
                    }
                }
                
                if(!foundAMatch){
                    self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
                }
            }
        }else if([self.player.mode isEqualToString:@"Wind"]){
            
            NSDictionary *beginningCombos = @{@"💨":@"highDNode"};
            if([[self.keyPressArray objectAtIndex:0] isEqualToString:@""]){
                self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
            }else{
                BOOL foundAMatch = NO;
                for(id key in self.windComboDictionary)
                {
                    NSArray *combo = [self.windComboDictionary objectForKey:key];
                    NSString *comboName = key;
                    BOOL matchFound = NO;
                    int startingInt = 0;
                    for(int i = 0; i < combo.count - 1; i++){
                        if([self.keyPressArray[i] isEqualToString:combo[0]]){
                            if([self.keyPressArray[0] isEqualToString:self.keyPressArray[1]] && [self.keyPressArray[0] isEqualToString:combo[0]]){
                                startingInt = 0;
                                matchFound = YES;
                            }else{
                                startingInt = i;
                                NSLog(@"Starting int:%d", startingInt);
                                matchFound = YES;
                            }
                        }
                    }
                    
                    if(matchFound)
                    {
                        int x = 0;
                        int furthestInt = 0;
                        BOOL matching = YES;
                        for(int i = startingInt; i >= 0; i--){
                            matching = NO;
                            if([self.keyPressArray[i] isEqualToString:combo[x]]){
                                furthestInt = x;
                                NSLog(@"Key press array i:%@, combox:%@", self.keyPressArray[i], combo[x]);
                                NSLog(@"Furthest int:%d", furthestInt);
                                matching = YES;
                                
                            }
                            x++;
                        }
                        NSLog(@"Matchin:%d", matching);
                        if(furthestInt + 1 < combo.count && matching){
                            foundAMatch = YES;
                            NSLog(@"Combo next letter: %@", [combo objectAtIndex:furthestInt+1]);
                            [self.availableComboNoteDictionary setObject:[combo objectAtIndex:furthestInt+1] forKey:comboName];
                        }
                    }
                }
                
                if(!foundAMatch){
                    self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
                }
            }
        }else if([self.player.mode isEqualToString:@"Water"]){
            
            NSDictionary *beginningCombos = @{@"💦":@"highENode"};
            if([[self.keyPressArray objectAtIndex:0] isEqualToString:@""]){
                self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
            }else{
                BOOL foundAMatch = NO;
                for(id key in self.waterComboDictionary)
                {
                    NSArray *combo = [self.waterComboDictionary objectForKey:key];
                    NSString *comboName = key;
                    BOOL matchFound = NO;
                    int startingInt = 0;
                    for(int i = 0; i < combo.count - 1; i++){
                        if([self.keyPressArray[i] isEqualToString:combo[0]]){
                            if([self.keyPressArray[0] isEqualToString:self.keyPressArray[1]] && [self.keyPressArray[0] isEqualToString:combo[0]]){
                                startingInt = 0;
                                matchFound = YES;
                            }else{
                                startingInt = i;
                                NSLog(@"Starting int:%d", startingInt);
                                matchFound = YES;
                            }
                        }
                    }
                    
                    if(matchFound)
                    {
                        int x = 0;
                        int furthestInt = 0;
                        BOOL matching = YES;
                        for(int i = startingInt; i >= 0; i--){
                            matching = NO;
                            if([self.keyPressArray[i] isEqualToString:combo[x]]){
                                furthestInt = x;
                                NSLog(@"Key press array i:%@, combox:%@", self.keyPressArray[i], combo[x]);
                                NSLog(@"Furthest int:%d", furthestInt);
                                matching = YES;
                                
                            }
                            x++;
                        }
                        NSLog(@"Matchin:%d", matching);
                        if(furthestInt + 1 < combo.count && matching){
                            foundAMatch = YES;
                            NSLog(@"Combo next letter: %@", [combo objectAtIndex:furthestInt+1]);
                            [self.availableComboNoteDictionary setObject:[combo objectAtIndex:furthestInt+1] forKey:comboName];
                        }
                    }
                }
                
                if(!foundAMatch){
                    self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
                }
            }
        }else if([self.player.mode isEqualToString:@"Earth"]){
            
            NSDictionary *beginningCombos = @{@"Rock":@"highGNode"};
            if([[self.keyPressArray objectAtIndex:0] isEqualToString:@""]){
                self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
            }else{
                BOOL foundAMatch = NO;
                for(id key in self.earthComboDictionary)
                {
                    NSArray *combo = [self.earthComboDictionary objectForKey:key];
                    NSString *comboName = key;
                    BOOL matchFound = NO;
                    int startingInt = 0;
                    for(int i = 0; i < combo.count - 1; i++){
                        if([self.keyPressArray[i] isEqualToString:combo[0]]){
                            if([self.keyPressArray[0] isEqualToString:self.keyPressArray[1]] && [self.keyPressArray[0] isEqualToString:combo[0]]){
                                startingInt = 0;
                                matchFound = YES;
                            }else{
                                startingInt = i;
                                NSLog(@"Starting int:%d", startingInt);
                                matchFound = YES;
                            }
                        }
                    }
                    
                    if(matchFound)
                    {
                        int x = 0;
                        int furthestInt = 0;
                        BOOL matching = YES;
                        for(int i = startingInt; i >= 0; i--){
                            matching = NO;
                            if([self.keyPressArray[i] isEqualToString:combo[x]]){
                                furthestInt = x;
                                NSLog(@"Key press array i:%@, combox:%@", self.keyPressArray[i], combo[x]);
                                NSLog(@"Furthest int:%d", furthestInt);
                                matching = YES;
                                
                            }
                            x++;
                        }
                        NSLog(@"Matchin:%d", matching);
                        if(furthestInt + 1 < combo.count && matching){
                            foundAMatch = YES;
                            NSLog(@"Combo next letter: %@", [combo objectAtIndex:furthestInt+1]);
                            [self.availableComboNoteDictionary setObject:[combo objectAtIndex:furthestInt+1] forKey:comboName];
                        }
                    }
                }
                
                if(!foundAMatch){
                    self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:beginningCombos];
                }
            }
        }
        
        
        [self setAvailableComboBlocks];
    }
}

/**
 * Gives visual representations on the upper keys of which notes the user can press to perform combos
 */
-(void)setAvailableComboBlocks{
    
    NSMutableDictionary *keySpacing = [[NSMutableDictionary alloc] init];
    
    [self removeChildrenInArray:self.availableComboBlockArray];
    self.availableComboBlockArray = [[NSMutableArray alloc] init];
    
    for(id key in self.availableComboNoteDictionary){
        SKSpriteNode *keyNode = (SKSpriteNode *)[self childNodeWithName:[self.availableComboNoteDictionary objectForKey:key]];
        SKLabelNode *keyNodeLabel = (SKLabelNode *)[self childNodeWithName:[NSString stringWithFormat:@"%@Label", keyNode.name]];
        
        int ySpacing = 10;
        if([keySpacing objectForKey:[self.availableComboNoteDictionary objectForKey:key]]){
            int numOfKeys = [[keySpacing objectForKey:[self.availableComboNoteDictionary objectForKey:key]] intValue];
            ySpacing = 30 * numOfKeys;
            [keySpacing setObject:[NSNumber numberWithInt:(numOfKeys++)] forKey:[self.availableComboNoteDictionary objectForKey:key]];
        }else{
            [keySpacing setObject:@1 forKey:[self.availableComboNoteDictionary objectForKey:key]];
        }
        
        SKSpriteNode *comboBlock = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake([self childNodeWithName:@"highANode"].frame.size.width, 20)];
        //        if([self.player.mode isEqualToString:@"Fire"]){
        //            comboBlock.color = [UIColor redColor];
        //        }else if([self.player.mode isEqualToString:@"Music"]){
        //            comboBlock.color = [UIColor purpleColor];
        //        }else if([self.player.mode isEqualToString:@"Wind"]){
        //            comboBlock.color = [UIColor grayColor];
        //        }else if([self.player.mode isEqualToString:@"Water"]){
        //            comboBlock.color = [UIColor blueColor];
        //        }else if([self.player.mode isEqualToString:@"Earth"]){
        //            comboBlock.color = [UIColor greenColor];
        //        }
        comboBlock.name = [NSString stringWithFormat:@"%@Combo%@", keyNode.name, key];
        comboBlock.position = CGPointMake(CGRectGetMidX(keyNode.frame), CGRectGetMaxY(keyNodeLabel.frame) + (comboBlock.frame.size.height/2.0f) + ySpacing);
        comboBlock.zPosition = keyNode.zPosition + 0.1;
        [self addChild:comboBlock];
        ySpacing += 30;
        
        [self.availableComboBlockArray addObject:comboBlock];
        
        SKLabelNode *comboNameLabel = [SKLabelNode labelNodeWithText:key];
        comboNameLabel.name = [NSString stringWithFormat:@"%@Combo%@Label", keyNode.name, key];
        comboNameLabel.fontSize = 20.0f;
        comboNameLabel.fontName = @"Georgia-Bold";
        comboNameLabel.position = CGPointMake(comboBlock.position.x, CGRectGetMinY(comboBlock.frame));
        comboNameLabel.zPosition = comboBlock.zPosition += 0.1;
        
        [self addChild:comboNameLabel];
        [self.availableComboBlockArray addObject:comboNameLabel];
    }
    
    self.availableComboNoteDictionary = [NSMutableDictionary dictionaryWithDictionary:@{}];
    
    
}

/**
 * Called when the user either misses a combo or completes one. Resets the available combos back to the first note
 */
-(void)resetCombos{
    [self removeChildrenInArray:self.availableComboBlockArray];
    NSLog(@"Combo note array:%@", self.availableComboNoteDictionary);
    self.availableComboBlockArray = [[NSMutableArray alloc] init];
    self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
}

#pragma mark- update

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // Stop view from moving if a sign is present
   /* if(([[self childNodeWithName:@"rightEdge"] intersectsNode:[self childNodeWithName:@"sign1"]] ) || ([[self childNodeWithName:@"rightEdge"] intersectsNode:[self childNodeWithName:@"sign2"]] ) ){
        self.shouldMove = NO;
    }*/

    //Watch the enemy's movement
    self.lastBeat = playerBack->msElapsedSinceLastBeat;
    double closestBeat = (playerBack->closestBeatMs(CACurrentMediaTime()*1000, 0)) - CACurrentMediaTime()*1000;
//    NSLog(@"Closest Beat : %f", closestBeat - CACurrentMediaTime()*1000);
//    NSLog(@"last beat:%f, bpm:%f", self.lastBeat, closestBeat);
    if(self.lastBeat == (60.0f/self.BPM)*1000){
        NSLog(@"2Beat");
    }
//    NSLog(@"Since last beat: %f", self.lastBeat);
    if(!self.gameOver){
        for(Enemy *enemy in self.moveablesArray){
            if([enemy intersectsNode:[self childNodeWithName:@"player"]]&&!enemy.hidden&&(enemy.zPosition==1.0f))
            {
                self.player.health--;
                enemy.health = 0;
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
        
        for (Enemy *enemy in self.enemyArray)
        {
            if (enemy.hidden) {
                continue;
            }
            
            if([self childNodeWithName:@"watergun"] && [enemy intersectsNode:[self childNodeWithName:@"watergun"]]){
                enemy.health -= 20;
                [[self childNodeWithName:@"watergun"] removeFromParent];
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
                
                for (EnemyShot *shot in self.enemyShotArray)
                {
                    if (shot.hidden) {
                        continue;
                    }

                }


            }
            
            if([self childNodeWithName:[NSString stringWithFormat: @"%@AttackLabel", enemy.name]]){
                SKLabelNode *attackLabel = (SKLabelNode *)[self childNodeWithName:[NSString stringWithFormat: @"%@AttackLabel", enemy.name]];
                attackLabel.position = CGPointMake(enemy.position.x, enemy.position.y + 10);
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
                        self.player.health -= shot.damage;
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
                SKSpriteNode *enemyHealthBar = (SKSpriteNode*)[enemy childNodeWithName:[NSString stringWithFormat:@"%@Bar", enemy.name]];
                //enemyHealthLabel.text = [NSString stringWithFormat:@"%.2f", enemy.health];
                //enemyHealthBar.size = CGSizeMake(enemy.health/enemy.healthMax * 50, 10);
                SKAction *resizeHealth = [SKAction resizeToWidth:(enemy.health/enemy.healthMax * 50) duration:0.1f];
                [enemyHealthBar runAction:resizeHealth];
                //enemyHealthLabel.position = CGPointMake(CGRectGetMidX(enemy.frame) - enemyHealthLabel.size.width/2, CGRectGetMaxY(enemy.frame) + enemyHealthLabel.size.height/2 + 5);
            }else if (enemy.health <= 0){
                enemy.canShoot = NO;
                enemy.hidden = YES;
                [self.enemyToDeleteArray addObject:enemy];
                [enemy removeFromParent];
                [enemy childNodeWithName:[NSString stringWithFormat:@"%@Bar", enemy.name]].hidden = YES;
                [self checkRoomTransitions];
            }else{
                enemy.canShoot = NO;
                SKSpriteNode *enemyHealthBar = (SKSpriteNode*)[enemy childNodeWithName:[NSString stringWithFormat:@"%@Bar", enemy.name]];
                enemyHealthBar.alpha = 0.0f;
                enemyHealthBar.hidden = YES;
            }

        }

        //Update the touch held length && check interactables
        if(self.touchDown){
            self.touchLength = CACurrentMediaTime() - self.touchBegan;
            if(self.currentKeyDown){
              //[self checkInteractables:self.currentKeyDown];
            }
        }else{
            self.touchLength = 0;
        }
        
    
        SKAction *resizeHealth = [SKAction resizeToWidth:((self.player.health/self.player.healthMax) * self.healthBarFillMaxWidth) duration:0.2f];
        [self.healthBarFill runAction:resizeHealth];
        
        
        float keyNodeHeight = [self childNodeWithName:@"lowCNode"].frame.size.height - 1;
        SKSpriteNode *fireBar = (SKSpriteNode *)[self childNodeWithName:@"lowCNodeMPBAR"];
        SKAction *resizeMPBar = [SKAction resizeToHeight:((self.player.fireMP/self.player.fireMPMax) * keyNodeHeight) duration:0.2];
        [fireBar runAction:resizeMPBar];
        
        SKSpriteNode *windBar = (SKSpriteNode *)[self childNodeWithName:@"lowDNodeMPBAR"];
        SKAction *resizeMPBarWind = [SKAction resizeToHeight:((self.player.windMP/self.player.windMPMax) * keyNodeHeight) duration:0.2];
        [windBar runAction:resizeMPBarWind];
        
        SKSpriteNode *waterBar = (SKSpriteNode *)[self childNodeWithName:@"lowENodeMPBAR"];
        SKAction *resizeMPBarWater = [SKAction resizeToHeight:((self.player.waterMP/self.player.waterMPMax) * keyNodeHeight) duration:0.2];
        [waterBar runAction:resizeMPBarWater];
        
        SKSpriteNode *earthBar = (SKSpriteNode *)[self childNodeWithName:@"lowFNodeMPBAR"];
        SKAction *resizeMPBarEarth = [SKAction resizeToHeight:((self.player.earthMP/self.player.earthMPMax) * keyNodeHeight) duration:0.2];
        [earthBar runAction:resizeMPBarEarth];
        
        SKSpriteNode *musicBar = (SKSpriteNode *)[self childNodeWithName:@"lowGNodeMPBAR"];
        SKAction *resizeMPBarMusic = [SKAction resizeToHeight:((self.player.musicMP/self.player.musicMPMax) * keyNodeHeight) duration:0.2];
        [musicBar runAction:resizeMPBarMusic];
        
        self.playerHealthLabel.text = [NSString stringWithFormat:@"Player Health: %.2f", self.player.health];

        if(self.player.health <= 0){
            self.gameOver = YES;
            [self gameOver:@"playerDied"];
            self.player.health = 0;
            SKAction *resizeHealth = [SKAction resizeToWidth:((self.player.health/self.player.healthMax) * self.healthBarFillMaxWidth) duration:0.2f];
            [self.healthBarFill runAction:resizeHealth];
        }
    }
    
    [self removeDefeatedEnemies];
}


#pragma mark- tempo methods

/**
 * Used to keep track of the beat. Attempts to adjust any delay due to framerate lag
 */
-(void)beatTimer: (NSTimer *) timer{
    NSLog(@"Beat");
    double lastBeat = playerBack->msElapsedSinceLastBeat;

    if(lastBeat < 100){
//        NSLog(@"Delay:%f", ((60.00f/self.BPM) - (lastBeat * 0.001)));
        [self performSelector:@selector(beatTimer:) withObject:nil afterDelay:((60.00f/self.BPM) - (lastBeat * 0.001))];
    }else if(lastBeat > 460 && lastBeat < 480){
//        NSLog(@"Delay:%f", ((60.00f/self.BPM) + ((480 - lastBeat) * 0.001)));
        [self performSelector:@selector(beatTimer:) withObject:nil afterDelay:((60.00f/self.BPM) + ((480 - lastBeat) * 0.001))];
    }else{
        
        [self performSelector:@selector(beatTimer:) withObject:nil afterDelay:(60.00f/self.BPM)];

    }
    
    [self beat];
    
}


-(void)gameOver: (NSString *)reason{
    
    if([reason isEqualToString:@"playerDied"]){
        self.player.hidden = YES;
    }
}

/**
 * Called with every beat in the music
 */
-(void)beat{

    if(self.firstBeat){
        //[backgroundChannel play:backgroundBuffer loop:YES];

        pthread_mutex_lock(&mutex);
        playerBack->play(YES);
        playerC->play(YES);
        playerD->play(YES);
        playerE->play(YES);
        playerF->play(YES);
        playerG->play(YES);
        [self silenceLowKeys];
        pthread_mutex_unlock(&mutex);
        volG = 0.5;
        [self hideDefenseMarkers];
        self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];

    }
    
    if(self.filterInt < 8){
        
        if(self.filterInt == 0){
            [self sleepCombo];
        }
        //Increase the player's health by a tenth of his health
       /* if(self.attackMP < self.attackMPMax - 0.125){
            self.attackMP += 0.125;
        }else{
            self.attackMP = self.attackMPMax;
        }
        
        if(self.defenseMP < self.defenseMPMax - 0.125){
            self.defenseMP += 0.125;
        }else{
            self.defenseMP = self.defenseMPMax;
        }*/
        
        self.filterInt++;
        if(self.filterInt <= 3){
            filter->setResonantParameters(floatToFrequency(0.4), 0.1f);
        }else{
            filter->setResonantParameters(floatToFrequency(0.4 + (self.filterInt/10.0f - 0.3)), 0.1f);
        }
    }else{
        self.filterInt = 100;
        filter->enable(false);
        [self endSleepCombo];
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
    
    
    if(self.beatCount%12 == 0){
       // [self enemyAttack];
        [self refillMP:@"All" by: 1];

    }
    
    if(self.beatCount%24 == 0){
        [self enemyAttack:@{}];
    }
    
    self.firstBeat = NO;
    
    
    /*SKNode *camera = [self childNodeWithName:@"//camera"];
     SKAction *moveCamera = [SKAction moveByX:([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:0];
     [camera runAction:moveCamera];
     [self centerOnNode:camera];*/
}

/**
 * Refills each MP bar by the amount specified
 * @param amount The amount to fill each MP bar
 */
-(void)refillMP:(NSString *)bar by:(float)amount{
    if([bar isEqualToString:@"All"]){
        if(self.player.fireMP <= self.player.fireMPMax - 1){
            self.player.fireMP += amount;
        }
        if(self.player.waterMP <= self.player.waterMPMax - 1){
            self.player.waterMP += amount;
        }
        if(self.player.windMP <= self.player.windMPMax - 1){
            self.player.windMP += amount;
        }
        if(self.player.earthMP <= self.player.earthMPMax - 1){
            self.player.earthMP += amount;
        }
        if(self.player.musicMP <= self.player.musicMPMax - 1){
            self.player.musicMP += amount;
        }
    }
}

/**
 * Hides any Guitar Hero style defense markers floating down the screen. Called once the enemy's attack is over
 */
-(void)hideDefenseMarkers{
    self.defending = NO;
    [self enumerateChildNodesWithName:@"*Marker" usingBlock:^(SKNode *node, BOOL *stop) {
        node.hidden = YES;
        node.zPosition = -10.0f;
    }];
    self.keyPressArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
    [self setAvailableComboNotes];
}

/**
 * Shows all Guitar Hero style defense markers floating down the screen. Called at the beginning of the enemy's atack
 */
-(void)showDefenseMarkers{
    self.defending = YES;
    SKLabelNode *defendLabel = [SKLabelNode labelNodeWithText:@"Defend!"];
    defendLabel.position = CGPointMake([self childNodeWithName:@"dMarker"].position.x, self.scene.frame.size.height/1.5);
    defendLabel.fontName = @"MorrisRoman-Black";
    [defendLabel setFontSize: 40.0f];
    [defendLabel setFontColor:[UIColor blueColor]];
    [self.scene addChild:defendLabel];
    SKAction *fade = [SKAction fadeAlphaTo:0.0f duration:2.0f*(60.0f/self.BPM)];
    [defendLabel runAction:fade completion:^{
        [defendLabel removeFromParent];
    }];
    
    [self enumerateChildNodesWithName:@"*Marker" usingBlock:^(SKNode *node, BOOL *stop) {
        node.hidden = NO;
        node.zPosition = 2.0f;
    }];
    
}

#pragma mark- Move Player

/**
 * Moves the player across the screen to the specified key node
 * @param keyNode The key node we wish to move the player to
 */
-(void)movePlayer:(NSString *)keyNode{

    if([self.player.mode isEqualToString:@"Bag"] && self.shouldPlayerMove){
        
        if([self.player actionForKey:@"movePlayer"]){
            [self.player removeActionForKey:@"movePlayer"];
        }
        
        SKSpriteNode *keySprite = (SKSpriteNode *)[self childNodeWithName:keyNode];
        double distance = fabs(CGRectGetMidX(keySprite.frame) - self.player.position.x);
        
        //calculate your new duration based on the distance
        float moveDuration = 0.005*distance;
        
        SKAction *movePlayer = [SKAction moveTo:CGPointMake(CGRectGetMidX(keySprite.frame), CGRectGetMidY(self.frame)-5) duration:moveDuration];
        
        [self.player runAction:movePlayer withKey:@"movePlayer"];
        [self.player walkAdagio];
    }
    
}

/**
 *
 */
-(void)getPlayerCurrentKey{
    for(SKSpriteNode *key in self.keyArray){
        if((self.player.position.x > CGRectGetMinX(key.frame))&&(self.player.position.x < CGRectGetMaxX(key.frame))){
            self.currentPlayerKey = key.name;
        }
    }
}

#pragma mark- Enemy Methods

/**
 * Used to move enemies across the screen on beat
 */
-(void)moveEnemies{
    
    SKAction *moveAngle = [[SKAction alloc] init];
    for(Enemy *enemy in self.enemyArray){
        
        
        if([enemy.type isEqualToString:@"scooter"] && enemy.canMove){
            [enemy moveEnemy:self.enemyMoveInt withBPM:self.BPM];
        }
    }
    
    switch (self.enemyMoveInt) {
        case 1:
        {
            self.enemyMoveInt++;
            moveAngle = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:(60.0f/self.BPM)/2.0f];
            
            break;
        }
        case 2:
        {
            self.enemyMoveInt++;
            moveAngle = [SKAction moveByX:-([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:(60.0f/self.BPM)/2.0f];

            break;
        }
        case 3:
        {
            self.enemyMoveInt++;
            moveAngle = [SKAction moveByX:([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:(60.0f/self.BPM)/2.0f];

            
            break;
        }
        case 4:
        {
            self.enemyMoveInt = 1;
            moveAngle = [SKAction moveByX:([[UIScreen mainScreen] bounds].size.width/12) y:0 duration:(60.0f/self.BPM)/2.0f];

            break;
        }
        default:
            break;
    }

    
    
    for(Enemy *enemy in self.moveablesArray){
        
            if([enemy.type isEqualToString:@"scooter"] && enemy.canMove){

            }else if([enemy.type isEqualToString:@"angle"] && enemy.canMove){
                [enemy runAction:moveAngle];
            }
        
    }
    
}

/**
 * Used to start the Guitar Hero styled Enemy Attack
 */
-(void)enemyAttack:(NSMutableDictionary *) enemyAttack{
    
    for(Enemy *enemy in self.enemyArray){
        if(enemy.canShoot && !enemy.hidden && enemy.attackDictionary != nil){
            [self resetCombos];
            [self showDefenseMarkers];
            enemyAttack = enemy.attackDictionary;
            [enemyAttack setObject:[enemyAttack objectForKey:@"maxAttackDamage"] forKey:@"currentAttackDamage"];
            
            for(id key in enemyAttack){
                NSString *keyString = [NSString stringWithFormat:@"%@", key];
                if([keyString isEqualToString:@"end"]){
                    
                    [self performSelector:@selector(hideDefenseMarkers) withObject:nil afterDelay:([[enemyAttack objectForKey:key] floatValue] * (60.0f/self.BPM))];
                    [self performSelector:@selector(enemyAttack) withObject:nil afterDelay:([[enemyAttack objectForKey:key] floatValue] * (60.0f/self.BPM))];
                    
                }else if([keyString isEqualToString:@"name"]){
                    
                    SKLabelNode *attackNameLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica-Bold"];
                    attackNameLabel.text = [enemyAttack objectForKey:@"name"];
                    attackNameLabel.fontSize = 20.0f;
                    attackNameLabel.zPosition = enemy.zPosition + 0.1;
                    attackNameLabel.name = [NSString stringWithFormat:@"%@AttackLabel", enemy.name];
                    attackNameLabel.position = CGPointMake(enemy.position.x, enemy.position.y + 10);
                    [self.scene addChild:attackNameLabel];

                }else if (![keyString isEqualToString:@"currentAttackDamage"] && ![keyString isEqualToString:@"maxAttackDamage"]){
                    CGSize markerSize = [self childNodeWithName:@"aMarker"].frame.size;
                    NSString *firstLetter = [key substringToIndex:1];
                    NSString *markerName = [NSString stringWithFormat:@"%@Marker", firstLetter];
                    SKSpriteNode *attackNote = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"circle.png"] size:markerSize];
                    attackNote.position = CGPointMake(CGRectGetMidX([self childNodeWithName:markerName].frame), self.scene.size.height + attackNote.frame.size.height);
                    attackNote.alpha = 0.8f;
                    attackNote.zPosition = 2.0f;
                    attackNote.name = [NSString stringWithFormat:@"%@", [key uppercaseString]];
                    [self.scene addChild:attackNote];
                    SKAction *delayNote = [SKAction waitForDuration:([[enemyAttack objectForKey:key] floatValue] * (60.0f/self.BPM))];
                    [attackNote runAction:delayNote completion:^{
                        SKAction *moveNote = [SKAction moveToY:([self childNodeWithName:markerName].frame.origin.y + attackNote.frame.size.height/2.0f) duration:(4.0f * (60.0f/self.BPM))];
                        [attackNote runAction:moveNote completion:^{
                            double delay = playerBack->msElapsedSinceLastBeat;
                            //                NSLog(@"Delay:%f", delay);
                            SKAction *moveNoteDown = [SKAction moveToY:-attackNote.frame.size.height duration:(4.00f* (60.0f/self.BPM))];
                            [attackNote runAction:moveNoteDown completion:^{
                                
                                [attackNote removeFromParent];
                            }];
                            
                        }];
                    }];
                    
                }
            }
        }
    }
    
}

/**
 * Performs the actual physical enemy attack, such as shooting needles
 */
-(void)enemyAttack{
    
    [self enumerateChildNodesWithName:@"*AttackLabel" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    for(Enemy *enemy in self.enemyArray)
    {
        
        if([[enemy.attackDictionary objectForKey:@"currentAttackDamage"] floatValue] < 0.01f){
            SKLabelNode *blockedAttack = [SKLabelNode labelNodeWithText:@"Blocked!"];
            blockedAttack.position = enemy.position;
            blockedAttack.zPosition = enemy.zPosition + 0.1f;
            [self.scene addChild:blockedAttack];
            SKAction *moveUp = [SKAction moveByX:0 y:10.0f duration:0.2f];
            SKAction *fade = [SKAction fadeAlphaTo:0.0f duration:0.2f];
            SKAction *moveUpAndFade = [SKAction group:@[moveUp, fade]];
            [blockedAttack runAction:moveUpAndFade completion:^{
                [blockedAttack removeFromParent];
            }];
            
        }else{
            
            if([enemy.type isEqualToString:@"angle"] && enemy.canShoot && !enemy.hidden)
            {
                NSLog(@"Enemy attack dictionary:%@", enemy.attackDictionary);
                EnemyShot *spike = [EnemyShot spriteNodeWithImageNamed:@"angleShot.png"];
                spike.damage = [[enemy.attackDictionary objectForKey:@"currentAttackDamage"] floatValue];
                spike.size = CGSizeMake(15, 10);
                spike.position = CGPointMake(enemy.position.x-spike.size.width/2,enemy.position.y);
                spike.name = @"angle";
                [self addChild:spike];

                SKAction *laserMoveAction = [SKAction moveByX:-self.frame.size.width y:0 duration:2.0f];
                SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
                    spike.hidden = YES;
                    [spike removeFromParent];
                }];
                
                SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
                
                [spike runAction:moveLaserActionWithDone withKey:@"laserFired"];
                [self.enemyShotArray addObject:spike];
                
            }else if([enemy.type isEqualToString:@"boss"] && enemy.canShoot && !enemy.hidden){
               // [self.enemyShotArray removeAllObjects];
                EnemyShot *spike = [EnemyShot spriteNodeWithImageNamed:@"fireball.png"];
                spike.texture = [SKTexture textureWithImageNamed:@"fireball.png"];
                spike.damage = 1.0f;
                
                spike.size = CGSizeMake(15, 10);
                spike.position = CGPointMake(enemy.position.x-spike.size.width/2,enemy.position.y);
                spike.note = [self getRandomNote];
                [self addChild:spike];
                
                SKLabelNode *noteLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
                noteLabel.text = spike.note;
                [spike addChild:noteLabel];
                noteLabel.position = CGPointMake(0, 10);
                [self.enemyShotArray addObject:spike];

                EnemyShot *spike2 = [EnemyShot spriteNodeWithImageNamed:@"fireball.png"];
                spike2.texture = [SKTexture textureWithImageNamed:@"fireball.png"];
                spike2.damage = 1.0f;
                
                spike2.size = CGSizeMake(15, 10);
                spike2.position = CGPointMake(enemy.position.x-spike.size.width/2,enemy.position.y);
                spike2.note = [self getRandomNote];
                [self addChild:spike2];
                spike2.alpha = 0.0f;
                SKLabelNode *note2Label = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
                note2Label.text = spike2.note;
                [spike2 addChild:note2Label];
                note2Label.position = CGPointMake(0, 10);
                [self.enemyShotArray addObject:spike2];

                EnemyShot *spike3 = [EnemyShot spriteNodeWithImageNamed:@"fireball.png"];
                spike3.texture = [SKTexture textureWithImageNamed:@"fireball.png"];
                spike3.damage = 1.0f;
                
                spike3.size = CGSizeMake(15, 10);
                spike3.position = CGPointMake(enemy.position.x-spike.size.width/2,enemy.position.y);
                spike3.note = [self getRandomNote];
                [self addChild:spike3];
                spike3.alpha = 0.0f;
                SKLabelNode *note3Label = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
                note3Label.text = spike3.note;
                [spike3 addChild:note3Label];
                note3Label.position = CGPointMake(0, 10);
                [self.enemyShotArray addObject:spike3];

                SKAction *laserMoveAction = [SKAction moveByX:-self.frame.size.width y:0 duration:2.0f];
                SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
                    spike.hidden = YES;
                    [self.enemyShotArray removeObject:spike];
                    [spike removeFromParent];
                }];
                
                SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
                [spike runAction:moveLaserActionWithDone withKey:@"spike1Fired"];
                
                SKAction *wait = [SKAction waitForDuration:0.8];
                [spike2 runAction:wait completion:^{
                    spike2.alpha = 1.0f;
                    SKAction *laserMoveAction = [SKAction moveByX:-self.frame.size.width y:0 duration:2.0f];
                    SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
                        spike2.hidden = YES;
                        [self.enemyShotArray removeObject:spike2];
                        [spike2 removeFromParent];
                    }];
                    
                    SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
                    [spike2 runAction:moveLaserActionWithDone withKey:@"spike2Fired"];

                }];
                
                SKAction *wait2 = [SKAction waitForDuration:1.6];
                [spike3 runAction:wait2 completion:^{
                    spike3.alpha = 1.0f;
                    SKAction *laserMoveAction = [SKAction moveByX:-self.frame.size.width y:0 duration:6.0f];
                    SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
                        spike3.hidden = YES;
                        [self.enemyShotArray removeObject:spike3];
                        [spike3 removeFromParent];
                    }];
                    
                    SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
                    [spike3 runAction:moveLaserActionWithDone withKey:@"spike3Fired"];
                }];
                

            }
        }
        
        
    }
}

/**
 * Returns a random melodic note
 */
-(NSString *)getRandomNote{
    
    NSArray *noteArray = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];
    return [noteArray objectAtIndex: arc4random() % [noteArray count]];
}

/**
 * Removes any defeated enemies from the scene
 */
-(void)removeDefeatedEnemies{
    
    for(Enemy *enemy in self.enemyToDeleteArray){
        [self.enemyArray removeObject:enemy];
    }
    
    if(self.enemyToDeleteArray.count > 0){
        [self.enemyToDeleteArray removeAllObjects];
    }
    
}

#pragma mark - Keyboard Key Nodes

//THE LOW KEYS ON THE KEYBOARD

-(SKSpriteNode *)lowCNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.alpha = 0.0;
    keyNode.name = @"lowCNode";//how the node is identified later
    keyNode.zPosition = 3.0;
    
    return keyNode;
}

- (SKSpriteNode *)lowDNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.alpha = 0.0f;
    keyNode.position = CGPointMake(1*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"lowDNode";//how the node is identified later
    keyNode.zPosition = 3.0;
    return keyNode;
}

- (SKSpriteNode *)lowENode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(2*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.alpha = 0.0f;
    keyNode.name = @"lowENode";//how the node is identified later
    keyNode.zPosition = 3.0;
    return keyNode;
}


-(SKSpriteNode *)lowFNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake([[UIScreen mainScreen] bounds].size.width/12, [[UIScreen mainScreen] bounds].size.height/2.25)];
    keyNode.position = CGPointMake(3*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.alpha = 0.0f;
    keyNode.name = @"lowFNode";//how the node is identified later
    keyNode.zPosition = 3.0;
    return keyNode;
}

-(SKSpriteNode *)lowGNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake([[UIScreen mainScreen] bounds].size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(4*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5,(self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.alpha = 0.0f;
    keyNode.name = @"lowGNode";//how the node is identified later
    keyNode.zPosition = 3.0;
    return keyNode;
}

//THE HIGH KEYS ON THE KEYBOARD

- (SKSpriteNode *)highANode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(5*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highANode";//how the node is identified later
    keyNode.alpha = 0.3f;
    keyNode.zPosition = 3.0;
    
    
    SKSpriteNode *aMarker = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"EMPTYCIRCLEBLUE.png"] size:CGSizeMake(keyNode.frame.size.width - 10, keyNode.frame.size.width - 10)];
    aMarker.position = CGPointMake(CGRectGetMidX(keyNode.frame), CGRectGetMaxY(keyNode.frame) - (aMarker.frame.size.height/2.0f) - 3);
    aMarker.name = @"aMarker";
    aMarker.zPosition = 2.0f;
    [self.scene addChild:aMarker];
    
    
    
    return keyNode;
}

- (SKSpriteNode *)highBNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(6*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5,(self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highBNode";//how the node is identified later
    keyNode.zPosition = 3.0;
    keyNode.alpha = 0.3f;
    SKSpriteNode *Marker = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"EMPTYCIRCLEBLUE.png"] size:CGSizeMake(keyNode.frame.size.width - 10, keyNode.frame.size.width - 10)];
    
    Marker.position = CGPointMake(CGRectGetMidX(keyNode.frame), CGRectGetMaxY(keyNode.frame) - Marker.frame.size.height/2.0f  - 3);
    Marker.name = @"bMarker";
    Marker.zPosition = 2.0f;
    [self.scene addChild:Marker];
    return keyNode;
}

- (SKSpriteNode *)highCNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(7*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.alpha = 0.3f;
    keyNode.name = @"highCNode";//how the node is identified later
    keyNode.zPosition = 3.0;
    
    SKSpriteNode *Marker = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"EMPTYCIRCLEBLUE.png"] size:CGSizeMake(keyNode.frame.size.width - 10, keyNode.frame.size.width - 10)];
    Marker.position = CGPointMake(CGRectGetMidX(keyNode.frame), CGRectGetMaxY(keyNode.frame) - Marker.frame.size.height/2.0f  - 3);
    Marker.name = @"cMarker";
    Marker.zPosition = 2.0f;
    [self.scene addChild:Marker];
    return keyNode;
}

- (SKSpriteNode *)highDNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(8*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.alpha = 0.3f;
    keyNode.name = @"highDNode";//how the node is identified later
    keyNode.zPosition = 3.0;
    
    SKSpriteNode *Marker = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"EMPTYCIRCLEBLUE.png"] size:CGSizeMake(keyNode.frame.size.width - 10, keyNode.frame.size.width - 10)];
    Marker.position = CGPointMake(CGRectGetMidX(keyNode.frame), CGRectGetMaxY(keyNode.frame) - Marker.frame.size.height/2.0f  - 3);
    Marker.name = @"dMarker";
    Marker.zPosition = 2.0f;
    [self.scene addChild:Marker];
    return keyNode;
}

- (SKSpriteNode *)highENode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(9*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.alpha = 0.3f;
    keyNode.name = @"highENode";//how the node is identified later
    keyNode.zPosition = 3.0;
    
    SKSpriteNode *Marker = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"EMPTYCIRCLEBLUE.png"] size:CGSizeMake(keyNode.frame.size.width - 10, keyNode.frame.size.width - 10)];
    Marker.position = CGPointMake(CGRectGetMidX(keyNode.frame), CGRectGetMaxY(keyNode.frame) - Marker.frame.size.height/2.0f  - 3);
    Marker.name = @"eMarker";
    Marker.zPosition = 2.0f;
    [self.scene addChild:Marker];
    return keyNode;
}

- (SKSpriteNode *)highFNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(10*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highFNode";//how the node is identified later
    keyNode.alpha = 0.3f;
    keyNode.zPosition = 3.0;
    
    SKSpriteNode *Marker = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"EMPTYCIRCLEBLUE.png"] size:CGSizeMake(keyNode.frame.size.width - 10, keyNode.frame.size.width - 10)];
    Marker.position = CGPointMake(CGRectGetMidX(keyNode.frame), CGRectGetMaxY(keyNode.frame) - Marker.frame.size.height/2.0f  - 3);
    Marker.name = @"fMarker";
    Marker.zPosition = 2.0f;
    [self.scene addChild:Marker];
    return keyNode;
}

-(SKSpriteNode *)highGNode
{
    SKTexture *keyTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"blankKey"]];
    SKSpriteNode *keyNode = [SKSpriteNode spriteNodeWithTexture:keyTexture size:CGSizeMake(self.frame.size.width/12, self.frame.size.height/2.25)];
    keyNode.position = CGPointMake(11*self.yPositionIncrement + ([[UIScreen mainScreen] bounds].size.width/12)*0.5, (self.frame.size.height/2) - (self.frame.size.height/3.4));
    keyNode.name = @"highGNode";//how the node is identified later
    keyNode.alpha = 0.3f;
    keyNode.zPosition = 3.0;
    
    SKSpriteNode *Marker = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"EMPTYCIRCLEBLUE.png"] size:CGSizeMake(keyNode.frame.size.width - 10, keyNode.frame.size.width - 10)];
    Marker.position = CGPointMake(CGRectGetMidX(keyNode.frame), CGRectGetMaxY(keyNode.frame) - Marker.frame.size.height/2.0f - 3);
    Marker.name = @"gMarker";
    Marker.zPosition = 2.0f;
    [self.scene addChild:Marker];
    return keyNode;
}

-(void)addKeyNameLabel: (NSString *)keyName{
    SKSpriteNode *keyNode = (SKSpriteNode *)[self childNodeWithName:keyName];
    NSRange highRange = [keyName rangeOfString:@"high"];
    NSRange lowRange = [keyName rangeOfString:@"low"];
    NSString *keyLetter;
    if(highRange.length > 0){
        NSLog(@"high range:%@", NSStringFromRange( highRange));

    }
    if(highRange.length > 0){
        keyLetter = [keyName substringWithRange:NSMakeRange(highRange.length, 1)];
    }else if(lowRange.length > 0){
        keyLetter = [keyName substringWithRange:NSMakeRange(lowRange.length, 1)];

    }
    SKLabelNode *keyNameLabel = [SKLabelNode labelNodeWithText:keyLetter];
    keyNameLabel.fontColor = [UIColor whiteColor];
    keyNameLabel.position = CGPointMake(keyNode.position.x, CGRectGetMinY(keyNode.frame) + 10);
    keyNameLabel.name = [NSString stringWithFormat:@"%@Label", keyName];
    [self addChild:keyNameLabel];
    keyNameLabel.zPosition = keyNode.zPosition - 0.1;
}

#pragma mark- Cutscenes

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
    playerE->process(stereoBuffer, !silence, numberOfSamples, volE, masterBpm, msElapsedSinceLastBeatA);
    playerF->process(stereoBuffer, !silence, numberOfSamples, volF, masterBpm, msElapsedSinceLastBeatA);
    playerG->process(stereoBuffer, !silence, numberOfSamples, volG, masterBpm, msElapsedSinceLastBeatA);
    
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

/**
 * Loads the specified room number
 */
-(void)loadNextRoom:(int)roomNumber{
    [self hideDefenseMarkers];
    [self removeChildrenInArray:self.enemyArray];
    [self removeChildrenInArray:self.interactableArray];
    [self removeChildrenInArray:self.propArray];
    self.enemyArray = [NSMutableArray arrayWithObjects: nil];
    self.interactableArray = [NSArray arrayWithObjects: nil];
    self.propArray = [NSMutableArray arrayWithObjects: nil];
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

/**
 * The user has moved backwards into the previous room
 */
-(void)loadPreviousRoom:(int)roomNumber{
    [self hideDefenseMarkers];
    [self removeChildrenInArray:self.enemyArray];
    [self removeChildrenInArray:self.interactableArray];
    [self removeChildrenInArray:self.propArray];
    self.enemyArray = [NSMutableArray arrayWithObjects: nil];
    self.interactableArray = [NSArray arrayWithObjects: nil];
    self.propArray = [NSMutableArray arrayWithObjects: nil];
    
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

/**
 * The user has moved forward into the next room
 */
-(void)loadRoom:(int)roomNumber{
    
    self.enemyMoveInt = 1;
    
    if(self.currentRoomNumber == 1){
        
        Interactable *sign1 = [[Interactable alloc] init];
        [sign1 setTexture:[SKTexture textureWithImageNamed:@"signPost.png"]];
        sign1.name = @"sign1";
        sign1.displayText = @"Welcome to the Pink Forest!";
        sign1.keyNode = @"highDNode";
        sign1.size = CGSizeMake(40,40);
        sign1.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highENode"].frame), CGRectGetMaxY([self childNodeWithName:@"highENode"].frame) + sign1.size.height/2 - 5);
        sign1.type = @"sign";
        sign1.zPosition = 0.0f;
        [self addChild:sign1];
        
        self.interactableArray = [NSArray arrayWithObjects:sign1, nil];
        
        
    }else if(self.currentRoomNumber == 2){
        if(self.roomCleared < 2){
            self.roomCleared = 1;
        }
        
        Enemy *enemy1 = [Enemy spriteNodeWithImageNamed:@"scooter.png"];
        enemy1.name = @"enemy1";
        enemy1.size = CGSizeMake(50,50);
        enemy1.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highENode"].frame), CGRectGetMaxY([self childNodeWithName:@"highENode"].frame) + enemy1.size.height/2 + 10);
        enemy1.zPosition = 1.0f;
        enemy1.health = 100;
        enemy1.healthMax = 100;
        enemy1.hidden = NO;
        enemy1.type = @"scooter";
        enemy1.canMove = YES;
        enemy1.canShoot = YES;
        enemy1.sleepChance = 2;
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
        
        Enemy *enemy2 = [Enemy spriteNodeWithImageNamed:@"angle.png"];
        enemy2.name = @"enemy2";
        enemy2.size = CGSizeMake(50,50);
        enemy2.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highFNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highFNode"].frame) + enemy2.frame.size.height/2.3);
        enemy2.zPosition = 1.0f;
        enemy2.health = 150;
        enemy2.healthMax = 150;
        enemy2.attackDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"denemy2":@1.0, @"eenemy2":@2.0, @"fenemy2":@3.0, @"end":@8.5, @"name":@"💢", @"maxAttackDamage":@2.0, @"currentAttackDamage":@2.0}];
        enemy2.hidden = NO;
        enemy2.canShoot = YES;
        enemy2.canMove = YES;
        enemy2.sleepChance = 2;
        enemy2.type = @"angle";
        enemy2.resonantArray = @[@"highANode", @"highBNode", @"highCNode", @"highDNode"];
        [self addChild:enemy2];
        self.enemyArray = [NSMutableArray arrayWithObjects:enemy2, nil];
        enemy2.arrayPosition = 0;
        self.moveablesArray = [NSArray arrayWithObjects:enemy2, nil];
        
    }else if(self.currentRoomNumber == 4){
        if(self.roomCleared < 3)
        {
            self.roomCleared = 3;
        }
        
        
        Enemy *enemy1 = [Enemy spriteNodeWithImageNamed:@"angle.png"];
        enemy1.name = @"enemy1";
        enemy1.size = CGSizeMake(50,50);
        enemy1.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highDNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highFNode"].frame) + enemy1.frame.size.height/2.3);
        enemy1.zPosition = 1.0f;
        enemy1.health = 150;
        enemy1.healthMax = 150;
        enemy1.hidden = NO;
        enemy1.canShoot = YES;
        enemy1.canMove = YES;
        enemy1.sleepChance = 2;
        enemy1.type = @"angle";
        enemy1.attackDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"eenemy1":@1.0, @"fenemy1":@2.0, @"genemy1":@3.0, @"end":@8.75, @"name":@"💢", @"maxAttackDamage":@2.0, @"currentAttackDamage":@2.0}];
        enemy1.resonantArray = @[@"highANode", @"highBNode", @"highCNode", @"highDNode"];
        [self addChild:enemy1];
        
        Enemy *enemy2 = [Enemy spriteNodeWithImageNamed:@"angle.png"];
        enemy2.name = @"enemy2";
        enemy2.size = CGSizeMake(50,50);
        enemy2.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highFNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highFNode"].frame) + enemy2.frame.size.height/2.3);
        enemy2.zPosition = 1.0f;
        enemy2.health = 150;
        enemy2.healthMax = 150;
        enemy2.attackDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"cenemy2":@1.0, @"denemy2":@2.0, @"eenemy2":@3.0, @"end":@8.75, @"name":@"💢", @"maxAttackDamage":@2.0, @"currentAttackDamage":@2.0}];
        enemy2.hidden = NO;
        enemy2.canShoot = YES;
        enemy2.canMove = YES;
        enemy2.sleepChance = 2;
        enemy2.type = @"angle";
        enemy2.resonantArray = @[@"highANode", @"highBNode", @"highCNode", @"highDNode"];
        [self addChild:enemy2];
        
        self.enemyArray = [NSMutableArray arrayWithObjects:enemy1, enemy2, nil];
        enemy2.arrayPosition = 0;
        self.moveablesArray = [NSArray arrayWithObjects:enemy1, enemy2, nil];
    }else if(self.currentRoomNumber == 5){
        if(self.roomCleared < 4)
        {
            self.roomCleared = 4;
        }
        Interactable *cycleNPC = [[Interactable alloc] init];
        [cycleNPC setTexture:[SKTexture textureWithImageNamed:@"gaia1.png"]];
        NSString *deviceName = [[UIDevice currentDevice] name];
        NSString *personsName = @"John";
        NSRange range = [deviceName rangeOfString:@"'s"];
        if (range.location == NSNotFound) {
            NSLog(@"string was not found");
            personsName = deviceName;
        } else {
            NSLog(@"position %lu", (unsigned long)range.location);
            personsName = [deviceName substringToIndex:range.location];
        }
        cycleNPC.name = @"cycleinter";
        NSString *isYourNameString = [NSString stringWithFormat:@"Is your name... %@??", personsName];
        cycleNPC.textArray = @[isYourNameString, @"I'm the forest fortune teller. I'm usually pretty good."];
        cycleNPC.keyNode = @"highDNode";
        cycleNPC.size = CGSizeMake(63,75);
        cycleNPC.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highENode"].frame), CGRectGetMaxY([self childNodeWithName:@"highENode"].frame) + cycleNPC.size.height/2 - 8);
        cycleNPC.type = @"cycleNPC";
        cycleNPC.zPosition = 1.0f;
        cycleNPC.xScale = -1.0f;
        [self addChild:cycleNPC];
        
        self.interactableArray = @[cycleNPC];
    }else if(self.currentRoomNumber == 6){
        if(self.roomCleared < 5)
        {
            self.roomCleared = 5;
        }
        
        SKSpriteNode *treeSprite = [SKSpriteNode spriteNodeWithImageNamed:@"bigTree.png"];
        treeSprite.size = CGSizeMake(200, 400);
        treeSprite.name = @"treeSprite";
        treeSprite.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highFNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highFNode"].frame) + treeSprite.frame.size.height/2 - 3);
        [self addChild:treeSprite];
        [self.propArray addObject:treeSprite];

        
        Enemy *bigTree =[Enemy spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(60, 60)];
        bigTree.name = @"bigTree";
        bigTree.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highFNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highFNode"].frame) + 30);
        bigTree.zPosition = 1.0f;
        bigTree.health = 10000000000;
        bigTree.healthMax = 100000000;
        bigTree.hidden = NO;
        bigTree.canShoot = NO;
        bigTree.canMove = NO;
        bigTree.sleepChance = 2000000000;
        bigTree.type = @"tree";
        bigTree.resonantArray = @[@"highCNode", @"highANode", @"highBNode", @"highBNode", @"highANode", @"highGNode", @"highENode"];
        [self addChild:bigTree];

        
        Interactable *cycleNPC = [[Interactable alloc] init];
        [cycleNPC setTexture:[SKTexture textureWithImageNamed:@"evilBowtie.png"]];
        cycleNPC.name = @"cycleNPCinter";
        cycleNPC.textArray = @[@"Well, well, well. Looks like somebody finally made it all the way through the forest.", @"If you want to face the boss, you'll have to get past this tree here.", @"And nobody gets past this tree! Ha! Good luck sucker!"];
        cycleNPC.keyNode = @"highDNode";
        cycleNPC.size = CGSizeMake(40,40);
        cycleNPC.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highENode"].frame), CGRectGetMaxY([self childNodeWithName:@"highENode"].frame) + treeSprite.size.height/2 - cycleNPC.size.height);
        cycleNPC.type = @"cycleNPC";
        cycleNPC.zPosition = 1.0f;
        [self addChild:cycleNPC];
        self.interactableArray = @[cycleNPC];
        self.enemyArray = [NSMutableArray arrayWithObjects: bigTree, nil];
    }else if(self.currentRoomNumber == 7){
        if(self.roomCleared < 6)
        {
            self.roomCleared = 6;
        }
        
        
        Enemy *enemy1 = [Enemy spriteNodeWithImageNamed:@"orc01.png"];
        enemy1.name = @"boss";
        enemy1.size = CGSizeMake(72, 80);
        enemy1.position = CGPointMake(CGRectGetMidX([self childNodeWithName:@"highDNode"].frame), CGRectGetMaxY([self childNodeWithName:@"highFNode"].frame) + enemy1.size.height/2 - 10);
        enemy1.zPosition = 1.0f;
        enemy1.health = 500;
        enemy1.healthMax = 500;
        enemy1.hidden = NO;
        enemy1.canShoot = YES;
        enemy1.canMove = YES;
        enemy1.sleepChance = 3;
        enemy1.type = @"boss";
        enemy1.resonantArray = @[@"highANode", @"highBNode", @"highCNode", @"highDNode"];
        [self addChild:enemy1];
        self.enemyArray = [NSMutableArray arrayWithObjects:enemy1, nil];
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
            SKSpriteNode *enemyHealthBar = [SKSpriteNode spriteNodeWithImageNamed:@"loader_bar_red_fill.png"];
            enemyHealthBar.name = [NSString stringWithFormat:@"%@Bar", enemy.name];
            enemyHealthBar.size = CGSizeMake(50, 10);
            enemyHealthBar.position = CGPointMake(-enemyHealthBar.size.width/2, enemy.size.height/2 + enemyHealthBar.size.height);
            enemyHealthBar.anchorPoint = CGPointMake(0.0, 0.5);
            [enemy addChild:enemyHealthBar];
            [self.enemyHealthLabelArray addObject:enemyHealthBar];
            
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
