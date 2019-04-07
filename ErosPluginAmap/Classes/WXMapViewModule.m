//
//  WXMapViewModule.m
//  Pods
//
//  Created by yangshengtao on 17/1/23.
//
//

#import "WXMapViewModule.h"
#import "WXMapViewComponent.h"
#import "WXConvert+AMapKit.h"
#import <WeexPluginLoader/WeexPluginLoader.h>
#import <AMapSearchKit/AMapSearchKit.h>

WX_PlUGIN_EXPORT_MODULE(amap, WXMapViewModule)

WX_PlUGIN_EXPORT_COMPONENT(weex-amap, WXMapViewComponent)
WX_PlUGIN_EXPORT_COMPONENT(weex-amap-marker, WXMapViewMarkerComponent)
WX_PlUGIN_EXPORT_COMPONENT(weex-amap-polyline, WXMapPolylineComponent)
WX_PlUGIN_EXPORT_COMPONENT(weex-amap-polygon, WXMapPolygonComponent)
WX_PlUGIN_EXPORT_COMPONENT(weex-amap-circle, WXMapCircleComponent)
WX_PlUGIN_EXPORT_COMPONENT(weex-amap-info-window, WXMapInfoWindowComponent)

@interface WXMapViewModule()<AMapSearchDelegate>
    
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) NSMutableArray *searchPoiArray;
@property (nonatomic) WXModuleCallback callback;
    
@end

@implementation WXMapViewModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(initAmap:))
WX_EXPORT_METHOD(@selector(getUserLocation:callback:))
WX_EXPORT_METHOD(@selector(getLineDistance:marker:callback:))
WX_EXPORT_METHOD_SYNC(@selector(polygonContainsMarker:ref:callback:))

WX_EXPORT_METHOD(@selector(geoAddress:callback:))
    
- (void)initAmap:(NSString *)appkey
{
    [[AMapServices sharedServices] setApiKey:appkey];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}
    
- (void)geoAddress: (NSString *) searchLatlonPoint callback:(WXModuleCallback)callback {
    
    if (searchLatlonPoint) {
        @try {
            self.callback = nil;
            self.callback = callback;
            //解析JSON
            NSDictionary *dic = [WXMapViewModule dictionaryWithJsonString:searchLatlonPoint];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[dic objectForKey:@"latitude"] floatValue], [[dic objectForKey:@"longitude"] floatValue]);
            [self searchReGeocodeWithCoordinate:coordinate];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    
}

- (void)getUserLocation:(NSString *)elemRef callback:(WXModuleCallback)callback
{
    [self performBlockWithRef:elemRef block:^(WXComponent *component) {
        callback([(WXMapViewComponent *)component getUserLocation] ? : nil);
    }];
}

- (void)getLineDistance:(NSArray *)marker marker:(NSArray *)anotherMarker callback:(WXModuleCallback)callback
{
    CLLocationCoordinate2D location1 = [WXConvert CLLocationCoordinate2D:marker];
    CLLocationCoordinate2D location2 = [WXConvert CLLocationCoordinate2D:anotherMarker];
    MAMapPoint p1 = MAMapPointForCoordinate(location1);
    MAMapPoint p2 = MAMapPointForCoordinate(location2);
    CLLocationDistance distance =  MAMetersBetweenMapPoints(p1, p2);
    NSDictionary *userDic;
    if (distance > 0) {
        userDic = @{@"result":@"success",@"data":@{@"distance":[NSNumber numberWithDouble:distance]}};
    }else {
        userDic = @{@"resuldt":@"false",@"data":@""};
    }
    callback(userDic);
}

- (void)polygonContainsMarker:(NSArray *)position ref:(NSString *)elemRef callback:(WXModuleCallback)callback
{
    [self performBlockWithRef:elemRef block:^(WXComponent *WXMapRenderer) {
        CLLocationCoordinate2D loc1 = [WXConvert CLLocationCoordinate2D:position];
        MAMapPoint p1 = MAMapPointForCoordinate(loc1);
        NSDictionary *userDic;

        if (![WXMapRenderer.shape isKindOfClass:[MAMultiPoint class]]) {
            userDic = @{@"result":@"false",@"data":[NSNumber numberWithBool:NO]};
            return;
        }
        MAMapPoint *points = ((MAMultiPoint *)WXMapRenderer.shape).points;
        NSUInteger pointCount = ((MAMultiPoint *)WXMapRenderer.shape).pointCount;
        
        if(MAPolygonContainsPoint(p1, points, pointCount)) {
             userDic = @{@"result":@"success",@"data":[NSNumber numberWithBool:YES]};
        } else {
            userDic = @{@"result":@"false",@"data":[NSNumber numberWithBool:NO]};
        }
        callback(userDic);
    }];
}

- (void)performBlockWithRef:(NSString *)elemRef block:(void (^)(WXComponent *))block {
    if (!elemRef) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    WXPerformBlockOnComponentThread(^{
        WXComponent *component = (WXComponent *)[weakSelf.weexInstance componentForRef:elemRef];
        if (!component) {
            return;
        }
        
        [weakSelf performSelectorOnMainThread:@selector(doBlock:) withObject:^() {
            block(component);
        } waitUntilDone:NO];
    });
}

- (void)doBlock:(void (^)())block {
    block();
}
    
#pragma mark - AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [self.searchPoiArray removeAllObjects];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        [self.searchPoiArray addObject:obj];
    }];
}
    
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setObject:response.regeocode.addressComponent.country forKey:@"country"];
        [info setObject:response.regeocode.addressComponent.city forKey:@"city"];
        [info setObject:response.regeocode.addressComponent.district forKey:@"district"];
        [info setObject:response.regeocode.formattedAddress forKey:@"address"];
        [info setObject:response.regeocode.addressComponent.adcode forKey:@"adCode"];
        [info setObject:response.regeocode.addressComponent.towncode forKey:@"towncode"];
        
        if (self.callback) {
            self.callback(info);
        }
        
        
    }
}
    
#pragma mark - Utility
    
    /* 根据中心点坐标来搜周边的POI. */
- (void)searchPoiWithCenterCoordinate:(CLLocationCoordinate2D )coord
{
    AMapPOIAroundSearchRequest*request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location = [AMapGeoPoint locationWithLatitude:coord.latitude  longitude:coord.longitude];
    request.radius   = 1000;
    request.sortrule = 0;
    
    [self.search AMapPOIAroundSearch:request];
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    [self.search AMapReGoecodeSearch:regeo];
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
+(NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}
@end
