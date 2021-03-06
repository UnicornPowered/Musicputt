//
//  UIViewControllerAlbumStore.m
//  MusicPutt
//
//  Created by Eric Pinet on 2014-09-13.
//  Copyright (c) 2014 Eric Pinet. All rights reserved.
//

#import "UIViewControllerAlbumStore.h"

#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "AppDelegate.h"
#import "TableViewCellAlbumStoreCell.h"
#import "TableViewCellAlbumStoreHeader.h"
#import "UIViewControllerArtistStore.h"
#import "ITunesSearchApi.h"


@interface UIViewControllerAlbumStore () <UITableViewDelegate, UITableViewDataSource, ITunesSearchApiDelegate, AVAudioPlayerDelegate>
{
    NSArray* songs;
    AVAudioPlayer* audioPlayer;
    NSInteger currentSongIndex;
    NSInteger currentDownloadingIndex;
    NSInteger currentPlayingIndex;
    UIActivityIndicatorView *activityIndicator;
}
@property AppDelegate* del;

/**
 * Table of songs
 */
@property (weak, nonatomic) IBOutlet UITableView* songstable;

@end

@implementation UIViewControllerAlbumStore

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // setup app delegate
    self.del = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    // setup title
    [self setTitle:@"Store"];
    
    // setup tableview
    scrollView = _songstable;
    
    // init loaging activity indicator
    activityIndicator= [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    activityIndicator.opaque = YES;
    activityIndicator.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    activityIndicator.center = self.view.center;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    // prepare itunes service for query
    ITunesSearchApi *itunes = [[ITunesSearchApi alloc] init];
    [itunes setDelegate:self];
    
    // query songs
    [itunes queryMusicTrackWithAlbumId:_collectionId asynchronizationMode:true];
    
    // Initialize AVAudioPLayer
    [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    if (setCategoryError)
        NSLog(@"Error setting category! %@", setCategoryError);
    
    // init current downloading displaying
    currentDownloadingIndex = -1;
    currentPlayingIndex = -1;
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stopPlaying];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AMWaveViewController

- (NSArray*)visibleCells
{
    return [self.songstable visibleCells];
}


/**
 *  Number of section in the table view.
 *
 *  @param tableView :
 *
 *  @return          : Number of section.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (songs.count>0) {
        return 1;
    }
    else{
        return 0;
    }
}

/**
 *  The number of rows in the specified section.
 *
 *  @param tableView <#tableView description#>
 *  @param section   : Section's index.
 *
 *  @return          : Number of row of this section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return songs.count - 1;
}

/**
 *  Return the cell at a specified location in the talbe view.
 *
 *  @param tableView :
 *  @param indexPath : The path to the cell.
 *
 *  @return
 */
- (TableViewCellAlbumStoreCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellAlbumStoreCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumStoreCell"];
    [cell setMediaItem:songs[indexPath.row+1]];
    
    if (currentPlayingIndex == indexPath.row) {
        [cell startPlayingProgress];
        
        if (currentDownloadingIndex == indexPath.row) {
            [cell stopPlayingProgress];
            [cell startDownloadProgress];
        }
    }
    else{
        [cell stopPlayingProgress];
        [cell stopDownloadProgress];
    }
    
    return cell;
}

/**
 *  Create the header cell of the section in the table view.
 *
 *  @param tableView :
 *  @param section   : The section index.
 *  @return          : The header cell.
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TableViewCellAlbumStoreHeader * headerCell = [tableView dequeueReusableCellWithIdentifier:@"AlbumStoreHeaderCell"];
    headerCell.backgroundColor = [UIColor whiteColor];
    [headerCell setMediaItem:songs[0]];
    return headerCell;
}
/**
 *  Set the section header's height.
 *
 *  @param tableView : Table view for this section.
 *  @param section   : Section index.
 *
 *  @return          : Section hearder's height.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 110.0f;
}

/**
 *  Implement this methode for recieve result after query.
 *
 *  @param status  Status of the querys
 *  @param type    Type of query sender
 *  @param results resultset of the query
 */
-(void) queryResult:(ITunesSearchApiQueryStatus)status type:(ITunesSearchApiQueryType)type results:(NSArray*)results
{
    if(status == ITunesSearchApiStatusSucceed)
    {
        if(type == QueryMusicTrackWithAlbumId)
        {
            // query music track completed
            songs = results;
        }
        
        [_songstable reloadData];
    }
    
    // stop activity indicator
    [activityIndicator stopAnimating];
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+1 == currentSongIndex && [audioPlayer isPlaying]) {
        NSLog(@" %s - %@ %ld\n", __PRETTY_FUNCTION__, @"Stop playing ", (long)currentSongIndex);
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSongIndex-1 inSection:0];
        [self.songstable deselectRowAtIndexPath:indexPath animated:YES];
        
        [audioPlayer stop];
        [self stopPlayingProgress:[NSNumber numberWithInteger:currentSongIndex]];
    }
    else{
        [self startPlayingAtIndex:indexPath.row+1];
    }
    return indexPath;
}


#pragma mark - AVAudioPlayerDelegate

/**
 *  Ensure that playing preview song is ended
 */
- (void) stopPlaying
{
    [audioPlayer stop];
    [self stopPlayingProgress:[NSNumber numberWithInteger:currentPlayingIndex]];
}

/**
 *  Start playing item a this index
 *
 *  @param index <#index description#>
 */
- (void) startPlayingAtIndex:(NSInteger) index
{
    if (songs.count>index) {
        currentSongIndex = index;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSongIndex-1 inSection:0];
        [_songstable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        NSLog(@" %s - %@ %ld\n", __PRETTY_FUNCTION__, @"Start playing", (long)currentSongIndex);
        
        [self startDownloadProgress:currentSongIndex-1];
        
        NSURL *url = [NSURL URLWithString: [[songs objectAtIndex:index] previewUrl]];
        if (url) {
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
                audioPlayer.delegate = self;
                [audioPlayer prepareToPlay];
                [audioPlayer play];
                
                NSNumber *param = [NSNumber numberWithInteger:currentDownloadingIndex];
                [self performSelectorOnMainThread:@selector(stopDownloadProgress:) withObject:param waitUntilDone:NO];
                
                NSNumber *param2 = [NSNumber numberWithInteger:currentDownloadingIndex];
                [self performSelectorOnMainThread:@selector(startPlayingProgress:) withObject:param2 waitUntilDone:NO];
                
            }];
            [task resume];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"There is no preview for this song!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil,nil];
            [alert show];
            
            [self stopDownloadProgress: [NSNumber numberWithInteger:currentSongIndex-1]];
        }
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@" %s - %@ %ld\n", __PRETTY_FUNCTION__, @"Playing ended ", (long)currentSongIndex);
    [audioPlayer stop];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSongIndex-1 inSection:0];
    [self.songstable deselectRowAtIndexPath:indexPath animated:YES];
    
    [self startPlayingAtIndex:currentSongIndex+1];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Error occured");
}

-(void) startDownloadProgress:(NSInteger) index
{
    if (currentDownloadingIndex != -1) {
        // stop already downloding progress
        [self stopDownloadProgress:[NSNumber numberWithInteger:index]];
    }
    
    currentDownloadingIndex = index;
    
    //NSLog(@" %s - %@ %ld\n", __PRETTY_FUNCTION__, @"Start downloading progress ", (long)index);
    
    TableViewCellAlbumStoreCell *cell = (TableViewCellAlbumStoreCell*)[_songstable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (cell) {
        [cell startDownloadProgress];
    }
}

-(void) stopDownloadProgress:(NSNumber*) index
{
    //NSLog(@" %s - %@ %ld\n", __PRETTY_FUNCTION__, @"Stop downloading progress ", (long)[index integerValue]);
    
    TableViewCellAlbumStoreCell *cell = (TableViewCellAlbumStoreCell*)[_songstable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[index integerValue] inSection:0]];
    if (cell) {
        [cell stopDownloadProgress];
    }
    currentDownloadingIndex = -1;
}

/**
 *  <#Description#>
 *
 *  @param index <#index description#>
 */
-(void) startPlayingProgress:(NSInteger) index
{
    if (currentPlayingIndex != -1) {
        // stop already downloding progress
        [self stopPlayingProgress:[NSNumber numberWithInteger:currentPlayingIndex]];
    }
    
    currentPlayingIndex = currentSongIndex;
    
    TableViewCellAlbumStoreCell *cell = (TableViewCellAlbumStoreCell*)[_songstable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentPlayingIndex-1 inSection:0]];
    if (cell) {
        [cell startPlayingProgress];
    }
}

/**
 *  <#Description#>
 *
 *  @param index <#index description#>
 */
-(void) stopPlayingProgress:(NSNumber*) index
{
    //NSLog(@" %s - %@ %ld\n", __PRETTY_FUNCTION__, @"Stop downloading progress ", (long)[index integerValue]);
    
    TableViewCellAlbumStoreCell *cell = (TableViewCellAlbumStoreCell*)[_songstable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[index integerValue]-1 inSection:0]];
    if (cell) {
        [cell stopPlayingProgress];
    }
    currentPlayingIndex = -1;
}

/**
 *  Share button was pressed by the user.
 *
 *  @param sender sender of event.
 */
- (IBAction)sharePressed:(id)sender
{
    if(songs[0])
    {
        NSString* sharedString = [NSString stringWithFormat:@"I'm listening : %@ - %@ @musicputt!", [songs[0] artistName], [songs[0] collectionName]];
        NSURL* sharedUrl = [NSURL URLWithString:[songs[0] collectionViewUrl]];
        
        id path = [songs[0] getArtworkUrlCustomQuality:@"300x300-100"];
        NSURL *url = [NSURL URLWithString:path];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *sharedImage = [[UIImage alloc] initWithData:data];
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[sharedString, sharedUrl, sharedImage] applicationActivities:nil];
        controller.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact];
        [self presentViewController:controller animated:YES completion:nil];
    }
}


/**
 *  Click on itunes button.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)itunesButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[songs[0] collectionViewUrl]]];
}

/**
 *  Click on artist button.
 */
- (IBAction)artistButtonPressed:(id)sender
{
    NSLog(@" %s - %@\n", __PRETTY_FUNCTION__, @"artistPressed");

    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewControllerArtistStore *storeView = [sb instantiateViewControllerWithIdentifier:@"Store"];
    [storeView setStoreArtistId: [songs[0] artistId]];
    [self.navigationController pushViewController:storeView animated:YES];
    //[self.navigationController presentViewController:storeView animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
