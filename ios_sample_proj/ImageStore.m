//
//  ImageStore.m
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import "ImageStore.h"
#import <UIKit/UIApplication.h>

@interface ImageStore () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic) NSURLSession *session;

@end

@implementation ImageStore

+ (instancetype)sharedStore {
    static ImageStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    return sharedStore;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"singleton" reason:@"use +[ImageStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)clearCache:(NSNotification *)note {
    NSLog(@"flushing %lu images out of the cache", (unsigned long)[self.dictionary count]);
    [self.dictionary removeAllObjects];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    self.dictionary[key] = image;
    NSString *imagePath = [self imagePathForKey:key];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    [data writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)key {
    UIImage *result = self.dictionary[key];
    if (!result) {
        NSString *imagePath = [self imagePathForKey:key];
        result = [UIImage imageWithContentsOfFile:imagePath];
        if (result) {
            self.dictionary[key] = result;
        } else {
            NSLog(@"error: unable to find %@", imagePath);
            
            NSString *requestString = key;
            NSURL *url = [NSURL URLWithString:requestString];
            NSURLRequest *req = [NSURLRequest requestWithURL:url];
            NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:req];
            [task resume];
        }
    }
    return result;
}

- (void)deleteImageForKey:(NSString *)key {
    if (!key) {
        return;
    }
    [self.dictionary removeObjectForKey:key];
    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

- (NSString *)imagePathForKey:(NSString *)key {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    NSURL *url = [NSURL URLWithString:key];
    NSString *fileName = [url.pathComponents lastObject];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location { 
    NSString *key = [downloadTask.originalRequest.URL absoluteString];
    NSData *imageData = [NSData dataWithContentsOfFile:location.path];
    [self setImage:[UIImage imageWithData:imageData] forKey:key];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progressImageCallback" object:nil userInfo:@{@"key" : [downloadTask.originalRequest.URL absoluteString], @"progress" : [NSNumber numberWithDouble:1.0*totalBytesWritten/totalBytesExpectedToWrite]}];
    });
}

@end
