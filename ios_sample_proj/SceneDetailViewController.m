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

@interface SceneDetailViewController () <UIScrollViewDelegate>

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
@property (strong, nonatomic) UIScrollView *relativeScrollView;

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
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    sv.delegate = self;
    self.relativeScrollView = sv;
    UIImageView *prev = nil;
    for (int i = 0; i != arr.count; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i*85, 0, 80, 80)];
        iv.backgroundColor = [UIColor grayColor];
        [self.arrRelativeImageView addObject:iv];
        
        Scene *s = arr[i];
        [ImageStore sharedStore].indexPathsDict[s.imageKey] = [NSIndexPath indexPathForRow:i inSection:self.indexPath.section];
        iv.image = [[ImageStore sharedStore] imageForKey:s.imageKey];
        iv.userInteractionEnabled = true;
        iv.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRelativeImageView:)];
        [iv addGestureRecognizer:tap];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(i*85, 85, 80, 15)];
        l.font = [UIFont systemFontOfSize:13];
        l.text = s.name;
        
        [sv addSubview:l];
        [sv addSubview:iv];
        [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[iv]" options:0 metrics:nil views:@{@"iv":iv}]];
        if (!prev) {
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[iv]" options:0 metrics:nil views:@{@"iv":iv}]];
        } else {
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[prev]-(5)-[iv]" options:0 metrics:nil views:@{@"iv":iv, @"prev":prev}]];
        }
        prev = iv;
        
        if (i == (arr.count-1)) {
            //sv.contentSize = CGSizeMake((i+1)*100, 80);
        }
    }
    [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(20)-|" options:0 metrics:nil views:@{@"prev":prev}]];
    [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[prev]-(0)-|" options:0 metrics:nil views:@{@"prev":prev}]];
    
    [self.relativeView addSubview:sv];
    [self.relativeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sv]|" options:0 metrics:nil views:@{@"sv":sv}]];
    [self.relativeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sv]|" options:0 metrics:nil views:@{@"sv":sv}]];
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

- (void)tapRelativeImageView:(UITapGestureRecognizer *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.view.tag inSection:self.indexPath.section];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SceneDetailViewController *sdvc = (SceneDetailViewController *)[sb instantiateViewControllerWithIdentifier:@"SceneDetailViewController"];
    sdvc.indexPath = indexPath;
    //[self.navigationController pushViewController:sdvc animated:NO];
    NSArray *vcs = @[self.navigationController.viewControllers[0], sdvc];
    [self.navigationController setViewControllers:vcs animated:NO];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.relativeScrollView]) {
        for (int i = 0; i != self.arrRelativeImageView.count; i++) {
            UIImageView *iv = self.arrRelativeImageView[i];
            if (!iv.image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateRelativeImageViewWithIndex:i];
                });
            }
        }
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
