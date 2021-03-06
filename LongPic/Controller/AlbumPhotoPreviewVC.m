//
//  AlbumPhotoPreviewVC.m
//  eCamera
//
//  Created by shiguang on 2018/3/29.
//  Copyright © 2018年 coder. All rights reserved.
//

#import "AlbumPhotoPreviewVC.h"
#import "UIView+PBExtend.h"
#import "AlbumItemModel.h"
#define WWidth [UIScreen mainScreen].bounds.size.width
#define WHeight [UIScreen mainScreen].bounds.size.height
@interface AlbumPhotoPreviewVC ()<UIScrollViewDelegate>{
    CGFloat _zoomScale;
    CGFloat toolBarBottom;
}

@property (nonatomic,strong) PHCachingImageManager *imageManager;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMarginC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarHeightC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollBottom;

/** 是否有图片数据 */
@property (nonatomic,assign) BOOL hasImage;
/** 单击 */
@property (nonatomic,strong) UITapGestureRecognizer *tap_single_viewGesture;

/** 双击 */
@property (nonatomic,strong) UITapGestureRecognizer *tap_double_imageViewGesture;

/** 双击放大 */
@property (nonatomic,assign) BOOL isDoubleClickZoom;
/** 单击 */
@property (nonatomic,copy) void (^ItemViewSingleTapBlock)();
@property (nonatomic, assign) BOOL hiddenBar;
@property (nonatomic, copy) NSString * imgUrl;
@end

@implementation AlbumPhotoPreviewVC
- (PHCachingImageManager *)imageManager{
    if (_imageManager == nil) {
        _imageManager = [PHCachingImageManager new];
    }
    return _imageManager;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}
- (BOOL)prefersStatusBarHidden
{
    return _hiddenBar;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bottomMarginC.constant = toolBarBottom;
   
    self.automaticallyAdjustsScrollViewInsets = NO;
    //数据准备
    [self dataPrepare];
    self.scrollView.bouncesZoom = YES;
    //添加手势
    [self.view addGestureRecognizer:self.tap_single_viewGesture];
    
    [self.view addGestureRecognizer:self.tap_double_imageViewGesture];
    
}
- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)shareClick:(id)sender {}

/*
 *  数据准备
 */
-(void)dataPrepare{
   
    PHAsset *asset = self.model.asset;
    
    [self.imageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        self.photoImageView.image = result;
    
        
        //标记
        self.hasImage = YES;
        self.photoImageView.frame = self.photoImageView.calF;
        self.scrollView.contentSize = self.photoImageView.frame.size;
    }];


}

-(PhotoImageView *)photoImageView{
    
    if(_photoImageView == nil){
        
        _photoImageView = [[PhotoImageView alloc] init];
        
        _photoImageView.userInteractionEnabled = YES;
        
        [self.scrollView addSubview:_photoImageView];
    }
    
    return _photoImageView;
}

/*
 *  单击
 */
-(void)tap_single_viewTap:(UITapGestureRecognizer *)tap{
    [self tap_view];
}

-(void)tap_view{
    
    [self handleBarView];
}

/*
 *  双击
 */
-(void)tap_double_imageViewTap:(UITapGestureRecognizer *)tap{
    
    if(!self.hasImage) return;
    
    //标记
    self.isDoubleClickZoom = YES;
    
    CGFloat zoomScale = self.scrollView.zoomScale;
    
    if(zoomScale<=1.0f){
        
        CGRect imgRect = self.photoImageView.calF;
        CGFloat zoomScale = [UIScreen mainScreen].bounds.size.width / imgRect.size.width;
        [self.scrollView setZoomScale:zoomScale animated:YES];
        
    }else{
        [self.scrollView setZoomScale:1.0f animated:YES];
    }
}

/*
 *  处理barView
 */
-(void)handleBarView{
    
    CGFloat nav_h = _navBarView.frame.size.height;
    
    BOOL show = _navBarView.tag == 0;
    _navBarView.tag = show?1:0;
    
    if (show) {
        _hiddenBar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }else{
        _hiddenBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    _topBarHeightC.constant = show?-nav_h:0;

    _bottomBar.hidden = _hiddenBar;
    _bottomMarginC.constant = !_hiddenBar ? toolBarBottom:0;
    
    [UIView animateWithDuration:.25f animations:^{
        
        [_navBarView setNeedsLayout];
        [_navBarView layoutIfNeeded];
    }];
    
}

/*
 *  代理方法区
 */
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{

    return self.photoImageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if(scrollView.zoomScale <=1) scrollView.zoomScale = 1.0f;
    
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;

    [self.photoImageView setCenter:CGPointMake(xcenter, ycenter)];
}

/*
 *  重置
 */
-(void)reset{
    
    //缩放比例
    self.scrollView.zoomScale = 1.0f;
    
    //默认无图
    self.hasImage = NO;
    self.photoImageView.frame=CGRectZero;
}

- (CGRect)itemImageViewFrame{
    
    return self.photoImageView.frame;
}

-(CGFloat)zoomScale{
    return self.scrollView.zoomScale;
}

-(void)setZoomScale:(CGFloat)zoomScale{
    _zoomScale = zoomScale;
    [self.scrollView setZoomScale:zoomScale animated:YES];
}

-(UITapGestureRecognizer *)tap_single_viewGesture{
    
    if(_tap_single_viewGesture == nil){
        
        _tap_single_viewGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_single_viewTap:)];
        [_tap_single_viewGesture requireGestureRecognizerToFail:self.tap_double_imageViewGesture];
    }
    
    return _tap_single_viewGesture;
}

-(UITapGestureRecognizer *)tap_double_imageViewGesture{
    
    if(_tap_double_imageViewGesture == nil){
        
        _tap_double_imageViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_double_imageViewTap:)];
        _tap_double_imageViewGesture.numberOfTapsRequired = 2;
    }
    
    return _tap_double_imageViewGesture;
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end
