//
//  GetMusicViewController.m
//  SameSound
//
//  Created by Mac Mini on 31/03/2015.
//
//

#import "GetMusicViewController.h"
#import "NetworkManager.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface GetMusicViewController()

@property (weak, nonatomic) IBOutlet UITextField *urlText;
@property (nonatomic, strong, readwrite) NSURLConnection *  connection;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) NSMutableData *musicData;
@property (strong, nonatomic) NSURLResponse *urlResponse;

@property (nonatomic, retain) AVAudioPlayer *player;

@end

@implementation GetMusicViewController

- (IBAction)getMusicAction:(id)sender {
    NSLog(@"Get Music button pressed");
    [[NetworkManager sharedInstance] didStartNetworkOperation];
    [self startGetMusic];
}

- (void)sendDidStopWithStatus:(NSString *)statusString
{
    NSLog(@"sendDidStopWithStatus: %@",statusString);
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

-(void)startGetMusic{
    NSURL * url;
    NSMutableURLRequest * request;
    NSLog(@"startGetMusic");
    
    assert(self.connection == nil);
    
    url = [[NetworkManager sharedInstance] smartURLForString:self.urlText.text];
    assert(url != nil);
    
    request = [NSMutableURLRequest requestWithURL:url];
//    [request setValue:@"bytes=1-50000" forHTTPHeaderField:@"Range"];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    self.musicData = [[NSMutableData alloc] init];
    
    // Make other threads aware.
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
    //I'm able to get headers casting to NSHTTPURLResponse.
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    
    NSLog(@"didReceiveResponse description:%@", httpResponse.description);
    
    self.urlResponse = response;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError description: %@", error.description);
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data{
//    NSError * JSONError;
//    NSDictionary * channels = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
    
    [self.musicData appendData:data];
    self.progressView.progress = (float)self.musicData.length/(float)self.urlResponse.expectedContentLength;
    NSLog(@"Progress: %f", (float)self.musicData.length/(float)self.urlResponse.expectedContentLength);
    NSLog(@"didReceiveData response.expectedContentLength: %lld", self.urlResponse.expectedContentLength);
    NSLog(@"didReceiveData musicData.length: %lu", (unsigned long)data.length);
    
//    if(JSONError != nil){
//        NSLog(@"Error in JSON Serialization: %@", JSONError.description);
//        self.connection = nil;
//    }else{
//        NSLog(@"JSON Response: %@", channels.description);
//    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:self.musicData fileTypeHint:@"mp3" error:nil];
    self.player = newPlayer;
    
    [self.player prepareToPlay];
    [self.player play];
}

@end
