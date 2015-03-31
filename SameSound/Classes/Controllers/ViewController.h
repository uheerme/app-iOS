//
//  ViewController.h
//  SameSound
//
//  Created by Mac Mini on 17/03/2015.
//
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface ViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageLabels;

@end
