//
//  DownloadViewCell.h
//  DemoProgressbar
//
//  Created by Honey on 4/22/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadCellViewModel;

@interface DownloadViewCell : UITableViewCell


- (void)configViewModel:(DownloadCellViewModel *)viewModel
              indexPath:(NSIndexPath *)path;
@end
