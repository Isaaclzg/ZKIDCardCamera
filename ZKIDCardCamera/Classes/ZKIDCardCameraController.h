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

/// 获取身份证照片，当图片大小超过限制，则无效，会在imageNeedLimit返回
/// - Parameters:
///   - image: 图片
///   - UIViewController: 当前控制器
///   - isFront: 是否是正面
- (void)cameraDidFinishShootWithCameraImage:(UIImage *)image viewController:(UIViewController *)UIViewController isFront:(BOOL)isFront;

/// 获取身份证照片，当图片大小超过限制生效，考虑UI交互，ZKIDTools仅提供方法
/// - Parameters:
///   - image: 图片
///   - UIViewController: 当前控制器
///   - isFront: 是否是正面
- (void)imageNeedLimit:(UIImage *)image viewController:(UIViewController *)UIViewController isFront:(BOOL)isFront;

@end

@interface ZKIDCardCameraController : UIViewController

@property (nonatomic, weak) id<ZKIDCardCameraControllerDelegate> delegate;

- (instancetype)initWithType:(ZKIDCardType)type;

/// 限制文件大小（单位：字节），默认0，代表不限制
@property (nonatomic, assign) NSInteger limitSize;

@end

NS_ASSUME_NONNULL_END
