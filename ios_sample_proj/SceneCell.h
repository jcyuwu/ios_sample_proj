//
//  SceneCell.h
//  ios_sample_proj
//
//  Created by JCY on 2018/2/18.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SceneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *parkNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;

@end
