//
//  UITableViewCellArtistAlbum.m
//  MusicPutt
//
//  Created by Qiaomei Wang on 2014-07-09.
//  Copyright (c) 2014 Eric Pinet. All rights reserved.
//

#import "UITableViewCellArtistAlbum.h"
#import "AppDelegate.h"
#import "Playlist.h"
#import "PlaylistItem.h"

@interface UITableViewCellArtistAlbum()
{
   MPMediaItem* mediaItem;
}

@property AppDelegate* del;

@end

@implementation UITableViewCellArtistAlbum

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.del = (AppDelegate*)[[UIApplication sharedApplication]delegate];
}

/**
 *  Set the information of the media item (name, track no. and duration).
 *
 *  @param artistAlbumItem : The media item to set.
 */
- (void)setArtistAlbumItem: (MPMediaItem*)artistAlbumItem
{
    mediaItem = artistAlbumItem;
    self.songName.text = [artistAlbumItem valueForProperty:MPMediaItemPropertyTitle];
    self.trackNo.text  = [[artistAlbumItem valueForProperty:MPMediaItemPropertyAlbumTrackNumber] stringValue];

    NSNumber *durationtime = [artistAlbumItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    self.songDuration.text = [NSString stringWithFormat: @"%02d:%02d",
                             [durationtime intValue]/60,
                             [durationtime intValue]%60];
}

- (MPMediaItem*)getMediaItem
{
    return mediaItem;
}

- (IBAction)addButtonClick:(id)sender
{
    // create new playlist item and add to current playlist
    PlaylistItem* item = [PlaylistItem MR_createEntity];
    item.songuid = [[NSNumber alloc] initWithUnsignedLongLong:mediaItem.persistentID];
    item.position = [[NSNumber alloc] initWithUnsignedLong: [[[[self.del mpdatamanager] currentMusicputtPlaylist] items] count] ];
    [[[self.del mpdatamanager] currentMusicputtPlaylist] addItemsObject:item];
}

@end
