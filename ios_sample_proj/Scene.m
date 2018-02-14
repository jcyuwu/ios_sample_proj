//
//  Scene.m
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import "Scene.h"

@implementation Scene

- (instancetype)initWithSceneName:(NSString *)name parkName:(NSString *)park {
    self = [super init];
    if (self) {
        _name = name;
        _parkName = park;
    }
    return self;
}

- (instancetype)init {
    return [self initWithSceneName:@"急公好義坊" parkName:@"二二八和平公園"];
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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.parkName forKey:@"parkName"];
    [aCoder encodeObject:self.sceneKey forKey:@"sceneKey"];
}

@end
