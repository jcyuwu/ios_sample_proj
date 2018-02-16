//
//  SceneStore.m
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import "SceneStore.h"
#import "Scene.h"
#import "ImageStore.h"

@interface SceneStore ()

@property (nonatomic) NSMutableArray *privateScenes;
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray *> *parkToScenes;
@property (nonatomic) NSURLSession *session;

@end

@implementation SceneStore

+ (instancetype)sharedStore {
    static SceneStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    return sharedStore;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"singleton" reason:@"use +[SceneStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        NSString *path = [self sceneArchivePath];
        _privateScenes = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!_privateScenes) {
            _privateScenes = [[NSMutableArray alloc] init];
        }
        
        _parkToScenes = [[NSMutableDictionary alloc] init];
        for (Scene *scene in _privateScenes) {
            if (![[_parkToScenes allKeys] containsObject:scene.parkName]) {
                _parkToScenes[scene.parkName] = [NSMutableArray arrayWithObject:scene];
            } else {
                [_parkToScenes[scene.parkName] addObject:scene];
            }
        }
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    }
    return self;
}

- (NSArray *)allScenes {
    return self.privateScenes;
}

- (void)removeScene:(Scene *)scene {
    NSString *key = scene.sceneKey;
    [[ImageStore sharedStore] deleteImageForKey:key];
    [self.privateScenes removeObjectIdenticalTo:scene];
}

- (NSString *)sceneArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"Scenes.archive"];
}

- (BOOL)saveChanges {
    NSString *path = [self sceneArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.privateScenes toFile:path];
}

- (Scene *)createScene {
    Scene *scene = [[Scene alloc] init];
    [self.privateScenes addObject:scene];
    return scene;
}

- (void)fetchScene {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self sceneArchivePath]]) {
        NSString *requestString = @"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=bf073841-c734-49bf-a97f-3757a6013812";
        NSURL *url = [NSURL URLWithString:requestString];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *dict in [jsonObject valueForKeyPath:@"result.results"]) {
                NSString *name = [dict valueForKeyPath:@"Name"];
                NSString *parkName = [dict valueForKeyPath:@"ParkName"];
                Scene *scene = [[Scene alloc] initWithSceneName:name parkName:parkName];
                [self.privateScenes addObject:scene];
                NSLog(@"%@", scene.name);
            }
            
            for (Scene *scene in self.privateScenes) {
                if (![[self.parkToScenes allKeys] containsObject:scene.parkName]) {
                    self.parkToScenes[scene.parkName] = [NSMutableArray arrayWithObject:scene];
                } else {
                    [self.parkToScenes[scene.parkName] addObject:scene];
                }
            }
            [self saveChanges];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchSceneCallback" object:nil userInfo:nil];
            });
            
        }];
        [dataTask resume];
    }
}

@end
