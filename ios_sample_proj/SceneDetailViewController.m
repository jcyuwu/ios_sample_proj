//
//  SceneDetailViewController.m
//  ios_sample_proj
//
//  Created by JCY on 2018/2/20.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import "SceneDetailViewController.h"
#import "SceneStore.h"
#import "Scene.h"
#import "ImageStore.h"

@interface SceneDetailViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content1WidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content1HeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation SceneDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.content1WidthConstraint.constant = self.view.bounds.size.width;
    self.imageViewHeightConstraint.constant = self.view.bounds.size.height/3.0;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageView setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical];
    [self.imageView setContentCompressionResistancePriority:700 forAxis:UILayoutConstraintAxisVertical];
    
    Scene *scene = [SceneStore sharedStore].arrParkToScenes[self.indexPath.section][self.indexPath.row];
    self.nameLabel.text = scene.name;
    self.parkNameLabel.text = scene.parkName;
    self.openTimeLabel.text = [NSString stringWithFormat:@"開放時間：%@", scene.openTime];
    self.introductionLabel.text = scene.introduction;
    
    [ImageStore sharedStore].indexPathsDict[scene.imageKey] = self.indexPath;
    [[ImageStore sharedStore] imageForKey:scene.imageKey];
    NSString *imagePath = [[ImageStore sharedStore] imagePathForKey:scene.imageKey];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
    self.imageView.image = image;
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
