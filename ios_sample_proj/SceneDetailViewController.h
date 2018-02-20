//
//  SceneDetailViewController.h
//  ios_sample_proj
//
//  Created by JCY on 2018/2/20.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SceneDetailViewController : UIViewController

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *parkNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *openTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;

@end
