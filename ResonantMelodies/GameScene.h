//
//  GameScene.h
//  ResonantMelodies
//

//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//


#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface GameScene : SKScene

//Player Properties
@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) NSString *currentHero;
@property (strong, nonatomic) SKSpriteNode *player;

//Touch Properties
@property (strong, nonatomic) NSMutableArray *touchArray;
@property (nonatomic, strong) NSMutableArray *sectionedTouchArray;

//Enemy Properties
@property (nonatomic) float enemyHealth;
@property (nonatomic) BOOL asteroidCreated;
@property (nonatomic) int asteroidCount;
@property (nonatomic) float enemySpeed;
@property (strong, nonatomic) NSArray *enemyArray;


//Attack Properties
@property (nonatomic) float laserDamage;

//Keyboard Properties
@property (nonatomic) float yPositionIncrement;

//Audio Properties
@property (strong, nonatomic) AVAudioPlayer *lowAAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowGAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowBAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowCAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowDAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *lowEAudioPlayer;

@property (nonatomic) SystemSoundID resonantSound1;
@property (nonatomic) SystemSoundID resonantSound2;
@property (nonatomic) SystemSoundID resonantSound3;
@property (nonatomic) SystemSoundID resonantSound4;

//Game Properties
@property (nonatomic) int score;
@property (nonatomic) float randSecs;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) SKLabelNode *healthLabel;
@property (strong, nonatomic) NSString *difficulty;

@property (nonatomic, strong) NSArray *currentResonantArray;

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) NSInteger intTmp;


@property (nonatomic) CGPoint location;

//Tempo Settings
@property (nonatomic) float BPM;
@property (nonatomic) BOOL firstBeat;
@property (nonatomic) int beatCount;
@property (nonatomic) int measureCount;
@property (nonatomic) double beatTime;

@end
