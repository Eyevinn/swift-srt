//
//  SRTWrapper.m
//  swift-srt
//
//  Created by Jesper Lundqvist on 2021-08-17.
//

#import "SRTWrapper.h"

#import <srt/srt.h>

@implementation SRTWrapper

+ (SRTWrapper*)sharedInstance {
    static SRTWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SRTWrapper alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        srt_startup();
    }
    return self;
}

- (void)dealloc
{
    srt_cleanup();
}

- (int)createSocketAsSender:(bool)sender {
    SRTSOCKET socket = srt_create_socket();
    
    if (socket == SRT_ERROR) {
        [NSException raise:@"Error when creating socket" format:@"%s", srt_getlasterror_str()];
    }
    
    if (sender) {
        int yes = 1;
        srt_setsockflag(socket, SRTO_SENDER, &yes, sizeof(yes));
    }
    
    return socket;
}

- (int)bindSocket:(int)socket forAddress:(NSString *)address atPort:(int)port {
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(uint32_t(port));
    int result = inet_pton(AF_INET, address.UTF8String, &addr.sin_addr);
    
    if (result != 1) {
        [NSException raise:@"Error when binding socket" format:@"%s", strerror(errno)];
    }
    
    result = srt_bind(socket, (struct sockaddr *)&addr, sizeof(addr));
    
    if (result == SRT_ERROR) {
        [NSException raise:@"Error when binding socket" format:@"%s", srt_getlasterror_str()];
    }
    
    return result;
}

- (int)listenOnSocket:(int)socket withBacklog:(int)backlog {
    int result = srt_listen(socket, backlog);

    if (result == SRT_ERROR) {
        [NSException raise:@"Error when listening to socket" format:@"%s", srt_getlasterror_str()];
    }
    
    return result;
}

- (int)connectToSocket:(int)socket withHost:(NSString *)host atPort:(int)port {
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(uint32_t(port));
    
    inet_pton(AF_INET, host.UTF8String, &addr.sin_addr);
    
    int result = srt_connect(socket, (struct sockaddr *)&addr, sizeof(addr));
    
    if (result == SRT_ERROR) {
        [NSException raise:@"Error when connecting to socket" format:@"%s", srt_getlasterror_str()];
    }
    
    return result;
}

- (int)acceptSocket:(int)socket {
    sockaddr_in their_addr;
    int addr_size = sizeof(sockaddr_in);
    
    int their_fd = srt_accept(socket, (struct sockaddr *)&their_addr, &addr_size);
    
    if (their_fd == SRT_INVALID_SOCK) {
        srt_close(socket);
        [NSException raise:@"Invalid socket" format:@"%s", srt_getlasterror_str()];
    }
    
    srt_close(socket);
    
    return their_fd;
}

- (int)closeSocket:(int)socket {
    int result = srt_close(socket);
    
    if (result == SRT_ERROR) {
        [NSException raise:@"Error when closing socket" format:@"%s", srt_getlasterror_str()];
    }
    
    return result;
}

- (NSData*)readFromSocket:(int)socket withChunkSize:(int)chunkSize {
    size_t bufferSize = uint32_t(chunkSize);
    uint8_t *buffer = (uint8_t *)malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    int nb = srt_recvmsg(socket, (char *)buffer, (int)bufferSize);
    if (nb == SRT_ERROR) {
        [NSException raise:@"Error when reading from socket" format:@"%s", srt_getlasterror_str()];
    }
    
    NSData* data = [NSData dataWithBytes: buffer length: nb];
    free(buffer);
    
    return data;
}

- (int)writeToSocket:(int)socket withChunk:(NSData *)chunk {
    int result = srt_sendmsg2(socket, (const char *)chunk.bytes, (int)chunk.length, NULL);
    
    if (result == SRT_ERROR) {
        [NSException raise:@"Error when writing to socket" format:@"%s", srt_getlasterror_str()];
    }
    
    return result;
}

- (int)setOption:(int)option toValue:(int)value forSocket:(int)socket {
    int result = srt_setsockflag(socket, (SRT_SOCKOPT)option, &value, sizeof(int));
    
    if (result == SRT_ERROR) {
        [NSException raise:@"Error when setting socket flag" format:@"%s", srt_getlasterror_str()];
    }
    
    return result;
}

- (NSValue *)getOption:(int)option fromSocket:(int)socket {
    // TODO: Different types for different options
    int optValue;
    int optSize = sizeof(optValue);
    srt_getsockflag(socket, (SRT_SOCKOPT)option, (void*)&optValue, &optSize);
    return [NSValue value: &optValue withObjCType: @encode(int)];
}

- (int)getStateFromSocket:(int)socket {
    return srt_getsockstate(socket);
}

- (int)epollCreate {
    int epid = srt_epoll_create();
    
    if (epid < 0) {
        [NSException raise:@"Epoll Error" format:@"%s", srt_getlasterror_str()];
    }
    
    return epid;
}

- (int)epollAddUsockFor:(int)epid withSocket:(int)socket events:(int)events {
    int result = srt_epoll_add_usock(epid, socket, &events);
    
    if (result == SRT_ERROR) {
        [NSException raise:@"Epoll Error" format:@"%s", srt_getlasterror_str()];
    }
    
    return result;
}

- (NSArray *)epollUWaitFor:(int)epid withTimeOutInMs:(int)msTimeOut {
    const int fdsSetSize = 1024;
    SRT_EPOLL_EVENT fdsSet[fdsSetSize];
    int n = srt_epoll_uwait(epid, fdsSet, fdsSetSize, msTimeOut);
    
    NSMutableArray* events = [NSMutableArray array];
    for(int i = 0; i < n; i++) {
        NSDictionary* dict = @{
            @"socketId" : [NSNumber numberWithInt: fdsSet[i].fd],
            @"events" : [NSNumber numberWithInt: fdsSet[i].events]
        };
        
        [events addObject: dict];
    }
    
    return events;
}

- (NSDictionary *)statsForSocket:(int)socket shouldClear:(bool)clear {
    SRT_TRACEBSTATS stats;
    
    if (srt_bstats(socket, &stats, clear) == SRT_ERROR) {
        [NSException raise:@"Could not get stats for socket" format:@"%s", srt_getlasterror_str()];
    }
    
    NSDictionary* dict = @{
        // global measurements
        @"msTimeStamp": [NSNumber numberWithLongLong: stats.msTimeStamp],
        @"pktSentTotal": [NSNumber numberWithLongLong: stats.pktSentTotal],
        @"pktRecvTotal": [NSNumber numberWithLongLong: stats.pktRecvTotal],
        @"pktSndLossTotal": [NSNumber numberWithInt: stats.pktSndLossTotal],
        @"pktRcvLossTotal": [NSNumber numberWithInt: stats.pktRcvLossTotal],
        @"pktRetransTotal": [NSNumber numberWithInt: stats.pktRetransTotal],
        @"pktSentACKTotal": [NSNumber numberWithInt: stats.pktSentACKTotal],
        @"pktRecvACKTotal": [NSNumber numberWithInt: stats.pktRecvACKTotal],
        @"pktSentNAKTotal": [NSNumber numberWithInt: stats.pktSentNAKTotal],
        @"pktRecvNAKTotal": [NSNumber numberWithLongLong: stats.usSndDurationTotal],
        @"pktSndDropTotal": [NSNumber numberWithInt: stats.pktSndDropTotal],
        @"pktRcvDropTotal": [NSNumber numberWithInt: stats.pktRcvDropTotal],
        @"pktRcvUndecryptTotal": [NSNumber numberWithInt: stats.pktRcvUndecryptTotal],
        @"byteSentTotal": [NSNumber numberWithUnsignedLongLong: stats.byteSentTotal],
        @"byteRecvTotal": [NSNumber numberWithUnsignedLongLong: stats.byteRecvTotal],
        @"byteRcvLossTotal": [NSNumber numberWithUnsignedLongLong: stats.byteRcvLossTotal],
        @"byteRetransTotal": [NSNumber numberWithUnsignedLongLong: stats.byteRetransTotal],
        @"byteSndDropTotal": [NSNumber numberWithUnsignedLongLong: stats.byteSndDropTotal],
        @"byteRcvDropTotal": [NSNumber numberWithUnsignedLongLong: stats.byteRcvDropTotal],
        @"byteRcvUndecryptTotal": [NSNumber numberWithUnsignedLongLong: stats.byteRcvUndecryptTotal],

        // local measurements
        @"pktSent": [NSNumber numberWithLongLong: stats.pktSent],
        @"pktRecv": [NSNumber numberWithLongLong: stats.pktRecv],
        @"pktSndLoss": [NSNumber numberWithInt: stats.pktSndLoss],
        @"pktRcvLoss": [NSNumber numberWithInt: stats.pktRcvLoss],
        @"pktRetrans": [NSNumber numberWithInt: stats.pktRetrans],
        @"pktRcvRetrans": [NSNumber numberWithInt: stats.pktRcvRetrans],
        @"pktSentACK": [NSNumber numberWithInt: stats.pktSentACK],
        @"pktRecvACK": [NSNumber numberWithInt: stats.pktRecvACK],
        @"pktSentNAK": [NSNumber numberWithInt: stats.pktSentNAK],
        @"pktRecvNAK": [NSNumber numberWithInt: stats.pktRecvNAK],
        @"mbpsSendRate": [NSNumber numberWithInt: stats.mbpsSendRate],
        @"mbpsRecvRate": [NSNumber numberWithInt: stats.mbpsRecvRate],
        @"usSndDuration": [NSNumber numberWithLongLong: stats.usSndDuration],
        @"pktReorderDistance": [NSNumber numberWithInt: stats.pktReorderDistance],
        @"pktRcvAvgBelatedTime": [NSNumber numberWithInt: stats.pktRcvAvgBelatedTime],
        @"pktRcvBelated": [NSNumber numberWithLongLong: stats.pktRcvBelated],
        @"pktSndDrop": [NSNumber numberWithInt: stats.pktSndDrop],
        @"pktRcvDrop": [NSNumber numberWithInt: stats.pktRcvDrop],
        @"pktRcvUndecrypt": [NSNumber numberWithInt: stats.pktRcvUndecrypt],
        @"byteSent": [NSNumber numberWithUnsignedLongLong: stats.byteSent],
        @"byteRecv": [NSNumber numberWithUnsignedLongLong: stats.byteRecv],
        @"byteRcvLoss": [NSNumber numberWithUnsignedLongLong: stats.byteRcvLoss],
        @"byteRetrans": [NSNumber numberWithUnsignedLongLong: stats.byteRetrans],
        @"byteSndDrop": [NSNumber numberWithUnsignedLongLong: stats.byteSndDrop],
        @"byteRcvDrop": [NSNumber numberWithUnsignedLongLong: stats.byteRcvDrop],
        @"byteRcvUndecrypt": [NSNumber numberWithUnsignedLongLong: stats.byteRcvUndecrypt],

        // instant measurements
        @"usPktSndPeriod": [NSNumber numberWithInt: stats.usPktSndPeriod],
        @"pktFlowWindow": [NSNumber numberWithInt: stats.pktFlowWindow],
        @"pktCongestionWindow": [NSNumber numberWithInt: stats.pktCongestionWindow],
        @"pktFlightSize": [NSNumber numberWithInt: stats.pktFlightSize],
        @"msRTT": [NSNumber numberWithInt: stats.msRTT],
        @"mbpsBandwidth": [NSNumber numberWithInt: stats.mbpsBandwidth],
        @"byteAvailSndBuf": [NSNumber numberWithInt: stats.byteAvailSndBuf],
        @"byteAvailRcvBuf": [NSNumber numberWithInt: stats.byteAvailRcvBuf],
        @"mbpsMaxBW": [NSNumber numberWithInt: stats.mbpsMaxBW],
        @"byteMSS": [NSNumber numberWithInt: stats.byteMSS],
        @"pktSndBuf": [NSNumber numberWithInt: stats.pktSndBuf],
        @"byteSndBuf": [NSNumber numberWithInt: stats.byteSndBuf],
        @"msSndBuf": [NSNumber numberWithInt: stats.msSndBuf],
        @"msSndTsbPdDelay": [NSNumber numberWithInt: stats.msSndTsbPdDelay],
        @"pktRcvBuf": [NSNumber numberWithInt: stats.pktRcvBuf],
        @"byteRcvBuf": [NSNumber numberWithInt: stats.byteRcvBuf],
        @"msRcvBuf": [NSNumber numberWithInt: stats.msRcvBuf],
        @"msRcvTsbPdDelay": [NSNumber numberWithInt: stats.msRcvTsbPdDelay],
        @"pktSndFilterExtraTotal": [NSNumber numberWithInt: stats.pktSndFilterExtraTotal],
        @"pktRcvFilterExtraTotal": [NSNumber numberWithInt: stats.pktRcvFilterExtraTotal],
        @"pktRcvFilterSupplyTotal": [NSNumber numberWithInt: stats.pktRcvFilterSupplyTotal],
        @"pktRcvFilterLossTotal": [NSNumber numberWithInt: stats.pktRcvFilterLossTotal],
        @"pktSndFilterExtra": [NSNumber numberWithInt: stats.pktSndFilterExtra],
        @"pktRcvFilterExtra": [NSNumber numberWithInt: stats.pktRcvFilterExtra],
        @"pktRcvFilterSupply": [NSNumber numberWithInt: stats.pktRcvFilterSupply],
        @"pktRcvFilterLoss": [NSNumber numberWithInt: stats.pktRcvFilterLoss],
        @"pktReorderTolerance": [NSNumber numberWithInt: stats.pktReorderTolerance],

        // Total
        @"pktSentUniqueTotal": [NSNumber numberWithLongLong: stats.pktSentUniqueTotal],
        @"pktRecvUniqueTotal": [NSNumber numberWithLongLong: stats.pktRecvUniqueTotal],
        @"byteSentUniqueTotal": [NSNumber numberWithUnsignedLongLong: stats.byteSentUniqueTotal],
        @"byteRecvUniqueTotal": [NSNumber numberWithUnsignedLongLong: stats.byteRecvUniqueTotal],

        // Local
        @"pktSentUnique": [NSNumber numberWithLongLong: stats.pktSentUnique],
        @"pktRecvUnique": [NSNumber numberWithLongLong: stats.pktRecvUnique],
        @"byteSentUnique": [NSNumber numberWithLongLong: stats.byteSentUnique],
        @"byteRecvUnique": [NSNumber numberWithUnsignedLongLong: stats.byteRecvUnique]
    };
    
    return dict;
}

@end
