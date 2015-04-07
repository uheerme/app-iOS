//
//  ViewController.m
//  SameSound
//
//  Created by Mac Mini on 17/03/2015.
//
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageLabels = @[@"1", @"2", @"3", @"4", @"5"];
    
    //Create page view controller.
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //Change the size of the page view controller.
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index ==0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == [self.pageLabels count]) {
        return nil;
    }
    
    index++;
    return [self viewControllerAtIndex:index];
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index{
    if(([self.pageLabels count] == 0) || (index >= [self.pageLabels count])){
        return nil;
    }
    
    PageContentViewController *pageContentViewController = nil;
    
    if (index == 0) {
        //Load view controller with the Post method.
        pageContentViewController = (PageContentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
    }else if(index == 1){
        pageContentViewController = (PageContentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PostMusicViewController"];
    }else if(index == 2){
        pageContentViewController = (PageContentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GetMusicViewController"];
    }else{
        pageContentViewController = (PageContentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
        //pageContentViewController.screenNumber = self.pageLabels[index];
    }    
    pageContentViewController.pageIndex = index;

    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return [self.pageLabels count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
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
