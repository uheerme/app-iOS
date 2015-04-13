//
//  MusicStreamConnection.h
//  SameSound
//
//  Created by Mac Mini on 12/04/2015.
//
//

#import <Foundation/Foundation.h>

@protocol MusicStreamConnectionDelegate

-(void)musicStreamReceived:(NSData *)musicData;

@end

@interface MusicStreamConnection : NSObject{
    id delegate_;
}

-(void)getMusicStream;
-(id)initWithDelegate:(id<MusicStreamConnectionDelegate>)delegate idRequest:(int)idRequest;

@end
