//
//  Scene.m
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import "Scene.h"
#import <UIKit/UIKit.h>

@implementation Scene

- (instancetype)initWithSceneName:(NSString *)name parkName:(NSString *)park imageKey:(NSString *)imageKey introduction:(NSString *)intro openTime:(NSString *)openTime {
    self = [super init];
    if (self) {
        _name = name;
        _parkName = park;
        _imageKey = imageKey;
        _introduction = intro;
        _openTime = openTime;
    }
    return self;
}

- (instancetype)init {
    return [self initWithSceneName:@"急公好義坊" parkName:@"二二八和平公園" imageKey:@"http://parks.taipei/parkbasic/imagespace/specialview/original/thumb_image_5117942.JPG" introduction:@"臺北府淡水縣貢生洪騰雲，因臺北府城建造考棚行署，捐獻田地銀兩有功，巡府劉銘傳奏請建坊獎勵，於光緒14年西元1888年坊成，原立於今衡陽路上，至日據時期拆遷至現址，雕琢精美，為臺北最典型之清代石坊。" openTime:@"00:00~24:00"];
}

- (NSString *)description {
    NSString *descriptionString = [NSString stringWithFormat:@"name:%@ park:%@", self.name, self.parkName];
    return descriptionString;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _parkName = [aDecoder decodeObjectForKey:@"parkName"];
        _imageKey = [aDecoder decodeObjectForKey:@"imageKey"];
        _introduction = [aDecoder decodeObjectForKey:@"introduction"];
        _openTime = [aDecoder decodeObjectForKey:@"openTime"];
        _thumbnail = [aDecoder decodeObjectForKey:@"thumbnail"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.parkName forKey:@"parkName"];
    [aCoder encodeObject:self.imageKey forKey:@"imageKey"];
    [aCoder encodeObject:self.introduction forKey:@"introduction"];
    [aCoder encodeObject:self.openTime forKey:@"openTime"];
    [aCoder encodeObject:self.thumbnail forKey:@"thumbnail"];
}

- (void)setThumbnailFromImage:(UIImage *)image {
    CGSize originImageSize = image.size;
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    float ratio = MAX(newRect.size.width / originImageSize.width, newRect.size.height / originImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    [path addClip];
    
    CGRect projectRect;
    projectRect.size.width = ratio * originImageSize.width;
    projectRect.size.height = ratio * originImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [image drawInRect:projectRect];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnail = smallImage;
    
    UIGraphicsEndImageContext();
}

@end
