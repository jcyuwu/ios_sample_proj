//
//  SceneDetailViewController.m
//  ios_sample_proj
//
//  Created by JCY on 2018/2/20.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import "SceneDetailViewController.h"

@interface SceneDetailViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content1WidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content1HeightConstraint;

@end

@implementation SceneDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.content1WidthConstraint.constant = self.view.bounds.size.width;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageView setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical];
    [self.imageView setContentCompressionResistancePriority:700 forAxis:UILayoutConstraintAxisVertical];
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
