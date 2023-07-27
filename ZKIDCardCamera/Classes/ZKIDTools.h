//
//  ZKIDTools.h
//  ZKIDCardCamera
//
//  Created by apple on 2023/7/27.
//

#import <Foundation/Foundation.h>

typedef void(^ImgBlock) (UIImage *resultImage);
typedef void(^DataBlock)(NSData  *resultData);

@interface ZKIDTools : NSObject

/// 得到旋转后的图片
/// - Parameters:
///   - image: 原图
///   - angle: 角度（0~360）
+ (UIImage *)getRotationImageWithImage:(UIImage *)image
                                 angle:(CGFloat)angle;

/// 前台压缩（可能比较慢，造成当前进程卡住） 压缩得到 目标大小的 图片Data
/// - Parameters:
///   - oldImage: 原图
///   - showSize: 将要显示的分辨率
///   - fileSize: 文件大小限制
+ (NSData *)compressToDataWithImage:(UIImage *)oldImage
                          showSize:(CGSize)showSize
                           fileSize:(NSInteger)fileSize;

/// 压缩得到 目标大小的 UIImage
/// - Parameters:
///   - oldImage: 原图
///   - showSize: 将要显示的分辨率
///   - fileSize: 文件大小限制
+ (UIImage *)compressToImageWithImage:(UIImage *)oldImage
                            showSize:(CGSize)showSize
                             fileSize:(NSInteger)fileSize;

/// 只压不缩--返回UIImage  优点：不影响分辨率，不太影响清晰度 缺点：存在最小限制，可能压不到目标大小
/// - Parameters:
///   - oldImage: 原图
///   - fileSize: 文件大小限制
+ (UIImage *)onlyCompressToImageWithImage:(UIImage *)oldImage
                                 fileSize:(NSInteger)fileSize;

/// 只压不缩--按NSData大小压缩，返回NSData 优点：不影响分辨率，不太影响清晰度 缺点：存在最小限制，可能压不到目标大小
/// - Parameters:
///   - oldImage: 原图
///   - fileSize: 文件大小限制
+ (NSData *)onlyCompressToDataWithImage:(UIImage *)oldImage
                               fileSize:(NSInteger)fileSize;

/// 只缩不压
/// - Parameters:
///   - oldImage: 原图
///   - size: 文件大小限制
///   - scale: 若Scale为YES，则原图会根据Size进行拉伸-会变形若Scale为NO，则原图会根据Size进行填充-不会变形。
+ (UIImage *)resizeImageWithImage:(UIImage *)oldImage
                          andSize:(CGSize)size
                            scale:(BOOL)scale;

@end
