//
//  ChannelConnectionController.m
//  SameSound
//
//  Created by Mac Mini on 12/04/2015.
//
//

#import "ChannelConnectionController.h"
#import "ChannelConnection.h"
#import "Synchronizer.h"
#import "MusicStreamConnection.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface ChannelConnectionController () <MusicStreamConnectionDelegate, ChannelConnectionDelegate, SynchronizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property (weak, nonatomic) IBOutlet UILabel *playingLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelName;
@property (weak, nonatomic) IBOutlet UILabel *musicName;
@property (weak, nonatomic) IBOutlet UITextField *channelIdText;
@property (strong, nonatomic) Synchronizer *synchronizer;
@property (nonatomic) NSTimeInterval systemAndServerTimeDifference;
@property (strong, nonatomic) ChannelConnection *channelConnection;
@property (strong, nonatomic) MusicStreamConnection *musicStreamConnection;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSDate *channelStartedAt;

@end

@implementation ChannelConnectionController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.synchronizer = [[Synchronizer alloc] initWithDelegate:self];
}

-(void)systemAndServerClockDifference:(NSTimeInterval)serverDifference{
    self.systemAndServerTimeDifference = serverDifference;
}

- (IBAction)ListenAction:(id)sender {
    int channelId = [self.channelIdText.text intValue];
    
    self.channelConnection = [[ChannelConnection alloc] initWithDelegate:self idRequest:channelId];
    [self.channelConnection getChannelInfo];
}

-(void)channelInfoReceived:(NSDictionary *)channelInfo{
    NSLog(@"%@", channelInfo.description);
    
    self.channelLabel.hidden = NO;
    self.playingLabel.hidden = NO;
    
    NSDictionary *musics;
    for (int i=0; i<[[channelInfo valueForKey:@"Musics"] count]; i++) {
        musics = [[channelInfo valueForKey:@"Musics"] objectAtIndex:i];
        
        if ([musics valueForKey:@"Id"] == [channelInfo valueForKey:@"CurrentId"]) {
            break;
        }
    }
    
    [self.channelName setText:[channelInfo valueForKey:@"Name"]];
    [self.musicName setText:[musics valueForKey:@"Name"]];
    
    self.channelName.hidden = NO;
    self.musicName.hidden = NO;
    
    //Configurating formatter to parse time string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    self.channelStartedAt = [dateFormatter dateFromString:[channelInfo valueForKey:@"CurrentStartTime"]];
    
    self.musicStreamConnection = [[MusicStreamConnection alloc] initWithDelegate:self idRequest:[[musics valueForKey:@"Id"] intValue]];
    [self.musicStreamConnection getMusicStream];
}

-(void)musicStreamReceived:(NSData *)musicData{
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:musicData fileTypeHint:@"mp3" error:nil];
    self.player = newPlayer;
    
    [self.player prepareToPlay];
    
    NSDate *time1 = [[NSDate date] dateByAddingTimeInterval:self.systemAndServerTimeDifference];
    NSLog(@"time1: %@", time1.description);
    NSLog(@"channelstartesAt: %@", self.channelStartedAt);
    NSTimeInterval currentTime = [[[NSDate date] dateByAddingTimeInterval:self.systemAndServerTimeDifference] timeIntervalSinceDate:self.channelStartedAt];
    NSLog(@"%f", currentTime);
    
    [self.player setCurrentTime:currentTime];
    
    [self.player play];
}

@end
