//
//  LocalMovieViewController.m
//  IntroSequence
//
//  Created by Sarah Allen on 6/6/15.
//  Copyright (c) 2015 Mightyverse. All rights reserved.
//

#import "LocalMovieViewController.h"

@interface LocalMovieViewController ()
-(NSURL *)localMovieURL;
@end

@implementation LocalMovieViewController


/* Returns a URL to a local movie in the app bundle. */
-(NSURL *)localMovieURL
{
    NSURL *theMovieURL = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle)
    {
        NSString *moviePath = [bundle pathForResource:@"judy-tuan-89e52b2c-0940-4fc1-e538-5b014b1f05ee-you-are-awesome"
                                               ofType:@"mp4"];
        if (moviePath)
        {
            theMovieURL = [NSURL fileURLWithPath:moviePath];
        }
    }
    return theMovieURL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad LocalMovieViewController");
    NSURL *movieUrl = [self localMovieURL];
    NSLog([ movieUrl absoluteString]);

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
