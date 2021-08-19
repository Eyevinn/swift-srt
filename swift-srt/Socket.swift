//
//  Socket.swift
//  swift-srt
//
//  Created by Jesper Lundqvist on 2021-08-17.
//

import Foundation

public struct SRTSocket {
    public let socketId: Int32

    public init(sender: Bool = false) {
        self.socketId = SRTWrapper.sharedInstance().createSocket(asSender: sender)
    }
    
    public init(withSocketId socket: Int32) {
        self.socketId = socket
    }
    
    public func bind(to url: URL) throws {
        guard let host = url.host, let port = url.port else {
            throw URLError(.badURL)
        }
        
        SRTWrapper.sharedInstance().bindSocket(socketId, forAddress: host, atPort: Int32(port))
    }
    
    public func listen(withBacklog backlog: Int) {
        SRTWrapper.sharedInstance().listen(onSocket: socketId, withBacklog: Int32(backlog))
    }
    
    public func connect(to url: URL) throws {
        guard let host = url.host, let port = url.port else {
            throw URLError(.badURL)
        }
        
        SRTWrapper.sharedInstance().connect(toSocket: socketId, withHost: host, atPort: Int32(port))
    }
    
    public func accept() -> SRTSocket {
        let newSocket = SRTWrapper.sharedInstance().acceptSocket(socketId)
        return SRTSocket(withSocketId: newSocket)
    }
    
    public func close() {
        SRTWrapper.sharedInstance().closeSocket(socketId)
    }
    
    public func read(dataWithSize size: Int) -> Data {
        SRTWrapper.sharedInstance().read(fromSocket: socketId, withChunkSize: Int32(size))
    }
    
    public func write(data: Data) {
        SRTWrapper.sharedInstance().write(toSocket: socketId, withChunk: data)
    }
    
    // TODO: Add enum for option and support more types
    public func set(option: Int, value: Int) {
        SRTWrapper.sharedInstance().setOption(Int32(option), toValue: Int32(value), forSocket: socketId)
    }
    
    // TODO: Enum for options and do not use NSValue
    public func get(option: Int) -> NSValue {
        SRTWrapper.sharedInstance().getOption(Int32(option), fromSocket: socketId)
    }
    
    public func stats(shouldClear clear: Bool) -> [AnyHashable: Any] {
        SRTWrapper.sharedInstance().stats(forSocket: socketId, shouldClear: clear)
    }
}
