//
//  ViewController.m
//  DemoProgressbar
//
//  Created by Hung Nguyen on 4/19/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import "ViewController.h"
#import "CircularLoaderView.h"
#import "DownloadViewCell.h"
#import "DownloadCellViewModel.h"

@interface ViewController ()
<NSURLSessionDownloadDelegate,
    CircularLoaderViewDelegate,
UITableViewDelegate,
UITableViewDataSource
>
{
    NSURLSessionTask *task;
    NSURLSession *session;
    NSURLRequest *request;
    NSArray *downloadSample;
}
@property (weak, nonatomic) IBOutlet CircularLoaderView *circularLoadView_;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    
    NSString *str = @"http://ipv4.download.thinkbroadband.com/5MB.zip";
    NSURL *url = [NSURL URLWithString:str];
    request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    task = [session downloadTaskWithRequest:request];
    self.circularLoadView_.delegate = self;
    downloadSample = @[
                       @"http://ipv4.download.thinkbroadband.com/5MB.zip",
                       @"http://ipv4.download.thinkbroadband.com/5MB.zip",
                       @"http://ipv4.download.thinkbroadband.com/5MB.zip",
                       @"http://ipv4.download.thinkbroadband.com/5MB.zip",
      @"http://1.bp.blogspot.com/-ncT0UA1cffc/Vyibv_xXP5I/AAAAAAAOGrw/9gtl6ECMgOg/s0/bt3627-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-010.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-6QnvSlNmIlY/Vyibw5n4DVI/AAAAAAAOGr4/aEJ7uQ0bJhY/s0/bt3631-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-011.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-aRPH7Th6tO0/VyibxtLbG4I/AAAAAAAOGsA/gY11_mWp3Yg/s0/bt3634-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-012.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-RWJT2uiWwIY/Vyibyi8qxvI/AAAAAAAOGsI/Zen4tVPbq7s/s0/bt3638-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-013.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-BWSlbTPPGdM/VyibzaG3uyI/AAAAAAAOGsQ/CRkBQE6Empg/s0/bt3641-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-014.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-FJcjEn9gHRM/Vyib0OTi9qI/AAAAAAAOGsY/SyyFn0amFnA/s0/bt3644-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-015.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-J4Kz84JCPmQ/Vyib0-EDeAI/AAAAAAAOGsg/bR6os2gStMY/s0/bt3647-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-016.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-BMwdNqCmqjQ/Vyib1hslyNI/AAAAAAAOGss/-ZKPFEoatV4/s0/bt3650-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-017.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-oMCpMGYUN9w/Vyib2q3MWDI/AAAAAAAOGs0/hiQc9G3tNbY/s0/bt3654-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-018.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-tAtXSVhrRCQ/Vyib3R44mcI/AAAAAAAOGs8/t_TCXrIM4wI/s0/bt3657-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-019.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-nkvLLXSmDiY/Vyib4Q19BDI/AAAAAAAOGtI/zf4BToX5dQ8/s0/bt3701-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-020.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-k2P1QLvuWtE/Vyib5bEYn-I/AAAAAAAOGtQ/3rCwTscgaiI/s0/bt3705-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-021.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-sSmNT1KfM8w/Vyib6I70s1I/AAAAAAAOGtY/faYaWlW1IsM/s0/bt3708-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-022.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-uK3Z9GtBmLA/Vyib63Az-HI/AAAAAAAOGtg/xhdDnR4bLZk/s0/bt3711-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-023.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-ncT0UA1cffc/Vyibv_xXP5I/AAAAAAAOGrw/9gtl6ECMgOg/s0/bt3627-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-010.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-6QnvSlNmIlY/Vyibw5n4DVI/AAAAAAAOGr4/aEJ7uQ0bJhY/s0/bt3631-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-011.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-aRPH7Th6tO0/VyibxtLbG4I/AAAAAAAOGsA/gY11_mWp3Yg/s0/bt3634-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-012.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-RWJT2uiWwIY/Vyibyi8qxvI/AAAAAAAOGsI/Zen4tVPbq7s/s0/bt3638-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-013.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-BWSlbTPPGdM/VyibzaG3uyI/AAAAAAAOGsQ/CRkBQE6Empg/s0/bt3641-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-014.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-FJcjEn9gHRM/Vyib0OTi9qI/AAAAAAAOGsY/SyyFn0amFnA/s0/bt3644-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-015.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-J4Kz84JCPmQ/Vyib0-EDeAI/AAAAAAAOGsg/bR6os2gStMY/s0/bt3647-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-016.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-BMwdNqCmqjQ/Vyib1hslyNI/AAAAAAAOGss/-ZKPFEoatV4/s0/bt3650-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-017.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-oMCpMGYUN9w/Vyib2q3MWDI/AAAAAAAOGs0/hiQc9G3tNbY/s0/bt3654-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-018.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-tAtXSVhrRCQ/Vyib3R44mcI/AAAAAAAOGs8/t_TCXrIM4wI/s0/bt3657-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-019.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-nkvLLXSmDiY/Vyib4Q19BDI/AAAAAAAOGtI/zf4BToX5dQ8/s0/bt3701-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-020.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-k2P1QLvuWtE/Vyib5bEYn-I/AAAAAAAOGtQ/3rCwTscgaiI/s0/bt3705-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-021.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-sSmNT1KfM8w/Vyib6I70s1I/AAAAAAAOGtY/faYaWlW1IsM/s0/bt3708-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-022.jpg?imgmax=0",
      @"http://1.bp.blogspot.com/-uK3Z9GtBmLA/Vyib63Az-HI/AAAAAAAOGtg/xhdDnR4bLZk/s0/bt3711-hiep-khach-giang-ho-truyentranhtuan-com-chap-500-trang-023.jpg?imgmax=0"];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                              didFinishDownloadingToURL:(NSURL *)location {
    [self.circularLoadView_ doneDownload];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float progess = (float)totalBytesWritten / totalBytesExpectedToWrite;
//        NSLog(@"progress: %f", progess);
        self.circularLoadView_.circleRadius = progess;
}

- (void)circularLoaderViewDidPressStart:(CircularLoaderView *)circularLoaderView {
    if (task.state != NSURLSessionTaskStateRunning) {
        task = [session downloadTaskWithRequest:request];
        [task resume];
    }
}

- (void)circularLoaderViewDidPressCancel:(CircularLoaderView *)circularLoaderView {
    [task suspend];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return downloadSample.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadViewCell *cell = (DownloadViewCell *)[tableView
                                                  dequeueReusableCellWithIdentifier:@"DownloadViewCell"
                                                  forIndexPath:indexPath];
    NSString *urlStr = downloadSample[indexPath.row];
    NSURL *url = [NSURL URLWithString:urlStr];
    DownloadCellViewModel *viewModel = [[DownloadCellViewModel alloc] initWithURL:url];
    [cell configViewModel:viewModel indexPath:indexPath];
    viewModel.url = url;
    
    return cell;
}


@end
