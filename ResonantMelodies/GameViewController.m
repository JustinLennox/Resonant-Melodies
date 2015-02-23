//
//  GameViewController.m
//  ResonantMelodies
//
//  Created by Justin Lennox on 1/22/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "WorldOverview.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;

    
    SKScene *sampleScene = [[WorldOverview alloc] initWithSize:skView.bounds.size];
    SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
    [skView presentScene:sampleScene transition:transition];
    
    NSLog(@"GameViewController Called");
    // Present the scene.
    //[skView presentScene:overviewScene];
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
