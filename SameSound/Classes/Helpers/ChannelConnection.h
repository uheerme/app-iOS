//
//  ChennelConnection.h
//  SameSound
//
//  Created by Mac Mini on 12/04/2015.
//
//

#import <Foundation/Foundation.h>

@protocol ChannelConnectionDelegate

-(void)channelInfoReceived:(NSDictionary *)channelInfo;

@end

@interface ChannelConnection : NSObject{
    id delegate_;
}

-(void)getChannelInfo;
-(id)initWithDelegate:(id<ChannelConnectionDelegate>)delegate idRequest:(int)idRequest;

@end
