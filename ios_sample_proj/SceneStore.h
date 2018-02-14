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
+ (instancetype)sharedStore;
- (Scene *)createScene;

@end
