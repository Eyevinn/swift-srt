//
//  Socket.swift
//  swift-srt
//
//  Created by Jesper Lundqvist on 2021-08-17.
//

import Foundation
import Combine

public enum SRTSocketOption: Int {
    case mss = 0              // the Maximum Transfer Unit
    case sndsyn = 1           // if sending is blocking
    case rcvsyn = 2           // if receiving is blocking
    case isn = 3              // Initial Sequence Number (valid only after srt_connect or srt_accept-ed sockets)
    case fc = 4               // Flight flag size (window size)
    case sndbuf = 5           // maximum buffer in sending queue
    case rcvbuf = 6           // UDT receiving buffer size
    case linger = 7           // waiting for unsent data when closing
    case udp_sndbuf = 8       // UDP sending buffer size
    case udp_rcvbuf = 9       // UDP receiving buffer size

    case rendezvous = 12      // rendezvous connection mode
    case sndtimeo = 13        // send() timeout
    case rcvtimeo = 14        // recv() timeout
    case reuseaddr = 15       // reuse an existing port or create a new one
    case maxbw = 16           // maximum bandwidth (bytes per second) that the connection can use
    case state = 17           // current socket state, see UDTSTATUS, read only
    case event = 18           // current available events associated with the socket
    case snddata = 19         // size of data in the sending buffer
    case rcvdata = 20         // size of data available for recv
    case sender = 21          // Sender mode (independent of conn mode), for encryption, tsbpd handshake.
    case tsbpdmode = 22       // Enable/Disable TsbPd. Enable -> Tx set origin timestamp, Rx deliver packet at origin time + delay
    case latency = 23         // NOT RECOMMENDED. SET: to both SRTO_RCVLATENCY and SRTO_PEERLATENCY. GET: same as SRTO_RCVLATENCY.
    case inputbw = 24         // Estimated input stream rate.
    case oheadbw              // MaxBW ceiling based on % over input stream rate. Applies when UDT_MAXBW=0 (auto).
    case passphrase = 26      // Crypto PBKDF2 Passphrase (must be 10..79 characters, or empty to disable encryption)
    case pbkeylen             // Crypto key len in bytes {16,24,32} Default: 16 (AES-128)
    case kmstate              // Key Material exchange status (UDT_SRTKmState)
    case ipttl = 29           // IP Time To Live (passthru for system sockopt IPPROTO_IP/IP_TTL)
    case iptos                // IP Type of Service (passthru for system sockopt IPPROTO_IP/IP_TOS)
    case tlpktdrop = 31       // Enable receiver pkt drop
    case snddropdelay = 32    // Extra delay towards latency for sender TLPKTDROP decision (-1 to off)
    case nakreport = 33       // Enable receiver to send periodic NAK reports
    case version = 34         // Local SRT Version
    case peerversion          // Peer SRT Version (from SRT Handshake)
    case conntimeo = 36       // Connect timeout in msec. Caller default: 3000, rendezvous (x 10)
    case drifttracer = 37     // Enable or disable drift tracer
    case mininputbw = 38      // Minimum estimate of input stream rate.

    case sndkmstate = 40      // (GET) the current state of the encryption at the peer side
    case transtype = 50       // Transmission type (set of options required for given transmission type)
    case packetfilter = 60    // Add and configure a packet filter
    case retransmitalgo = 61   // An option to select packet retransmission algorithm}
}

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
        
        if let exception = tryBlock({
            SRTWrapper.sharedInstance().bindSocket(socketId, forAddress: host, atPort: Int32(port))
        }) {
            throw SRTError(rawValue: Int(exception.name.rawValue) ?? -1) ?? SRTError.unknown
        }
    }
    
    public func listen(withBacklog backlog: Int) throws {
        if let exception = tryBlock({
            SRTWrapper.sharedInstance().listen(onSocket: socketId, withBacklog: Int32(backlog))
        }) {
            throw SRTError(rawValue: Int(exception.name.rawValue) ?? -1) ?? SRTError.unknown
        }
    }
    
    public func connect(to url: URL) throws {
        guard let host = url.host, let port = url.port else {
            throw URLError(.badURL)
        }
        
        if let exception = tryBlock({
            SRTWrapper.sharedInstance().connect(toSocket: socketId, withHost: host, atPort: Int32(port))
        }) {
            throw SRTError(rawValue: Int(exception.name.rawValue) ?? -1) ?? SRTError.unknown
        }
    }
    
    public func accept() throws -> SRTSocket {
        var newSocket: Int32 = 0
        
        if let exception = tryBlock({
            newSocket = SRTWrapper.sharedInstance().acceptSocket(socketId)
        }) {
            throw SRTError(rawValue: Int(exception.name.rawValue) ?? -1) ?? SRTError.unknown
        }
        
        return SRTSocket(withSocketId: newSocket)
    }
    
    public func close() {
        SRTWrapper.sharedInstance().closeSocket(socketId)
    }
    
    public func read(dataWithSize size: Int) throws -> Data {
        var data = Data()
        
        if let exception = tryBlock({
            data = SRTWrapper.sharedInstance().read(fromSocket: socketId, withChunkSize: Int32(size))
        }) {
            throw SRTError(rawValue: Int(exception.name.rawValue) ?? -1) ?? SRTError.unknown
        }
        
        return data
    }
    
    public func write(data: Data) throws {
        if let exception = tryBlock({
            SRTWrapper.sharedInstance().write(toSocket: socketId, withChunk: data)
        }) {
            throw SRTError(rawValue: Int(exception.name.rawValue) ?? -1) ?? SRTError.unknown
        }
    }
    
    // TODO: Add enum for option and support more types
    public func set(option: SRTSocketOption, value: Int) throws {
        if let exception = tryBlock({
            SRTWrapper.sharedInstance().setOption(Int32(option.rawValue), toValue: Int32(value), forSocket: socketId)
        }) {
            throw SRTError(rawValue: Int(exception.name.rawValue) ?? -1) ?? SRTError.unknown
        }
    }
    
    // TODO: Enum for options and do not use NSValue
    public func get(option: SRTSocketOption) -> NSValue {
        SRTWrapper.sharedInstance().getOption(Int32(option.rawValue), fromSocket: socketId)
    }
    
    public func stats(shouldClear clear: Bool) -> [AnyHashable: Any] {
        SRTWrapper.sharedInstance().stats(forSocket: socketId, shouldClear: clear)
    }
}
