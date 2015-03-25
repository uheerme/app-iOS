//
//  PostMusicViewController.m
//  SameSound
//
//  Created by Mac Mini on 24/03/2015.
//
//

#import "PostMusicViewController.h"
#import "NetworkManager.h"

@interface PostMusicViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextField *urlText;
@property (nonatomic, strong, readwrite) NSURLConnection *  connection;

@end

@implementation PostMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)postAction:(id)sender {
    self.statusLabel.text = @"Sending";
    [[NetworkManager sharedInstance] didStartNetworkOperation];
    [self startSendMusic];
}

- (void)sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"POST succeeded";
    }
    self.statusLabel.text = statusString;
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

- (BOOL)isSending
{
    return (self.connection != nil);
}

- (NSString *)generateBoundaryString
{
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

-(void)startSendMusic{
    BOOL success;
    NSURL * url;
    NSMutableURLRequest * request;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"relicario" ofType:@"mp3"];
    
    assert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    assert( [filePath.pathExtension isEqual:@"mp3"] || [filePath.pathExtension isEqual:@"mpeg"] );
    
    NSLog(@"startSend");
    
    assert(self.connection == nil);         // don't tap receive twice in a row!
    
    // First get and check the URL.
    
    url = [[NetworkManager sharedInstance] smartURLForString:self.urlText.text];
    success = (url != nil);
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.statusLabel.text = @"Invalid URL";
    }
    
    NSString * boundaryStr = [self generateBoundaryString];
    assert(boundaryStr != nil);
    
    NSString * bodyPrefixStr = [NSString stringWithFormat:
           @
           // empty preamble
           "\r\n"
           "--%@\r\n"
           "Content-Disposition: form-data; name=\"fileContents\"; filename=\"%@\"\r\n"
           "Content-Type: %@\r\n"
           "\r\n",
           boundaryStr,
           @"relicario.mp3",
           @"audio/mp3"
    ];
    NSString *bodySuffixStr = [NSString stringWithFormat:
         @
         "\r\n"
         "--%@\r\n"
         "Content-Disposition: form-data; name=\"uploadButton\"\r\n"
         "\r\n"
         "Upload File\r\n"
         "--%@--\r\n"
         "\r\n"
         //empty epilogue
         ,
         boundaryStr, 
         boundaryStr
    ];
    NSData *bodypreffix = [bodyPrefixStr dataUsingEncoding:NSASCIIStringEncoding];
    NSData *bodySuffix = [bodySuffixStr dataUsingEncoding:NSASCIIStringEncoding];
    
    NSNumber *fileLengthNum = (NSNumber *) [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] objectForKey:NSFileSize];

    unsigned long long bodyLength = (unsigned long long) [bodypreffix length]
     + [fileLengthNum unsignedLongLongValue]
     + (unsigned long long) [bodySuffix length];

    // Open a connection for the URL, configured to POST the file.
    
    request = [NSMutableURLRequest requestWithURL:url];
    assert(request != nil);
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", boundaryStr] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%llu", bodyLength] forHTTPHeaderField:@"Content-Length"];
    
    NSMutableData * body = (NSMutableData *)bodypreffix;
    [body appendData:[NSData dataWithContentsOfFile:filePath]];
    [body appendData:bodySuffix];
    
    [request setHTTPBody:body];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
    //I'm able to get headers casting to NSHTTPURLResponse.
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    
    NSLog(@"didReceiveResponse description:%@", httpResponse.description);
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError description: %@", error.description);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
