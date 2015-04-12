//
//  POSTHelper.m
//  SameSound
//
//  Created by Mac Mini on 25/03/2015.
//
//

#import "RESTHelper.h"

@implementation RESTHelper

+(NSString *)routePrefix{ return @"http://54.69.27.129"; }

+(NSURLRequest *) postFile:(NSString *)filePath withFields:(NSDictionary *)fields toURL:(NSURL *)url{
    NSMutableURLRequest *request;
    NSString *fileName = [filePath lastPathComponent];;
    NSMutableString *body = [[NSMutableString alloc] init];
    NSMutableData *bodyData;
    
    //Boundary, that initiate every field part and finish the
    NSString *boundaryStr = [RESTHelper generateBoundaryString];
    
    //Configurating Header
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryStr] forHTTPHeaderField:@"Content-Type"];
    
    //Biulding the body
    NSEnumerator *keyEnumerator = [fields keyEnumerator];
    id key;
    for (int i=0; i<[fields count]; i++) {
        key = [keyEnumerator nextObject];
    
        [body appendFormat:@
            "--%@\r\n"
            "Content-Disposition: form-data; name=\"%@\"\r\n"
            "\r\n"
            "%@\r\n",
            boundaryStr, key, [fields valueForKey:key]
        ];
    }
    
    //File information.
    [body appendFormat:@
     "--%@\r\n"
     "Content-Disposition: form-data; name=\"music\"; filename=\"%@\"\r\n"
     "Content-Type: audio/mpeg\r\n"
     "\r\n",
     boundaryStr, fileName
     ];
    
    NSString *bodySufix = [NSString stringWithFormat:@
        "\r\n"
        "--%@--\r\n",
        boundaryStr];

    //Building the data
    bodyData = (NSMutableData *)[body dataUsingEncoding:NSUTF8StringEncoding];

    //The file is being outputed without a stream, what can pause the program flow, in the simpleURLConnection there's an exemple of NSStream.
    [bodyData appendData:[NSData dataWithContentsOfFile:filePath]];
    
    [bodyData appendData:(NSMutableData *)[bodySufix dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Length of the payload
    [request setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:bodyData];
    
    return (NSURLRequest *)request;
}

+ (NSString *)generateBoundaryString{
    CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    NSString *      result;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"iOS_SameSound_Boundary-%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

@end
