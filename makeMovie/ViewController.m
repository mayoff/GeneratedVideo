//
//  ViewController.m
//  makeMovie
//
//  Created by Rob Mayoff on 4/25/15.
//  Copyright (c) 2015 Rob Mayoff. All rights reserved.
//

#import "ViewController.h"
#import "DqdGeneratedVideo.h"
#import "TestFrameGenerator.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressView.hidden = NO;
    self.activityIndicator.hidden = YES;
    self.textView.hidden = YES;
    self.progressView.progress = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    __weak ViewController *me = self;
    TestFrameGenerator *generator = [[TestFrameGenerator alloc] init];
    generator.frameGeneratedCallback = ^{
        ViewController *self = me;
        if (generator.framesEmittedCount == generator.totalFramesCount) {
            self.progressView.hidden = YES;
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
        } else {
            self.progressView.progress = (float)generator.framesEmittedCount / generator.totalFramesCount;
        }
    };

    NSURL *url = [[self documentDirectoryURL] URLByAppendingPathComponent:@"video.m4v"];
    NSLog(@"path = %@", url.path);

    DqdGeneratedVideo *video = [[DqdGeneratedVideo alloc] initWithOutputURL:url frameGenerator:generator];
    [video whenVideoIsFullyWritten:^{
        [self.activityIndicator stopAnimating];
    } ifError:^(NSError *error) {
        [self showError:error];
    }];
}

- (NSURL *)documentDirectoryURL {
    return [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
}

- (void)showError:(NSError *)error {
    self.progressView.hidden = YES;
    self.activityIndicator.hidden = YES;
    self.textView.hidden = NO;
    self.textView.text = error.description;
}

@end
