//
//  GetImageViewController.m
//  SameSound
//
//  Created by Mac Mini on 04/03/2015.
//
//

#import "GetImageViewController.h"

#import "NetworkManager.h"
#import "Synchronizer.h"

@interface GetImageViewController () <SynchronizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property int counter;
@property (nonatomic, strong, readwrite) NSURLConnection *                  connection;
@property (nonatomic, strong) Synchronizer *                                synchronizer;
@property (nonatomic, copy,   readwrite) NSString *                         filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *                   fileStream;
@property (weak, nonatomic) IBOutlet UITextField *urlText;

@end

@implementation GetImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.counter = 0;
}

- (IBAction)synchronizeAction:(id)sender {
    self.synchronizer = [[Synchronizer alloc] initWithDelegate:self];
}

-(void)systemAndServerClockDifference:(NSTimeInterval) serverDifference{
    NSLog(@"serverDifference: %f", serverDifference);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getButtonAction:(id)sender {
    self.counter ++;
    NSString *finalText = @"Get Pressed ";
    finalText = [finalText  stringByAppendingString:[NSString stringWithFormat:@"%d", self.counter]];
    [self.statusLabel setText:finalText];
    
    [self startReceive];
}

- (void)startReceive{
    // Starts a connection to download the current URL.
    BOOL                success;
    NSURL *             url;
    NSURLRequest *      request;
    
    assert(self.connection == nil);         // don't tap receive twice in a row!
    assert(self.fileStream == nil);         // ditto
    assert(self.filePath == nil);           // ditto
    
    // First get and check the URL.
    
    url = [[NetworkManager sharedInstance] smartURLForString:self.urlText.text];
    success = (url != nil);
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.statusLabel.text = @"Invalid URL";
    } else {
        
        // Open a stream for the file we're going to receive into.
        
        self.filePath = [[NetworkManager sharedInstance] pathForTemporaryFileWithPrefix:@"Get"];
        assert(self.filePath != nil);
        
        self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
        // Open a connection for the URL.

        request = [NSURLRequest requestWithURL:url];
        assert(request != nil);
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
    
        NSLog([self.connection description]);
        NSLog([url description]);

        // Make other threads aware.
        
        [[NetworkManager sharedInstance] didStartNetworkOperation];

    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"didReceiveResponse");
    NSLog(response.description);
    
    #pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    assert(theConnection == self.connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } else {
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
        // the string, so we can just use -isEqual: on the result.
        contentTypeHeader = [httpResponse MIMEType];
        if (contentTypeHeader == nil) {
            [self stopReceiveWithStatus:@"No Content-Type!"];
        } else if ( ! [contentTypeHeader isEqual:@"image/jpeg"]
                   && ! [contentTypeHeader isEqual:@"image/png"]
                   && ! [contentTypeHeader isEqual:@"image/gif"] ) {
            [self stopReceiveWithStatus:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
        } else {
            self.statusLabel.text = @"Response OK.";
        }
    }
}

- (void)stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil)
// or the error status (otherwise).
{
    NSLog(@"stopReceiveWithStatus");
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    [self receiveDidStopWithStatus:statusString];
    self.filePath = nil;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  We just
// write the data to the file.
{
    NSLog(@"\n\ndidReceiveData");
    NSLog(data.description);

    #pragma unused(theConnection)
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    assert(theConnection == self.connection);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [self stopReceiveWithStatus:@"File write error"];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
}

- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        assert(self.filePath != nil);
        self.imageView.image = [UIImage imageWithContentsOfFile:self.filePath];
        statusString = @"GET succeeded";
    }
    self.statusLabel.text = statusString;
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
    NSLog(@"didFailWithError");
    NSLog([error description]);
    assert(theConnection == self.connection);
    
    [self stopReceiveWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
    NSLog(@"connectionDidFinishLoading");
    [self stopReceiveWithStatus:nil];
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
