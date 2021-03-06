//
//  UIViewCurrentToolBar.m
//  MusicPutt
//
//  Created by Eric Pinet on 2014-06-28.
//  Copyright (c) 2014 Eric Pinet. All rights reserved.
//

#import "UIViewCurrentToolBar.h"
#import "AppDelegate.h"
#import "UIColor+CreateMethods.h"
#import "UIViewControllerMusic.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface UIViewCurrentToolBar()
{
    UIImageView *playView;
    UIImageView *pauseView;
    NSTimer* timer;
}
@property (nonatomic, copy) void (^didSelectBlock)(UAProgressView *progressView);
@property AppDelegate* del;

@end

@implementation UIViewCurrentToolBar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"Begin");
    
    // setup app delegate
    self.del = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [_progress setBackgroundColor:[UIColor clearColor]];
    _progress.borderWidth = 1.0;
    _progress.lineWidth = 3.0;
    _progress.fillOnTouch = YES;
    _progress.tintColor = [UIColor colorWithHex:@"#8E8E93" alpha:1.0];
    
    playView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play-toolbar"]];
    pauseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pause-toolbar"]];
    
    CGPoint point;
    point.x = 0;
    point.y = 0;
    CGSize size;
    size.height = 15;
    size.width = 15;
    CGRect rect;
    rect.origin = point;
    rect.size = size;
    playView.frame = rect;
    playView.opaque = FALSE;
    playView.alpha = .30;
    pauseView.frame = rect;
    pauseView.opaque = FALSE;
    pauseView.alpha = .30;
    _progress.centralView =  playView;
    
    _progress.didSelectBlock = ^(UAProgressView *progressView){
        MPMusicPlayerController* player = [[self.del mpdatamanager] musicplayer];
        //if([player playbackState] == MPMoviePlaybackStatePlaying)
        if([[AVAudioSession sharedInstance] isOtherAudioPlaying])
            [player pause];
        else
            [player play];
    };
    
    NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"Completed");
}

- (void)viewWillUnload
{
    [timer invalidate];
}

-(void) displayMediaItem: (MPMediaItem*) aitem
{
    // ensure that force display is set to false;
    [self.del mpdatamanager].forceDisplayMediaItem = false;
    
    if (aitem!=NULL) {
        
        UIImage* image;
        MPMediaItemArtwork *artwork = [aitem valueForProperty:MPMediaItemPropertyArtwork];
        
        if (artwork) {
            image = [artwork imageWithSize:[_imageview frame].size];
            if(image.size.height==0 || image.size.width==0)
                image = [UIImage imageNamed:@"empty"];
                
        }
        else{
            image = [UIImage imageNamed:@"empty"];
        }
        
        [_imageview setImage:image];
        [_songTitle setText:[aitem valueForProperty:MPMediaItemPropertyTitle]];
        [_artist setText:[aitem valueForProperty:MPMediaItemPropertyArtist]];
        [_album setText:[aitem valueForProperty:MPMediaItemPropertyAlbumTitle]];
        
        [self updateCurrentTime];
        
        // set last playing item to send it to musicputt server
        [[self.del mpdatamanager] setLastPlayingItem:aitem];
    }
    else{
        [_imageview setImage:nil];
        [_songTitle setText:@""];
        [_artist setText:@""];
        [_album setText:@""];
    }
    
}

-(void) updateCurrentTime
{
    // do action only if media player is ready
    if ([[self.del mpdatamanager] isMediaPlayerInitialized])
    {
        // update current time with progress round
        NSTimeInterval currentTime = [[[self.del mpdatamanager] musicplayer] currentPlaybackTime];
        NSTimeInterval playbackDuration;
        double progressValue = 0;
        
        if ([[[self.del mpdatamanager] musicplayer] nowPlayingItem]!=NULL)
        {
            NSNumber* duration = [[[[self.del mpdatamanager] musicplayer] nowPlayingItem] valueForKey:MPMediaItemPropertyPlaybackDuration];
            playbackDuration = [duration doubleValue];
            
            if (playbackDuration>0 && currentTime>0)
            {
                progressValue = currentTime / playbackDuration;
            }
        }
        
        [_progress setProgress:progressValue animated:false];
        
        // update icon play/pause
        
        //MPMusicPlayerController* player = [[self.del mpdatamanager] musicplayer];
        //if([player playbackState] == MPMoviePlaybackStatePlaying)
        if([[AVAudioSession sharedInstance] isOtherAudioPlaying])
            _progress.centralView =  pauseView;
        else
            _progress.centralView =  playView;
        
        // if needed, force displayMediaItem
        if ([self.del mpdatamanager].forceDisplayMediaItem) {
            [self displayMediaItem:[[[self.del mpdatamanager] musicplayer] nowPlayingItem]];
        }
    }
    else
    {
        NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"[Warning] - MediaPlayer isn't initialized.");
    }
    
    
}

/**
 *  Active notification capture from the media player.
 */
- (void) startNotificationCapture
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateCurrentTime)
                                           userInfo: nil
                                            repeats:YES];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      [[self.del mpdatamanager] musicplayer]];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      [[self.del mpdatamanager] musicplayer]];
    
    [[[self.del mpdatamanager] musicplayer] beginGeneratingPlaybackNotifications];
    
    NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"started");
}

/**
 *  Stop notification capture from the media player.
 */
- (void) stopNotificationCapture
{
    // desabled notification if view is not visible.
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:         [[_del mpdatamanager] musicplayer]];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:         [[_del mpdatamanager] musicplayer]];
    
    [[[_del mpdatamanager] musicplayer] endGeneratingPlaybackNotifications];
    
    [timer invalidate];
    
    NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"stoped");
}

- (void)viewPressed
{
    NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"Begin");
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewControllerMusic *musicView = [sb instantiateViewControllerWithIdentifier:@"Song"];
    [self.navigationController pushViewController:musicView animated:YES];
}

/**
 *  Check the current playing item and update display.
 */
-(void) updateCurrentPlayingItem
{
    
    // ensure that force display is set to false;
    [self.del mpdatamanager].forceDisplayMediaItem = false;
    
    // do action only if media player is ready
    if ([[self.del mpdatamanager] isMediaPlayerInitialized])
    {
        [self displayMediaItem:[[[self.del mpdatamanager] musicplayer] nowPlayingItem]];
    }
    else
    {
        NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"[Warning] - MediaPlayer isn't initialized.");
    }
}

#pragma  mark - MPMusicPlayerNSNotificationCenter

-(void) handle_PlaybackStateChanged:(id) notification
{
    //NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"Begin");
    // do action only if media player is ready
    if ([[self.del mpdatamanager] isMediaPlayerInitialized])
    {
        [self displayMediaItem:[[[self.del mpdatamanager] musicplayer] nowPlayingItem]];
    }
    else
    {
        NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"[Warning] - MediaPlayer isn't initialized.");
    }
    
}

-(void) handle_NowPlayingItemChanged:(id) notification
{
    //NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"Begin");
    // do action only if media player is ready
    if ([[self.del mpdatamanager] isMediaPlayerInitialized])
    {
        [self displayMediaItem:[[[self.del mpdatamanager] musicplayer] nowPlayingItem]];
    }
    else
    {
        NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"[Warning] - MediaPlayer isn't initialized.");
    }
}

@end
