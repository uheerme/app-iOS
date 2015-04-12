//
//  POSTHelper.h
//  SameSound
//
//  Created by Mac Mini on 25/03/2015.
//
//

#import <Foundation/Foundation.h>

@interface RESTHelper : NSObject

+(NSString *) routePrefix;
+(NSURLRequest *) postFile:(NSString *)filePath withFields:(NSDictionary *)fields toURL:(NSURL *)url;

@end
