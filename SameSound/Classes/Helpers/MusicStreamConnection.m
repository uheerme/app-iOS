//
//  MusicStreamConnection.m
//  SameSound
//
//  Created by Mac Mini on 12/04/2015.
//
//

#import "MusicStreamConnection.h"
#import "RESTHelper.h"

@interface MusicStreamConnection ()

@property (nonatomic) int musicId;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *musicData;

@end

@implementation MusicStreamConnection

-(id)initWithDelegate:(id<MusicStreamConnectionDelegate>)delegate idRequest:(int)idRequest{
    self = [super init];
    if(self){
        delegate_ = delegate;
    }
    
    self.musicId = idRequest;
    
    return self;
}

-(void)getMusicStream{
    NSURLRequest *request;
    self.musicData = [[NSMutableData alloc] init];
    
    request = [NSURLRequest requestWithURL:[RESTHelper getRouteWithSufix:[NSString stringWithFormat:@"api/Musics/%d/Stream",self.musicId]]];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
        NSLog(@"ChannelConnection Response: %@", response.description);
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data{
    [self.musicData appendData:data];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error{
    NSLog(@"ChannelConnection connectionDidFail: %@", error.description);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
    [delegate_ musicStreamReceived:self.musicData];
}

@end
