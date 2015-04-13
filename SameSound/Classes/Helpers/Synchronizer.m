//
//  Synchronizer.m
//  SameSound
//
//  Created by Mac Mini on 12/04/2015.
//
//

#import "Synchronizer.h"
#import "RESTHelper.h"
#import "NetworkManager.h"

@interface Synchronizer ()

@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property (nonatomic, strong) NSDate *sentTime;
@property (nonatomic) NSTimeInterval tripTime;
@property (nonatomic, strong) NSDictionary *jsonData;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation Synchronizer

-(id)initWithDelegate:(id<SynchronizerDelegate>)delegate{
    self = [super init];
    if(self){
        delegate_ = delegate;
    }
    
    //Configurating formatter to parse time string
    self.dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [self.dateFormatter setLocale:enUSPOSIXLocale];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZ"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    //Connection's stuff
    NSURLRequest *request;
    request = [NSURLRequest requestWithURL:[RESTHelper getRouteWithSufix:@"api/Status/Now"]];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    return self;
}

- (NSURLRequest *)connection:(NSURLConnection *)theConnection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    self.sentTime = [NSDate date];
    
    return request;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
    self.tripTime = -[self.sentTime timeIntervalSinceNow];
    NSLog(@"Trip time: %f", self.tripTime);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError * JSONError;
    self.jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
    
    if(JSONError != nil){
        NSLog(@"Error in JSON Serialization in synchronization with server: %@", JSONError.description);
    }else{
        NSDate *serverTime = [self.dateFormatter dateFromString:[self.jsonData valueForKey:@"Now"]];
        serverTime = [serverTime dateByAddingTimeInterval:self.tripTime/2];
        [delegate_ systemAndServerClockDifference: [serverTime timeIntervalSinceNow]];
    }
}

@end
