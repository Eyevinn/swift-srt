//
//  Epoll.swift
//  swift-srt
//
//  Created by Jesper Lundqvist on 2021-08-19.
//

import Foundation

public struct SRTEpollEventSet: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let input = SRTEpollEventSet(rawValue: 0x1)
    public static let output = SRTEpollEventSet(rawValue: 0x4)
    public static let error = SRTEpollEventSet(rawValue: 0x8)
    public static let update = SRTEpollEventSet(rawValue: 0x10)
    public static let edgeTriggered = SRTEpollEventSet(rawValue: 1 << 31)
}

public struct SRTEpollEvent {
    public let socket: SRTSocket
    public let events: SRTEpollEventSet
    
    public init(socket: SRTSocket, events: SRTEpollEventSet) {
        self.socket = socket
        self.events = events
    }
}

public struct SRTEpoll {
    private let eid: Int32
    
    public init() {
        self.eid = SRTWrapper.sharedInstance().epollCreate()
    }
    
    public func addSocket(_ socket: SRTSocket, events: SRTEpollEventSet) {
        SRTWrapper.sharedInstance().epollAddUsock(for: eid, withSocket: socket.socketId, events: Int32(events.rawValue))
    }
    
    public func getEvents(withTimeoutInMs timeout: Int32) -> [SRTEpollEvent] {
        SRTWrapper.sharedInstance().epollUWait(for: eid, withTimeOutInMs: timeout).compactMap {
            guard let dict = $0 as? [String: Int32], let socketId = dict["socketId"], let events = dict["events"] else {
                return nil
            }
            
            return SRTEpollEvent(socket: SRTSocket(withSocketId: socketId), events: SRTEpollEventSet(rawValue: Int(events)))
        }
    }
}
