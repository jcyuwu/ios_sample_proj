//
//  SceneStore.h
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Scene;

@interface SceneStore : NSObject

@property (nonatomic, readonly) NSArray *allScenes;
@property (nonatomic, readonly) NSArray<NSArray *> *arrParkToScenes;
+ (instancetype)sharedStore;
- (Scene *)createScene;
- (void)fetchScene;
- (void)getAccessToken;
- (NSString *)sceneArchivePath;

@end
