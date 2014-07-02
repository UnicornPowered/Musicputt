//
//  MPDataManager.m
//  MusicPutt
//
//  Created by Eric Pinet on 2014-06-28.
//  Copyright (c) 2014 Eric Pinet. All rights reserved.
//

#import "MPDataManager.h"
#import <MediaPlayer/MPMusicPlayerController.h>

@implementation MPDataManager
{
    bool musicviewcontrollervisible;
}


-(bool) initialise
{
    NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"Begin");
    bool retval = false;
    
    // Init MusicPlayer
    retval = [self initialiseMediaPlayer];
    
    // init current playing toolbar
    _currentPlayingToolbar = [[CurrentPlayingToolBar alloc] init];
    
    musicviewcontrollervisible = false;
    
    return retval;
}

- (bool) isMusicViewControllerVisible
{
    return musicviewcontrollervisible;
}

- (void) setMusicViewControllerVisible:(bool) visible
{
    musicviewcontrollervisible = visible;
}



#pragma mark - MediaPlayer

-(bool) initialiseMediaPlayer
{
    NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"Begin");
    bool retval = false;
    _musicplayer = [MPMusicPlayerController iPodMusicPlayer];
    if (_musicplayer==NULL) {
        NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"[ERROR] - Error getting MPMusicPlayerController iPodMusicPlayer");
    }
    else{
        NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"Completed.");
        retval = true;
    }
    return retval;
}


@end
