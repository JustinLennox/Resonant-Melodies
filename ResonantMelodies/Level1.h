//
//  Level1.h
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/26/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "Enemy.h"
#import "OALSimpleAudio.h"
#import "ObjectAL.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import "KeyLaser.h"
#import "CustomProgressBar.h"

#define highF @"wF.aif"

@interface Level1 : SKScene

//Player Properties
@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) NSString *currentHero;
@property (strong, nonatomic) SKSpriteNode *player;
@property (nonatomic) BOOL shouldPlayerMove;
@property (strong, nonatomic) NSString *currentPlayerKey;
@property (strong, nonatomic) SKSpriteNode *bowTie;
@property (nonatomic) int adagioHealthMax;
@property (nonatomic) int adagioLevel;
@property (nonatomic) int vifLevel;
@property (nonatomic) int brioLevel;
@property (strong, nonatomic) NSArray *attackArray;
@property (strong, nonatomic) NSArray *defenseArray;
@property (strong, nonatomic) NSArray *magicArray;
@property (nonatomic) float adagioMP;
@property (nonatomic) float adagioMaxMP;
@property (nonatomic) float vifMP;
@property (nonatomic) float vifMaxMP;
@property (nonatomic) float brioMP;
@property (nonatomic) float brioMaxMP;

@property (nonatomic) CGFloat playerMaxX;



//Touch Properties
@property (strong, nonatomic) NSMutableArray *touchArray;
@property (nonatomic, strong) NSMutableArray *sectionedTouchArray;
@property (nonatomic, strong) UILongPressGestureRecognizer *lpgr;

//Enemy Properties
@property (nonatomic) float enemyHealth;
@property (nonatomic) BOOL asteroidCreated;
@property (nonatomic) int asteroidCount;
@property (nonatomic) float enemySpeed;
@property (strong, nonatomic) NSMutableArray *enemyArray;
@property (strong, nonatomic) NSMutableArray *enemyHealthLabelArray;
@property (strong, nonatomic) NSMutableArray *enemyShotArray;

//Attack Properties
@property (nonatomic) float laserDamage;

//Combo Properties
@property (strong, nonatomic) NSMutableArray *fireballArray;
@property (nonatomic) BOOL flameOn;
@property (nonatomic) int filterInt;

//Keyboard Properties
@property (nonatomic) float yPositionIncrement;

//Labels
@property (strong, nonatomic) SKLabelNode *gigiHealthLabel;
@property (strong, nonatomic) SKSpriteNode *healthBar;
@property (strong, nonatomic) SKLabelNode *amosHealthLabel;
@property (strong, nonatomic) SKLabelNode *dvonHealthLabel;
@property (strong, nonatomic) SKLabelNode *adagioMPLabel;
@property (strong, nonatomic) SKLabelNode *brioMPLabel;

//Audio Properties
@property (strong, nonatomic) AVAudioPlayer *lowAAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowGAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowBAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowCAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowDAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowEAudioPlayer;
@property (strong, nonatomic) NSMutableArray *bufferStorageArray;
@property (strong, nonatomic) NSMutableDictionary *soundDictionary;

@property (nonatomic) SystemSoundID resonantSound1;
@property (nonatomic) SystemSoundID resonantSound2;
@property (nonatomic) SystemSoundID resonantSound3;
@property (nonatomic) SystemSoundID resonantSound4;

@property (nonatomic) float lastBeat;

//Game Properties
@property (nonatomic) int score;
@property (nonatomic) float randSecs;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) SKLabelNode *healthLabel;
@property (strong, nonatomic) NSString *difficulty;
@property (nonatomic) BOOL shouldMove;
@property (nonatomic, strong) NSArray *currentResonantArray;
@property (nonatomic, strong) NSMutableArray *keyPressArray;
@property (nonatomic) BOOL touchDown;
@property (strong, nonatomic) NSArray *interactableArray;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic) NSInteger intTmp;
@property (strong, nonatomic) NSMutableArray *keyLasers;
@property (strong, nonatomic) NSArray *moveablesArray;
@property (nonatomic) BOOL cutscene;
@property (nonatomic) BOOL shouldShoot;

@property (strong, nonatomic) NSString *currentKeyDown;

@property (nonatomic) float gigiHealth;
@property (nonatomic) float amosHealth;
@property (nonatomic) float dvonHealth;
@property (nonatomic) int currentHeroHealth;

@property (nonatomic) CGPoint location;

@property (strong, nonatomic) NSArray *keyArray;

@property (nonatomic) int currentRoomNumber;

@property (nonatomic) int enemyMoveInt;

@property (nonatomic) double touchBegan;
@property (nonatomic) double touchLength;
@property (nonatomic) BOOL touchingDown;

@property (nonatomic) float roomCleared;

//Partner Properties
@property (nonatomic) int bowTieIncrement;

//Tempo Settings
@property (nonatomic) float BPM;
@property (nonatomic) BOOL firstBeat;
@property (nonatomic) int beatCount;
@property (nonatomic) int measureCount;
@property (nonatomic) double beatTime;


@end
