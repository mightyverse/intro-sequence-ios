//
//  LocalMovieViewController.m
//  IntroSequence
//
//  Created by Sarah Allen on 6/6/15.
//  Copyright (c) 2015 Mightyverse. All rights reserved.
//

#import "LocalMovieViewController.h"

CGFloat kMovieViewOffsetX = 0.0;
CGFloat kMovieViewOffsetY = 0.0;

@interface LocalMovieViewController ()
-(NSURL *)localMovieURL;
-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType;
-(void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType;

// notifications
-(void)moviePlayBackDidFinish:(NSNotification*)notification;
-(void)loadStateDidChange:(NSNotification *)notification;
-(void)moviePlayBackStateDidChange:(NSNotification*)notification;
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification;

-(void)installMovieNotificationObservers;
-(void)removeMovieNotificationHandlers;

@property MPMoviePlayerController *moviePlayerController;

@property (weak, nonatomic) IBOutlet UIView *playbackView;
@property (weak, nonatomic) IBOutlet UILabel *movieNameLabel;

@end

@implementation LocalMovieViewController
@synthesize moviePlayerController;
@synthesize movieNameLabel;

/* Returns a URL to a local movie in the app bundle. */
-(NSURL *)localMovieURL
{
    NSURL *theMovieURL = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle)
    {
        NSString *movieName = movieNameLabel.text;
        NSLog(movieName);
        NSString *moviePath = [bundle pathForResource:movieName                                               ofType:@"mp4"];
        if (moviePath)
        {
            theMovieURL = [NSURL fileURLWithPath:moviePath];
        }
    }
    return theMovieURL;
}

#pragma mark Notification Handlers

/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSNumber *reason = [notification userInfo][MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason integerValue])
    {
            /* The end of the movie was reached. */
        case MPMovieFinishReasonPlaybackEnded:
            NSLog(@"Playback ended");
            break;
            
            /* An error was encountered during playback. */
        case MPMovieFinishReasonPlaybackError:
            NSLog(@"An error was encountered during playback");
            break;
            
            /* The user stopped playback. */
        case MPMovieFinishReasonUserExited:
            NSLog(@"User stopped playback -- don't think this can happen");

        default:
            break;
    }
    
    [self performSegueWithIdentifier: @"Next" sender: self];
}

/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification
{
    MPMoviePlayerController *player = notification.object;
    MPMovieLoadState loadState = player.loadState;

    /* The load state is not known at this time. */
    if (loadState & MPMovieLoadStateUnknown)
    {
        NSLog(@"loadStateDidChange: unknown");
    }

    /* The buffer has enough data that playback can begin, but it
     may run out of data before playback finishes. */
    if (loadState & MPMovieLoadStatePlayable)
    {
        NSLog(@"loadStateDidChange: playable");
    }

    /* Enough data has been buffered for playback to continue uninterrupted. */
    if (loadState & MPMovieLoadStatePlaythroughOK)
    {
        NSLog(@"loadStateDidChange: playthrough ok");

    }

    /* The buffering of data has stalled. */
    if (loadState & MPMovieLoadStateStalled)
    {
        NSLog(@"loadStateDidChange: stalled");
    }

    if(moviePlayerController.loadState & (MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK)) {
        [self.view addSubview: [player view]];
        [player play];
    }
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
    MPMoviePlayerController *player = notification.object;

    /* Playback is currently stopped. */
    if (player.playbackState == MPMoviePlaybackStateStopped)
    {
        NSLog(@"moviePlayBackStateDidChange: stopped");
    }
    /*  Playback is currently under way. */
    else if (player.playbackState == MPMoviePlaybackStatePlaying)
    {
        NSLog(@"moviePlayBackStateDidChange: playing");
    }
    /* Playback is currently paused. */
    else if (player.playbackState == MPMoviePlaybackStatePaused)
    {
        NSLog(@"moviePlayBackStateDidChange: paused");
    }
    /* Playback is temporarily interrupted, perhaps because the buffer
     ran out of content. */
    else if (player.playbackState == MPMoviePlaybackStateInterrupted)
    {
        NSLog(@"moviePlayBackStateDidChange: interrupted");
    }
}

/* Notifies observers of a change in the prepared-to-play state of an object
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange");
}

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self moviePlayerController];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];
}

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers
{
    MPMoviePlayerController *player = [self moviePlayerController];

    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
}

/*
 Create a MPMoviePlayerController movie object for the specified URL and add movie notification
 observers. Configure the movie object for the source type, scaling mode, control style, background
 color, background image, repeat mode and AirPlay mode. Add the view containing the movie content and
 controls to the existing view hierarchy.
 */
-(void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    /* Create a new movie player object. */
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if (player)
    {
        /* Save the movie object. */
        self.moviePlayerController = player;
        
        player.controlStyle = MPMovieControlStyleNone;

        
        /* Register the current object as an observer for the movie
         notifications. */
       [self installMovieNotificationObservers];
        
        /* Specify the URL that points to the movie file. */
       [player setContentURL:[self localMovieURL]];
        
        /* If you specify the movie type before playing the movie it can result
         in faster load times. */
       [player setMovieSourceType:sourceType];
        
        /* Apply the user movie preference settings to the movie player object. */
      //  [self applyUserSettingsToMoviePlayer];
        
        /* Add a background view as a subview to hide our other view controls
         underneath during movie playback. */
     //   [self.view addSubview:self.backgroundView];
     
        CGRect viewInsetRect = CGRectInset ([self.playbackView frame],
                                            kMovieViewOffsetX,
                                            kMovieViewOffsetY );

        /* Inset the movie frame in the parent view frame. */
        [[player view] setFrame:viewInsetRect];
        
      //  [player view].backgroundColor = [UIColor lightGrayColor];
        
        /* To present a movie in your application, incorporate the view contained
         in a movie player’s view property into your application’s view hierarchy.
         Be sure to size the frame correctly. */
        
        player.shouldAutoplay = YES;

        [moviePlayerController prepareToPlay];

        
    }
}

/* Load and play the specified movie url with the given file type. */
-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    [self createAndConfigurePlayerWithURL:movieURL sourceType:sourceType];
    
}

/* Play the local movie */
-(void)playMovieFile:(NSURL *)movieFileURL
{
    [self createAndPlayMovieForURL:movieFileURL sourceType:MPMovieSourceTypeFile];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad LocalMovieViewController");
    movieNameLabel.hidden = YES;

    [self.playbackView setBackgroundColor:[UIColor clearColor]];
    [self.playbackView setOpaque:NO];

}

- (void)viewDidUnload
{
    [self removeMovieNotificationHandlers];
    [self setMoviePlayerController:nil];

    [super viewDidUnload];
}



- (void) viewDidAppear:(BOOL) animated {
    NSURL *movieUrl = [self localMovieURL];
    [self playMovieFile:movieUrl];
}

- (void) viewDidDisappear:(BOOL)animated {
   // [[self.moviePlayerController view] removeFromSuperview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
