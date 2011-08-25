//
//  ImageCropView.m
//  test31
//
//  Created by Tsuneo Yoshioka on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCropView.h"

@implementation ImageCropView
@synthesize image;
@synthesize cropRect;

- (CGRect)rectAdd:(CGRect)rect width:(float)width
{
    CGRect rect2;
    int sizewidthsign = ((rect.size.width >= 0) ? 1 : -1);
    int sizeheightsign = ((rect.size.height >=0) ? 1 : -1);
    rect2.origin.x = rect.origin.x - width * sizewidthsign;
    rect2.origin.y = rect.origin.y - width * sizeheightsign;
    rect2.size.width = rect.size.width + width*2 * sizewidthsign;
    rect2.size.height = rect.size.height + width*2  * sizeheightsign;
    return rect2;
}
- (CGRect)imageRect
{
    CGRect imageRect = [self rectAdd:self.bounds width:-marginwidth];
    NSLog(@"bounds=%f, %f, %f, %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    return imageRect;
}
- (void)reset
{
    cropRect = CGRectMake(0,0,1.0,1.0);
    NSLog(@"bounds=%f, %f, %f, %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
}
- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        marginwidth = 10;
        [self reset];
    }
    return self;
}
-(BOOL)canBecomeFirstResponder
{
    return YES;
}
- (UIImage*)imageByCropping
{
    CGRect rect;
    
    rect.origin.x = image.size.width * cropRect.origin.x;
    rect.origin.y = image.size.height * cropRect.origin.y;
    rect.size.width = image.size.width * cropRect.size.width;
    rect.size.height = image.size.height * cropRect.size.height;

    if(rect.origin.x + rect.size.width > image.size.width){rect.size.width = image.size.width;}
    if(rect.origin.y + rect.size.height > image.size.height){rect.size.height = image.size.height;}
    if(rect.origin.x < 0){rect.size.width +=rect.origin.x; rect.origin.x = 0;}
    if(rect.origin.y < 0){rect.size.height +=rect.origin.y; rect.origin.y = 0;}
    
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGImageRef imageRef = CGImageCreateWithImageInRect(image2.CGImage, rect);

    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    return cropped;
}
-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0);
    CGContextFillRect(context, self.bounds);
    NSLog(@"bounds=%f, %f, %f, %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    //[self.image drawInRect:imageRect];
    
    CGRect imageRect = [self imageRect];
    
    CGRect cropViewRect;
    cropViewRect.origin.x = imageRect.origin.x + imageRect.size.width * cropRect.origin.x;
    cropViewRect.origin.y = imageRect.origin.y + imageRect.size.height * cropRect.origin.y;
    cropViewRect.size.width = imageRect.size.width * cropRect.size.width;
    cropViewRect.size.height = imageRect.size.height * cropRect.size.height;

    // CGContextDrawImage(context, imageRect, self.image.CGImage);
    int cropwidth = 10;
    CGRect rect2 = [self rectAdd:cropViewRect width:-cropwidth/2];
    
    CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 0.3);
    CGContextStrokeRectWithWidth(context, rect2, cropwidth);
    
    CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1);
    CGContextStrokeRect(context, cropViewRect);

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchBeganPoint = [touch locationInView:self];
    [self touchesMoved:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    CGRect imageRect = [self imageRect];
    cropRect.origin.x = (touchBeganPoint.x - imageRect.origin.x)/imageRect.size.width;
    cropRect.origin.y = (touchBeganPoint.y - imageRect.origin.y)/imageRect.size.height;
    cropRect.size.width = (p.x - touchBeganPoint.x)/imageRect.size.width;
    cropRect.size.height = (p.y - touchBeganPoint.y)/imageRect.size.height;
    NSLog(@"1:cropRect=(%f, %f, %f, %f)", cropRect.origin.x, cropRect.origin.y, cropRect.size.width, cropRect.size.height);
    [self setNeedsDisplay];
}
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(self.bounds.origin.x <= point.x && self.bounds.origin.y <= point.y && point.x < self.bounds.origin.x + self.bounds.size.width && point.y < self.bounds.origin.y + self.bounds.size.height){
        return self;
    }
    
    return [super hitTest:point withEvent:event];
}

@end
