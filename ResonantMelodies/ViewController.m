//
//  ViewController.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/22/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//
#import "ViewController.h"

@implementation ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // Configure the view.
    // Configure the view after it has been sized for the correct orientation.
    [self startScene];
}


- (void)startScene
{
    SKView *skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        GameScene *theScene = [GameScene sceneWithSize:skView.bounds.size];
        theScene.scaleMode = SKSceneScaleModeAspectFill;
        
        WorldOverview *worldView = [WorldOverview sceneWithSize:skView.bounds.size];
        worldView.scaleMode = SKSceneScaleModeAspectFill;
        
        
        // Present the scene.
        [skView presentScene:worldView];
        NSLog(@"scene presentedd");
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
