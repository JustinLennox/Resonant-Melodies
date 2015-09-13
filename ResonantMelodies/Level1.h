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
#import "Hero.h"

@interface Level1 : SKScene

//Player Properties
@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) Hero *player;
@property (strong, nonatomic) SKNode *smallNode;
@property (nonatomic) BOOL shouldPlayerMove;
@property (strong, nonatomic) NSString *currentPlayerKey;

@property (nonatomic) CGFloat playerMaxX;

//Player Stats
@property (nonatomic) float playerHealth;
@property (nonatomic) float playerHealthMax;
@property (nonatomic) float playerExperience;
@property (nonatomic) float playerLevel;
@property (nonatomic) float playerToNextLevel;
@property (nonatomic) float playerMP;
@property (nonatomic) float playerMPMax;
@property (nonatomic) float attackMP;
@property (nonatomic) float attackMPMax;
@property (nonatomic) float magicMP;
@property (nonatomic) float magicMPMax;
@property (nonatomic) float defenseMP;
@property (nonatomic) float defenseMPMax;
@property (nonatomic) float attackLevel;
@property (nonatomic) float defenseLevel;
@property (nonatomic) float magicLevel;

//Combo Properties
@property (strong, nonatomic) NSArray *attackArray;
@property (strong, nonatomic) NSDictionary *attackDictionary;
@property (strong, nonatomic) NSDictionary *fireComboDictionary;
@property (strong, nonatomic) NSArray *fireComboArray;
@property (strong, nonatomic) NSDictionary *waterComboDictionary;
@property (strong, nonatomic) NSArray *waterComboArray;
@property (strong, nonatomic) NSDictionary *musicComboDictionary;
@property (strong, nonatomic) NSArray *musicComboArray;
@property (strong, nonatomic) NSDictionary *windComboDictionary;
@property (strong, nonatomic) NSArray *windComboArray;
@property (strong, nonatomic) NSDictionary *earthComboDictionary;
@property (strong, nonatomic) NSArray *earthComboArray;
@property (strong, nonatomic) NSArray *defenseArray;
@property (strong, nonatomic) NSArray *magicArray;
@property (strong, nonatomic) NSMutableArray *fireballArray;
@property (strong, nonatomic) NSMutableArray *availableComboBlockArray;
@property (strong, nonatomic) NSMutableDictionary *availableComboNoteDictionary;
@property (nonatomic) float fireMP;
@property (nonatomic) float fireMPMax;
@property (nonatomic) float windMP;
@property (nonatomic) float windMPMax;
@property (nonatomic) float waterMP;
@property (nonatomic) float waterMPMax;
@property (nonatomic) float earthMP;
@property (nonatomic) float earthMPMax;
@property (nonatomic) float musicMP;
@property (nonatomic) float musicMPMax;
@property (nonatomic) BOOL flameOn;
@property (nonatomic) int filterInt;

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
@property (nonatomic) int enemyMoveInt;

//Attack Properties
@property (nonatomic) float laserDamage;
@property (strong, nonatomic) NSMutableArray *keyLasers;

//Keyboard Properties
@property (nonatomic) float yPositionIncrement;

//Labels
@property (strong, nonatomic) UIImageView *healthBar;
@property (strong, nonatomic) SKLabelNode *playerHealthLabel;
@property (strong, nonatomic) SKLabelNode *attackMPLabel;
@property (strong, nonatomic) SKLabelNode *defenseMPLabel;
@property (strong, nonatomic) SKLabelNode *magicMPLabel;


//Bars
@property (strong, nonatomic) SKSpriteNode *healthBarBack;
@property (strong, nonatomic) SKSpriteNode *healthBarFill;
@property (nonatomic) float healthBarFillMaxWidth;
@property (nonatomic) float mpBarFillMaxWidth;
@property (strong, nonatomic) SKSpriteNode *mpBarBack;
@property (strong, nonatomic) SKSpriteNode *mpBarFill;





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
@property (nonatomic) BOOL shouldMove;
@property (nonatomic) BOOL gameOver;
@property (nonatomic, strong) NSArray *currentResonantArray;
@property (nonatomic, strong) NSMutableArray *keyPressArray;
@property (nonatomic) BOOL touchDown;
@property (strong, nonatomic) NSArray *interactableArray;
@property (nonatomic) BOOL isAnimating;
@property (strong, nonatomic) NSArray *moveablesArray;
@property (nonatomic) BOOL cutscene;
@property (nonatomic) BOOL shouldShoot;
@property (strong, nonatomic) NSString *currentKeyDown;
@property (nonatomic) CGPoint location;
@property (strong, nonatomic) NSArray *keyArray;
@property (nonatomic) int currentRoomNumber;
@property (nonatomic) double touchBegan;
@property (nonatomic) double touchLength;
@property (nonatomic) BOOL touchingDown;
@property (nonatomic) float roomCleared;
@property (strong, nonatomic) NSMutableArray *enemyToDeleteArray;
@property (strong, nonatomic) NSMutableArray *propArray;

//Partner Properties
@property (nonatomic) int bowTieIncrement;
@property (strong, nonatomic) SKSpriteNode *bowTie;

//Tempo Settings
@property (nonatomic) float BPM;
@property (nonatomic) BOOL firstBeat;
@property (nonatomic) int beatCount;
@property (nonatomic) int measureCount;
@property (nonatomic) double beatTime;

//Rhythm Game Defense Properties
@property (nonatomic) bool defending;


@end
