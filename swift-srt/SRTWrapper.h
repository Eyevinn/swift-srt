//
//  SRTWrapper.h
//  swift-srt
//
//  Created by Jesper Lundqvist on 2021-08-17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

@interface SRTWrapper : NSObject

+ (SRTWrapper*) sharedInstance;

- (int) createSocketAsSender: (bool)sender;
- (int) bindSocket: (int)socket forAddress: (NSString*)address atPort: (int)port;
- (int) listenOnSocket: (int)socket withBacklog: (int)backlog;
- (int) connectToSocket: (int)socket withHost: (NSString*)host atPort: (int)port;
- (int) acceptSocket: (int)socket;
- (int) closeSocket: (int)socket;
- (NSData*) readFromSocket: (int)socket withChunkSize: (int)chunkSize;
- (int) writeToSocket: (int)socket withChunk: (NSData*)chunk;
- (int) setOption: (int)option toValue: (int)value forSocket: (int)socket;
- (NSValue*) getOption: (int)option fromSocket: (int)socket;
- (int) getStateFromSocket: (int)socket;
- (int) epollCreate;
- (int) epollAddUsockFor: (int)epid withSocket: (int)socket events: (int)events;
- (NSArray*) epollUWaitFor: (int) epid withTimeOutInMs: (int) msTimeOut;
- (NSDictionary*) statsForSocket: (int)socket shouldClear: (bool)clear;

@end

NS_ASSUME_NONNULL_END
