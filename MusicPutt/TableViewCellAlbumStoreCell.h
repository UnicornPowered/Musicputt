//
//  TableViewCellAlbumStoreCell.h
//  MusicPutt
//
//  Created by Eric Pinet on 2014-09-13.
//  Copyright (c) 2014 Eric Pinet. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UAProgressView;
@class ITunesMusicTrack;
@class UIViewEqualizer;

@interface TableViewCellAlbumStoreCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* downloadProgress;

@property (weak, nonatomic) IBOutlet UIViewEqualizer* equalizer;

/**
 *  Set the information of the media item (name, track no. and duration).
 *
 *  @param mediaitem : The media item to set.
 */
- (void)setMediaItem: (ITunesMusicTrack*)mediaitem;


/**
 *  Get media item attach with this cell.
 *
 *  @return mediaItem attach with this cell.
 */
-(ITunesMusicTrack*) getMediaItem;


/**
 *  Start downloading progress
 */
-(void) startDownloadProgress;

/**
 *  Stop downloading progress
 */
-(void) stopDownloadProgress;

/**
 *  Start playing progress
 */
-(void) startPlayingProgress;

/**
 *  Stop playing progress
 */
-(void) stopPlayingProgress;


@end
