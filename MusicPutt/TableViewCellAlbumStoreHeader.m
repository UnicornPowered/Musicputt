//
//  TableViewCellAlbumStoreHeader.m
//  MusicPutt
//
//  Created by Eric Pinet on 2014-09-13.
//  Copyright (c) 2014 Eric Pinet. All rights reserved.
//

#import "TableViewCellAlbumStoreHeader.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "ITunesAlbum.h"
#import "MOStoreButton.h"


@interface TableViewCellAlbumStoreHeader()
{
    ITunesAlbum* _mediaitem;
}

@property (weak, nonatomic) IBOutlet UIImageView* imageview;

@property (weak, nonatomic) IBOutlet UIButton* artistname;

@property (weak, nonatomic) IBOutlet UILabel* albumname;

@property (weak, nonatomic) IBOutlet UILabel* year;

@property (weak, nonatomic) IBOutlet UILabel* price;

@property (weak, nonatomic) IBOutlet UILabel* genre;

@end

@implementation TableViewCellAlbumStoreHeader

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 *  Set the information of the media item (name, track no. and duration).
 *
 *  @param artistAlbumItem : The media item to set.
 */
- (void)setMediaItem:(ITunesAlbum *)mediaitem
{
    [_artistname setTitle:[NSString stringWithFormat:@"%@ >", [mediaitem artistName]] forState:UIControlStateNormal ];
    _albumname.text  = [mediaitem collectionName];
    _genre.text = [mediaitem primaryGenreName];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    _year.text = [[formatter stringFromDate:[mediaitem releaseDate]] capitalizedString];
    
    // load price
    if ( [mediaitem collectionPrice] == nil) {
        _price.text = @"";
    }
    else{
        _price.text = [NSString stringWithFormat:@"$%@", [mediaitem collectionPrice]];
    }
    
    [_imageview sd_setImageWithURL:[NSURL URLWithString:[mediaitem getArtworkUrlCustomQuality:@"300x300-75"]]
                    placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-300.jpg",[mediaitem collectionId]]]
                    options:SDWebImageProgressiveDownload];
    
    _mediaitem = mediaitem;
}

/**
 *  Get media item attach with this cell.
 *
 *  @return mediaItem attach with this cell.
 */
-(ITunesAlbum*) getMediaItem
{
    return _mediaitem;
}

@end
