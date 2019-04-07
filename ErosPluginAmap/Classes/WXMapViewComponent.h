//
//  WXMapViewComponent.h
//  WeexDemo
//
//  Created by yangshengtao on 2017/1/20.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import <WeexSDK/WeexSDK.h>
#import "WXMapViewMarkerComponent.h"
#import "WXMapRenderer.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface WXMapViewComponent : WXComponent<MAMapViewDelegate>

- (NSDictionary *)getUserLocation;

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIButton *gpsButton;
@property (nonatomic, assign) BOOL fixed;


#pragma - Marker
- (void)addMarker:(WXMapViewMarkerComponent *)marker;
- (void)addMarker:(WXMapViewMarkerComponent *)marker fixed:(BOOL)fixed;

- (void)updateTitleMarker:(WXMapViewMarkerComponent *)marker;

- (void)updateSubTitleMarker:(WXMapViewMarkerComponent *)marker;

- (void)updateIconMarker:(WXMapViewMarkerComponent *)marker;

- (void)updateLocationMarker:(WXMapViewMarkerComponent *)marker;

- (void)removeMarker:(WXComponent *)marker;

#pragma - Overlay
- (void)addOverlay:(id)overlay;

- (void)removeOverlay:(id)overlay;

- (void)updateOverlayAttributes:(id)overlay;
@end



