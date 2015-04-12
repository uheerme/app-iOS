//
//  PostMusicViewController.m
//  SameSound
//
//  Created by Mac Mini on 24/03/2015.
//
//

#import "PostMusicViewController.h"
#import "NetworkManager.h"
#import "RESTHelper.h"

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

-(void)startSendMusic{
    BOOL success;
    NSURL * url;
    NSURLRequest * request;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"relicario-cut" ofType:@"mp3"];
    NSLog(@"%@",filePath);
    
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

    // Open a connection for the URL, configured to POST the file.
    
    NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:@"JPMusicIOS", @"Name", @"9", @"ChannelID", nil];
    
//    NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:@"1005", @"ChannelID", nil];
    
    request = [RESTHelper postFile:filePath withFields:fields toURL:url];
    
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

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data{
    NSError * JSONError;
    NSDictionary * channels = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
    
    self.statusLabel.text = @"Receiving";
    
    if(JSONError != nil){
        NSLog(@"Error in JSON Serialization: %@", JSONError.description);
        self.statusLabel.text = @"JSON Serialization error";
        self.connection = nil;
    }else{
        NSLog(@"JSON Response: %@", channels.description);
    }
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
