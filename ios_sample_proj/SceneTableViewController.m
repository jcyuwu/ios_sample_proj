//
//  SceneTableViewController.m
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import "SceneTableViewController.h"
#import "SceneCell.h"
#import "SceneStore.h"
#import "Scene.h"
#import "ImageStore.h"
#import "SceneDetailViewController.h"

@interface SceneTableViewController ()

@end

@implementation SceneTableViewController

/*- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [[SceneStore sharedStore] createScene];
    }
    return self;
}*/

- (void)loadView {
    [super loadView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchSceneCallback:) name:@"fetchSceneCallback" object:nil];
    [[SceneStore sharedStore] fetchScene];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //self.tableView.estimatedRowHeight = 44.0;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressImageCallback:) name:@"progressImageCallback" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishImageCallback:) name:@"finishImageCallback" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"progressImageCallback" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishImageCallback" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fetchSceneCallback" object:nil];
}

- (void)fetchSceneCallback:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)progressImageCallback:(NSNotification *)note {
    NSDictionary *dict = note.userInfo;
    NSLog(@"%@", dict);
}

- (void)finishImageCallback:(NSNotification *)note {
    NSDictionary *dict = note.userInfo;
    NSIndexPath *indexPath = [dict valueForKeyPath:@"indexPath"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[SceneStore sharedStore].arrParkToScenes count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[SceneStore sharedStore].arrParkToScenes[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scene cell" forIndexPath:indexPath];
    Scene *scene = [SceneStore sharedStore].arrParkToScenes[indexPath.section][indexPath.row];
    cell.nameLabel.text = scene.name;
    cell.parkNameLabel.text = scene.parkName;
    cell.introductionLabel.text = scene.introduction;
    
    [ImageStore sharedStore].indexPathsDict[scene.imageKey] = indexPath;
    UIImage *image = [[ImageStore sharedStore] imageForKey:scene.imageKey];
    cell.thumbnailView.image = image;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Scene *scene = [[SceneStore sharedStore].arrParkToScenes[section] firstObject];
    return scene.parkName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SceneDetailViewController *sdvc = (SceneDetailViewController *)[sb instantiateViewControllerWithIdentifier:@"SceneDetailViewController"];
    sdvc.indexPath = indexPath;
    [self.navigationController pushViewController:sdvc animated:NO];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
