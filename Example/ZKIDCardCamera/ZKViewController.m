//
//  ZKViewController.m
//  ZKIDCardCamera
//
//  Created by deyang143@126.com on 09/21/2018.
//  Copyright (c) 2018 deyang143@126.com. All rights reserved.
//

#import "ZKViewController.h"
#import <Masonry/Masonry.h>
#import <ZKIDCardCamera/ZKIDCardCameraController.h>
#import <ZKIDCardCamera/ZKIDTools.h>

@interface ZKViewController ()<ZKIDCardCameraControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.imageView = [[UIImageView alloc] init];
    [self.view addSubview:self.imageView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = CGRectMake(20, 44, 316, 200);
    self.imageView.backgroundColor = UIColor.blueColor;
}

#pragma mark - events Handler

- (IBAction)front {
    ZKIDCardCameraController *controller = [[ZKIDCardCameraController alloc] initWithType:ZKIDCardTypeFront];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)reverse:(id)sender {
    ZKIDCardCameraController *controller = [[ZKIDCardCameraController alloc] initWithType:ZKIDCardTypeReverse];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    controller.delegate = self;
    controller.limitSize = 1024 * 1024;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - ZKIDCardCameraControllerDelegate
- (void)cameraDidFinishShootWithCameraImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)imageNeedLimit:(UIImage *)image {
    NSLog(@"超过限制大小1MB");
    NSData *data = [ZKIDTools compressToDataWithImage:image showSize:image.size fileSize:1024];
    NSLog(@"文件大小：%fMB",data.length / 1024 / 1024.0);
}

@end
