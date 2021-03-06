//
//  BlePalletManager.m
//  PalletBluetoothDemo
//
//  Created by issuser on 2018/8/7.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BlePalletManager.h"
#import "MJExtension.h"
#import "BleDataUtil.h"

#define kMaxResentCount  3
#define kTimeInterval 3.0f

@interface BlePalletManager() {
    NSString *_iccid;
}


@property (nonatomic, strong) BLEManager *bleMgr;
@property (nonatomic, strong) BLEPeripheral *peripheral;     //外围设备
@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, strong) NSTimer *timer;       //重发
@property (nonatomic, strong) NSData *curSendData;  //当前重发的数据
@property (nonatomic, assign) NSInteger resentCount;     //重发次数

@end

@implementation BlePalletManager

- (instancetype)initWithDelegate:delegate {
    if (self = [super init]) {
        self.curSendData = nil;
        self.delegate = delegate;
        self.bleMgr = [BLEManager sharedInstance];
        self.bleMgr.connectTimeout = 20;
        self.bleMgr.sendDataTimeout = 10;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectedNotifaction:) name:BLENotificationDisconnected object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchWithTag:(NSInteger)tag params:(NSDictionary *)params {
    _tag = tag;
    _iccid = params[@"ICCID"];
    self.receiveModel = [[BleReceiveModel alloc] init];
    self.sendModel = [[BleSendModel alloc] initWithDic:params];
    [self wakeupBle];
}


- (void)connectBleDevice:(BLEPeripheral *)peripheral tag:(NSInteger) tag{
    self.tag = tag;
    self.peripheral = peripheral;
    if (self.peripheral == nil) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.bleMgr connectPeripheral:self.peripheral completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"Failed to connect BLE peripheral.:%@",error.description);
            if (self.delegate && [self.delegate respondsToSelector:@selector(blePalletManager:tag: didWithError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate blePalletManager:self tag:self.tag didWithError:@"蓝牙连接失败"];
                });
                
            }
            
            return;
        }
        
        
        [self subscribeNotification];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(blePalletManager:tag:didConnectComplete:error:)]) {
            [weakSelf.delegate blePalletManager:self tag:self.tag didConnectComplete:data error:error];
        }
    }];
}

- (void)disconnect {
    [self.bleMgr disconnectPeripheral:self.peripheral completion:^(NSNumber * _Nullable success, NSError * _Nullable error) {
    }];
}


/**
 订阅通知
 */
- (void)subscribeNotification {
    
    [self.bleMgr subscribeNotificationForPeripheral:self.peripheral characteristicUUID:kNotificationUUID resultCallback:^(NSData *data, NSError *error) {
        NSLog(@"<<<<<<<<:%@<<<:%@",[BleDataUtil data2Hex:data],@(data.length));
        
        //返回空数据不解析
        if (data.length <= 0) {
            return;
        }
        
        int8_t *bytes = malloc(data.length);
        [data getBytes:bytes length:data.length];
        
        //唤醒针(第1个字节是字母D表是是唤醒贞)
        if (bytes[0] == 0x44) {
            [self handleWakeupBleResult:data];
            return;
        }
        
        //bytes[2] 应答包（第3个字节的第7位是1表示应答包）
        if ((bytes[2] - self.sendModel.pkgCount) == 0x40) {
            [self anwserBleData:data];
            return;
        }
        
        //接受数据包（第3个字节的包的总数<64 表示是数据接收包）
        if (bytes[2] < 0x40) {
            [self receiveBleData:data];
        }
        
    }];
}


/**
 蓝牙连接断开通知
 @param sender sender description
 */
- (void)disconnectedNotifaction:(id)sender {
    NSLog(@">>>>>>>>>>蓝牙连接已经断开");
    
}

#pragma mark -
#pragma mark 蓝牙步骤 method

/**
 唤醒设备
 */
- (void)wakeupBle {
    NSData *sendData = [kWakeUpCmd dataUsingEncoding:NSUTF8StringEncoding];
    [self.bleMgr sendData:sendData toPeripheral:self.peripheral characteristicUUID:kWriteUUID completion:^(id data, NSError *error) {}];
}



/**
 睡眠指令
 {
    "CMD":2,
    "ICCID":"898607B3221770072988",
    "PowerOff":1
 }
 @param iccid ICCID
 */
- (void)sleepBle:(NSString *)iccid {

    NSDictionary *sleepDic = @{@"CMD":@(2),@"ICCID":iccid,@"PowerOff":@(1)};
    self.sendModel = [[BleSendModel alloc] initWithDic:sleepDic];
    self.receiveModel = [[BleReceiveModel alloc] init];
    NSData *data = [self.sendModel dataForPkgIndex:1];//发送第一包
    [self.bleMgr sendData:data toPeripheral:self.peripheral characteristicUUID:kWriteUUID completion:^(id data, NSError *error) {}];
}


/**
 处理唤醒蓝牙结果
 @param data data description
 */
- (void)handleWakeupBleResult:(NSData *)data {
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@">>>>>>>>:唤醒结果(%@)",result);
    if ([result isEqualToString:kWakeNOk]) {
        return;
    }
    
    
    //唤醒后要等6s开发发包
    [self.sendModel.hasSendIndexSet removeAllIndexes];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSData *data = [self.sendModel dataForPkgIndex:1];//发送第一包
        if (data == nil) {
            return;
        }
        NSLog(@"分包发送(1)::>>%@",[BleDataUtil data2Hex:data]);
        [self.bleMgr sendData:data toPeripheral:self.peripheral characteristicUUID:kWriteUUID completion:^(NSNumber * _Nullable success, NSError * _Nullable error) {
        }];
        
        
        //timer创建重发机制
        [self openRewrite:data];
    });
}


/**
 分包应答发送（蓝牙回复还有多少包没有发送，处理未发送的包）
 其中每发送一次包，蓝牙收到包后，则回复你一个包，然后在继续发送下一个包
 @param data data description
 */
- (void)anwserBleData:(NSData *)data {
    //获取未发送的包
    NSInteger len = data.length - 4;
    if (len <= 0) {
        //清空回包信息（准备接收）
        [self.receiveModel.dataArr removeAllObjects];
        return;
    }
    
   
    int8_t *unsentPkgByte = malloc(len);
    [data getBytes:unsentPkgByte range: NSMakeRange(4, len)];
    NSInteger pkgIndex = unsentPkgByte[0];
    NSData *sendData = [self.sendModel dataForPkgIndex:pkgIndex];
    if (sendData == nil) {
        return;
    }
    
    //取消重发机制
    [self cancelRewrite];
    NSLog(@"分包发送(%ld)::>>%@",pkgIndex,[BleDataUtil data2Hex:sendData]);
    [self.bleMgr sendData:sendData toPeripheral:self.peripheral characteristicUUID:kWriteUUID completion:^(NSNumber * _Nullable success, NSError * _Nullable error) {
    }];
    
    [self openRewrite:sendData];
}


/**
 接受蓝牙返回的最后结果
 请求参数发完后，蓝牙自动回复第一包结果数据
 @param data data description
 */
- (void)receiveBleData:(NSData *)data {
    
    NSMutableData *answerData = [self.receiveModel appendPartData:data];
    if(answerData == nil) {
        return;
    };

    [self cancelRewrite]; //取消重发机制
    NSLog(@"回包发送::>>%@",[BleDataUtil data2Hex:answerData]);
    [self.bleMgr sendData:answerData toPeripheral:self.peripheral characteristicUUID:kWriteUUID completion:^(id data, NSError *error) {
    }];
    
    //打开重发
    [self openRewrite:answerData];
    //数据发送完成，可以获取结果了
    if (answerData.length == 4) {
        [self cancelRewrite];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(blePalletManager:tag:didResult:)]) {
            NSString *result = self.receiveModel.result;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate blePalletManager:self tag: self.tag didResult:result];
            });
            
        }
    }
}


#pragma mark -
#pragma mark timer重发机制 method

//开启重发
- (void)openRewrite:(NSData *)data {
    self.curSendData = data;
    self.resentCount = 0;
    
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kTimeInterval]];
}

//取消重发
- (void)cancelRewrite {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (NSTimer *)timer {
    if (_timer == nil) {
        NSLog(@">>>>>>>create timer");
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    
    return _timer;
}

- (void)timerFire:(NSTimer *)timer {
    self.resentCount = self.resentCount + 1;
    if (self.resentCount > kMaxResentCount) {
        [self cancelRewrite];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(blePalletManager:tag: didWithError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate blePalletManager:self tag:self.tag didWithError:@"获取数据失败."];
            });
            
        }
        
        return;
    }
    
    NSLog(@">>>>>>重发(%@):%@",@(self.resentCount),[BleDataUtil data2Hex:self.curSendData]);
    if (self.curSendData == nil) {
        return;
    }
    [self.bleMgr sendData:self.curSendData toPeripheral:self.peripheral characteristicUUID:kWriteUUID completion:^(NSNumber * _Nullable success, NSError * _Nullable error) {
    }];
}

@end
