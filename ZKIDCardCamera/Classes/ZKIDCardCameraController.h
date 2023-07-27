//
//  ZKIDCardCameraController.h
//  FBSnapshotTestCase
//
//  Created by zhangkai on 2018/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKIDCardType) {
    ZKIDCardTypeFront,
    ZKIDCardTypeReverse,
};

@protocol ZKIDCardCameraControllerDelegate <NSObject>

@required

/// 获取身份证照片，当图片大小超过限制，则会在imageNeedLimit返回
/// - Parameter image: 图片
- (void)cameraDidFinishShootWithCameraImage:(UIImage *)image;


/// 获取身份证照片，当图片大小超过限制生效，考虑UI交互，ZKIDTools仅提供方法
/// - Parameter image: 图片
- (void)imageNeedLimit:(UIImage *)image;

@end

@interface ZKIDCardCameraController : UIViewController

@property (nonatomic, weak) id<ZKIDCardCameraControllerDelegate> delegate;

- (instancetype)initWithType:(ZKIDCardType)type;

/// 限制文件大小（单位：字节），默认0，代表不限制
@property (nonatomic, assign) NSInteger limitSize;

@end

NS_ASSUME_NONNULL_END
