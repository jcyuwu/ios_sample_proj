//
//  Scene.m
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import "Scene.h"

@implementation Scene

- (instancetype)initWithSceneName:(NSString *)name parkName:(NSString *)park introduction:(NSString *)intro openTime:(NSString *)openTime {
    self = [super init];
    if (self) {
        _name = name;
        _parkName = park;
        _introduction = intro;
        _openTime = openTime;
    }
    return self;
}

- (instancetype)init {
    return [self initWithSceneName:@"急公好義坊" parkName:@"二二八和平公園" introduction:@"臺北府淡水縣貢生洪騰雲，因臺北府城建造考棚行署，捐獻田地銀兩有功，巡府劉銘傳奏請建坊獎勵，於光緒14年西元1888年坊成，原立於今衡陽路上，至日據時期拆遷至現址，雕琢精美，為臺北最典型之清代石坊。" openTime:@"00:00~24:00"];
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
        _sceneKey = [aDecoder decodeObjectForKey:@"sceneKey"];
        _introduction = [aDecoder decodeObjectForKey:@"introduction"];
        _openTime = [aDecoder decodeObjectForKey:@"openTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.parkName forKey:@"parkName"];
    [aCoder encodeObject:self.sceneKey forKey:@"sceneKey"];
    [aCoder encodeObject:self.introduction forKey:@"introduction"];
    [aCoder encodeObject:self.openTime forKey:@"openTime"];
}

@end
