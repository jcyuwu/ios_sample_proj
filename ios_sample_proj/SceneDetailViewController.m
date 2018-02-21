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

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *parkNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *openTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;
@property (weak, nonatomic) IBOutlet UIView *relativeView;
@property (strong, nonatomic) NSMutableArray *arrRelativeImageView;

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
    
    [self configureView];
    
    self.arrRelativeImageView = [[NSMutableArray alloc] init];
    NSArray *arr = [SceneStore sharedStore].arrParkToScenes[self.indexPath.section];
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.relativeView.bounds];
    for (int i = 0; i != arr.count; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i*100, 0, 80, 80)];
        iv.backgroundColor = [UIColor grayColor];
        [self.arrRelativeImageView addObject:iv];
        
        Scene *s = arr[i];
        [ImageStore sharedStore].indexPathsDict[s.imageKey] = [NSIndexPath indexPathForRow:i inSection:self.indexPath.section];
        iv.image = [[ImageStore sharedStore] imageForKey:s.imageKey];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(i*100, 85, 80, 15)];
        l.text = s.name;
        
        [sv addSubview:l];
        [sv addSubview:iv];
        if (i == (arr.count-1)) {
            sv.contentSize = CGSizeMake((i+1)*100, 80);
        }
    }
    [self.relativeView addSubview:sv];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishImageCallback:) name:@"finishImageCallback" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishImageCallback" object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        self.content1WidthConstraint.constant = self.view.bounds.size.width;
        self.imageViewHeightConstraint.constant = self.view.bounds.size.height/3.0;
    } else {
        self.content1WidthConstraint.constant = self.view.bounds.size.width;
        self.imageViewHeightConstraint.constant = self.view.bounds.size.height*2/3.0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView {
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

- (void)updateRelativeImageViewWithIndex:(NSInteger)index {
    UIImageView *iv = self.arrRelativeImageView[index];
    Scene *s = [SceneStore sharedStore].arrParkToScenes[self.indexPath.section][index];
    [ImageStore sharedStore].indexPathsDict[s.imageKey] = [NSIndexPath indexPathForRow:index inSection:self.indexPath.section];
    iv.image = [[ImageStore sharedStore] imageForKey:s.imageKey];
}

- (void)finishImageCallback:(NSNotification *)note {
    NSDictionary *dict = note.userInfo;
    NSIndexPath *indexPath = [dict valueForKeyPath:@"indexPath"];
    
    if ([indexPath isEqual:self.indexPath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureView];
            [self updateRelativeImageViewWithIndex:indexPath.row];
        });
    } else if (indexPath.section == self.indexPath.section) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateRelativeImageViewWithIndex:indexPath.row];
        });
    }
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
