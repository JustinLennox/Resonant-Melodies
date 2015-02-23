//
//  CustomProgressBar.h
//  ResonantMelodies
//
//  Created by Justin Lennox on 2/22/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CustomProgressBar : SKCropNode

/// Set to a value between 0.0 and 1.0.
- (void) setProgress:(CGFloat) progress;

///Set the bar's type from a string, like health, attack, etc.
-(void)setBarType:(NSString *) type;


@end
