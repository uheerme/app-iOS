//
//  ChennelConnection.m
//  SameSound
//
//  Created by Mac Mini on 12/04/2015.
//
//

#import "ChannelConnection.h"
#import "RESTHelper.h"

@interface ChannelConnection ()

@property (nonatomic) int channelId;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSDictionary *channelDictionary;

@end

@implementation ChannelConnection

-(id)initWithDelegate:(id)delegate idRequest:(int)idRequest{
    self = [super init];
    if(self){
        delegate_ = delegate;
    }
    
    self.channelId = idRequest;
    
    return self;
}

-(void)getChannelInfo{
    NSURLRequest *request;
    
    request = [NSURLRequest requestWithURL:[RESTHelper getRouteWithSufix:[NSString stringWithFormat:@"api/Channels/%d",self.channelId]]];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"ChannelConnection Response: %@", response.description);
}
    
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data{
    NSError * JSONError;
    self.channelDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
    
    if(JSONError != nil){
        NSLog(@"Error in JSON Serialization in ChannelConnection: %@", JSONError.description);
    }
    
}
    
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error{
    NSLog(@"ChannelConnection connectionDidFail: %@", error.description);
}
    
-(void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
    [delegate_ channelInfoReceived:self.channelDictionary];
}

@end
