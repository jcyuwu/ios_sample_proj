//
//  ImageStore.m
//  ios_sample_proj
//
//  Created by JCY on 2018/2/14.
//  Copyright © 2018年 KyosJhong. All rights reserved.
//

#import "ImageStore.h"
#import <UIKit/UIKit.h>

@interface ImageStore () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) NSMutableDictionary *tasksDict;
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
        _tasksDict = [[NSMutableDictionary alloc] init];
        _indexPathsDict = [[NSMutableDictionary<NSString *, NSIndexPath *> alloc] init];
        
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


- (UIImage *)thumbnailFromImage:(UIImage *)image {
    CGSize originImageSize = image.size;
    CGRect newRect = CGRectMake(0, 0, 80, 80);
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
    
    UIGraphicsEndImageContext();
    return smallImage;
}

- (NSString *)thumbnailPathForKey:(NSString *)key {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    NSURL *url = [NSURL URLWithString:key];
    NSString *fileName = [url.pathComponents lastObject];
    return [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"ss%@", fileName]];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    self.dictionary[key] = [self thumbnailFromImage:image];
    
    NSString *path = [self thumbnailPathForKey:key];
    NSData *data = UIImageJPEGRepresentation([self thumbnailFromImage:image], 0.5);
    [data writeToFile:path atomically:YES];
    
    NSString *imagePath = [self imagePathForKey:key];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    [imageData writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)key {
    UIImage *result = self.dictionary[key];
    if (!result) {
        NSString *path = [self thumbnailPathForKey:key];
        NSData *data = [NSData dataWithContentsOfFile:path];
        result = [UIImage imageWithData:data];
        if (!result) {
            NSString *imagePath = [self imagePathForKey:key];
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            result = [UIImage imageWithData:imageData];
        }
        if (result) {
            self.dictionary[key] = [self thumbnailFromImage:result];
        } else {
            NSLog(@"error: unable to find %@", [self imagePathForKey:key]);
            if ((![self.tasksDict valueForKey:key])&&(self.tasksDict.allKeys.count<=5)) {
                NSLog(@"downloading to %@", [self imagePathForKey:key]);
                
                NSString *requestString = key;
                NSURL *url = [NSURL URLWithString:requestString];
                NSURLRequest *req = [NSURLRequest requestWithURL:url];
                NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:req];
                [self.tasksDict setValue:task forKey:key];
                [task resume];
            }
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
    [self.tasksDict removeObjectForKey:key];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"finishImageCallback" object:nil userInfo:@{@"key" : [downloadTask.originalRequest.URL absoluteString], @"indexPath" : self.indexPathsDict[downloadTask.originalRequest.URL.absoluteString]}];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progressImageCallback" object:nil userInfo:@{@"key" : [downloadTask.originalRequest.URL absoluteString], @"progress" : [NSNumber numberWithDouble:1.0*totalBytesWritten/totalBytesExpectedToWrite], @"indexPath" : self.indexPathsDict[downloadTask.originalRequest.URL.absoluteString]}];
    });*/
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSString *key = [task.originalRequest.URL absoluteString];
    [self.tasksDict removeObjectForKey:key];
}

@end
