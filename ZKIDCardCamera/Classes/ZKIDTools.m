//
//  ZKIDTools.m
//  ZKIDCardCamera
//
//  Created by apple on 2023/7/27.
//

/*
 引用：https://github.com/976431yang/YQImageTool
 引用：https://github.com/976431yang/YQImageCompressor/
 */

#import "ZKIDTools.h"

@implementation ZKIDTools

#pragma mark - 旋转
+ (UIImage *)getRotationImageWithImage:(UIImage *)image
                                 angle:(CGFloat)angle {
    
    UIView *rootBackView = [[UIView alloc] initWithFrame:CGRectMake(0,0, image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(angle * M_PI / 180);
    rootBackView.transform = t;
    CGSize rotatedSize = rootBackView.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, image.scale);
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(theContext, rotatedSize.width / 2, rotatedSize.height / 2);
    CGContextRotateCTM(theContext, angle * M_PI / 180);
    CGContextScaleCTM(theContext, 1.0, -1.0);
    CGContextDrawImage(theContext, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - 前台压缩（可能比较慢，造成当前进程卡住） 压缩得到 目标大小的 图片Data
+ (NSData *)compressToDataWithImage:(UIImage *)oldImage
                          showSize:(CGSize)showSize
                          fileSize:(NSInteger)fileSize {
    UIImage *oldIMG = oldImage;
    UIImage *thumIMG = [self resizeImageWithImage:oldIMG andSize:showSize scale:NO];
    NSData  *outIMGData = [self onlyCompressToDataWithImage:thumIMG fileSize:(fileSize * 1024)];
    
    CGSize scalesize = showSize;
    
    //如果压缩后还是无法达到文件大小，则降低分辨率，继续压缩
    while (outIMGData.length > (fileSize * 1024)) {
        scalesize = CGSizeMake(scalesize.width * 0.8, scalesize.height * 0.8);
        thumIMG = [self resizeImageWithImage:oldIMG andSize:scalesize scale:NO];
        outIMGData = [self onlyCompressToDataWithImage:thumIMG fileSize:(fileSize * 1024)];
    }
    return outIMGData;
}

#pragma mark - 压缩得到 目标大小的 UIImage
+ (UIImage *)compressToImageWithImage:(UIImage *)oldImage
                            showSize:(CGSize)showSize
                            fileSize:(NSInteger)fileSize {
    NSLog(@"正在压缩图片...");
    UIImage *oldIMG = oldImage;
    UIImage *thumIMG = [self resizeImageWithImage:oldIMG andSize:showSize scale:NO];
    UIImage *outIMG = [self onlyCompressToImageWithImage:thumIMG fileSize:(fileSize * 1024)];
    NSData *newimageData = UIImageJPEGRepresentation(outIMG, 1);
    CGSize scalesize = showSize;
    
    //如果压缩后还是无法达到文件大小，则降低分辨率，继续压缩
    while ([newimageData length] > (fileSize * 1024)) {
        
        scalesize = CGSizeMake(scalesize.width*0.8, scalesize.height*0.8);
        thumIMG = [self resizeImageWithImage:outIMG andSize:scalesize scale:NO];
        outIMG = [self onlyCompressToImageWithImage:thumIMG fileSize:(fileSize * 1024)];
        newimageData = UIImageJPEGRepresentation(outIMG,1);
    }
    return outIMG;
}

#pragma mark --------后台压缩（异步进行，不会卡住前台进程） 后台压缩得到 目标大小的 图片Data
+ (void)compressToDataAtBackgroundWithImage:(UIImage *)oldImage
                                   showSize:(CGSize)showSize
                                   fileSize:(NSInteger)fileSize
                                      block:(ZKIDDataBlock)DataBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *newIMGData = [self compressToDataWithImage:oldImage showSize:showSize fileSize:fileSize];
        DataBlock(newIMGData);
    });
}



#pragma mark - 后台压缩得到 目标大小的 UIImage
+ (void)compressToImageAtBackgroundWithImage:(UIImage *)oldImage
                                   showSize:(CGSize)showSize
                                   fileSize:(NSInteger)fileSize
                                      block:(ZKIDImgBlock)ImgBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *newIMG = [self compressToImageWithImage:oldImage showSize:showSize fileSize:fileSize];
        ImgBlock(newIMG);
    });
}


#pragma mark - 细化调用方法
// ------只压不缩--返回UIImage
// 优点：不影响分辨率，不太影响清晰度
// 缺点：存在最小限制，可能压不到目标大小
+ (UIImage *)onlyCompressToImageWithImage:(UIImage *)oldImage
                                 fileSize:(NSInteger)fileSize {
    
    CGFloat compression = 0.9f;
    CGFloat minCompression = 0.01f;
    NSData *imageData = UIImageJPEGRepresentation(oldImage, compression);
    
    //每次减少的比例
    float scale = 0.1;
    
    //新UIImage的Data
    NSData * newimageData = UIImageJPEGRepresentation(oldImage,1);
    
    //循环条件：没到最小压缩比例，且没压缩到目标大小
    while ((compression > minCompression) && (newimageData.length > fileSize)) {
        imageData = UIImageJPEGRepresentation(oldImage, compression);
        UIImage *compressedImage = [UIImage imageWithData:imageData];
        newimageData= UIImageJPEGRepresentation(compressedImage,1);
        compression -= scale;
    }
    UIImage *compressedImage = [UIImage imageWithData:newimageData];
    return compressedImage;
}

#pragma mark - 只压不缩 -- 按NSData大小压缩，返回NSData
+ (NSData *)onlyCompressToDataWithImage:(UIImage *)oldImage
                               fileSize:(NSInteger)fileSize {
    CGFloat compression = 1.0f;
    CGFloat minCompression = 0.001f;
    NSData *imageData = UIImageJPEGRepresentation(oldImage, compression);
    //每次减少的比例
    float scale = 0.1;
    //循环条件：没到最小压缩比例，且没压缩到目标大小
    while ((compression > minCompression) && (imageData.length > fileSize)) {
        compression -= scale;
        imageData = UIImageJPEGRepresentation(oldImage, compression);
    }
    return imageData;
}

#pragma mark - 只缩不压 若Scale为YES，则原图会根据Size进行拉伸-会变形若Scale为NO，则原图会根据Size进行填充-不会变形。
+ (UIImage *)resizeImageWithImage:(UIImage *)oldImage
                          andSize:(CGSize)size
                            scale:(BOOL)scale {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    if (!scale) {
        CGFloat bili_imageWH = oldImage.size.width / oldImage.size.height;
        CGFloat bili_SizeWH  = size.width / size.height;
        if (bili_imageWH > bili_SizeWH) {
            
            CGFloat bili_SizeH_imageH = size.height / oldImage.size.height;
            CGFloat height = oldImage.size.height * bili_SizeH_imageH;
            CGFloat width = height * bili_imageWH;
            CGFloat x = -(width - size.width) / 2;
            CGFloat y = 0;
            rect = CGRectMake(x, y, width, height);
            
        }else{
            
            CGFloat bili_SizeW_imageW = size.width / oldImage.size.width;
            CGFloat width = oldImage.size.width * bili_SizeW_imageW;
            CGFloat height = width / bili_imageWH;
            CGFloat x = 0;
            CGFloat y = -(height - size.height) / 2;
            rect = CGRectMake(x, y, width, height);
        }
    }
    
    [[UIColor clearColor] set];
    UIRectFill(rect);
    [oldImage drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
