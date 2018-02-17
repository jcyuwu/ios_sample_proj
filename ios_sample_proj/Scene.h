//
//  Scene.h
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scene : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *parkName;
@property (nonatomic, copy) NSString *sceneKey;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, copy) NSString *openTime;
- (instancetype)initWithSceneName:(NSString *)name parkName:(NSString *)park introduction:(NSString *)intro openTime:(NSString *)openTime;

@end
