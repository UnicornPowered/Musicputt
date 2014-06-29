//
//  MPDataManager.h
//  MusicPutt
//
//  Created by Eric Pinet on 2014-06-28.
//  Copyright (c) 2014 Eric Pinet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPMusicPlayerController;

@interface MPDataManager : NSObject

@property (strong, nonatomic) MPMusicPlayerController* musicplayer;

-(bool) initialise;


@end
