//
//  Synchronizer.h
//  SameSound
//
//  Created by Mac Mini on 12/04/2015.
//
//

#import <Foundation/Foundation.h>

@protocol SynchronizerDelegate

-(void)systemAndServerClockDifference:(NSTimeInterval)serverDifference;

@end

@interface Synchronizer : NSObject{
    id delegate_;
}

-(id)initWithDelegate:(id<SynchronizerDelegate>)delegate;

@end
