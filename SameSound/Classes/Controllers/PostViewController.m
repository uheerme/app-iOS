//
//  PostViewController.m
//  SameSound
//
//  Created by Mac Mini on 17/03/2015.
//
//

#import "PostViewController.h"
#import "NetworkManager.h"

@interface PostViewController ()

@property (weak, nonatomic) IBOutlet UITextField *channelNameInput;
@property (weak, nonatomic) IBOutlet UITextField *ownerText;
@property (weak, nonatomic) IBOutlet UITextField *urlText;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong, readwrite) NSURLConnection *  connection;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)postAction:(id)sender {
    [self startSend];
}

- (void)startSend{
    BOOL success;
    NSURL * url;
    NSMutableURLRequest * request;
    
    NSLog(@"startSend");
    
    assert(self.connection == nil);         // don't tap receive twice in a row!
    
    NSData * channelData = [self transformToJson];
    assert(channelData != nil);
    
    // First get and check the URL.
    url = [[NetworkManager sharedInstance] smartURLForString:self.urlText.text];
    success = (url != nil);
    
    if(!success){
        self.statusLabel.text = @"Invalid URL";
    }else{
        request = [NSMutableURLRequest requestWithURL:url];
        assert(request != nil);
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:channelData];
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
        
        NSLog(@"%@" , self.connection.description);
        
        // Make other threads aware.
        [[NetworkManager sharedInstance] didStartNetworkOperation];
    }

}

- (NSData*)transformToJson{
    NSError *jsonError;
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:self.channelNameInput.text, @"name", self.ownerText.text, @"owner", nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
    NSLog(jsonDict.description);
    
    if(jsonError == nil){
        return jsonData;
    }
    
    NSLog(@"Error in JSON Serialization: %@",jsonError.description);
    self.statusLabel.text = @"JSON serialization error";
    self.connection = nil;
    return nil;
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
