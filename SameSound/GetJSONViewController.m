//
//  GetJSONViewController.m
//  SameSound
//
//  Created by Mac Mini on 04/03/2015.
//
//

#import "GetJSONViewController.h"
#import "NetworkManager.h"

@interface GetJSONViewController ()

@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UITextField *urlText;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong, readwrite) NSURLConnection *  connection;

@end

@implementation GetJSONViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.urlText.text = @"http://samesound.cfapps.io/api/channels";
}

-(void) startReceive{
    BOOL                success;
    NSURL *             url;
    NSURLRequest *      request;
    
    NSLog(@"startReceive");
    
    assert(self.connection == nil);         // don't tap receive twice in a row!
    
    // First get and check the URL.
    url = [[NetworkManager sharedInstance] smartURLForString:self.urlText.text];
    success = (url != nil);
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.statusLabel.text = @"Invalid URL";
    } else {
        // Open a connection for the URL.
        
        request = [NSURLRequest requestWithURL:url];
        assert(request != nil);
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
        
        NSLog(@"%@" , self.connection.description);
        
        // Make other threads aware.
        
        [[NetworkManager sharedInstance] didStartNetworkOperation];
        
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{
    //I'm able to get headers casting to NSHTTPURLResponse.
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    
    NSLog(@"didReceiveResponse description:%@", httpResponse.description);
    [self.resultText setText:[NSString stringWithFormat:@"URL: %@", httpResponse.URL]];
    [self.resultText setText:[NSString stringWithFormat:@"%@\nstatusCode: %ld", self.resultText.text,httpResponse.statusCode]];
    [self.resultText setText: [NSString stringWithFormat:@"%@\nheaders: %@", self.resultText.text,[[httpResponse allHeaderFields] description]]];
    NSLog([httpResponse allHeaderFields][@"Content-type"]);
    
    if([[httpResponse allHeaderFields][@"Content-Type"] rangeOfString:@"application/json"].location == NSNotFound){
        NSLog(@"ERROR: Content-type is not JSON");
        self.statusLabel.text = @"Not JSON";
        [self.connection cancel];
        self.connection = nil;
    }
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
        [self.resultText setText:[NSString stringWithFormat:@"%@\n\nJSON data: %@", self.resultText.text, channels.description]];
    }
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError description: %@", error.description);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
    self.statusLabel.text = @"Done";
    self.connection = nil;
}

- (IBAction)getButtonPressed:(id)sender {
    [self startReceive];
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
