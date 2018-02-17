//
//  Scene.h
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

@interface Scene : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *parkName;
@property (nonatomic, copy) NSString *imageKey;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, copy) NSString *openTime;
@property (nonatomic, strong) UIImage *thumbnail;
- (instancetype)initWithSceneName:(NSString *)name parkName:(NSString *)park imageKey:(NSString *)imageKey introduction:(NSString *)intro openTime:(NSString *)openTime;
- (void)setThumbnailFromImage:(UIImage *)image;

@end
