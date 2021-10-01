//
//  SRTStream.swift
//  swift-srt
//
//  Created by Eyevinn on 2021-09-27.
//

import Foundation

public class SRTStream {
    private let socket: SRTSocket
    
    public init(serverUrl: URL) throws {
        self.socket = SRTSocket(sender: true)
        print("Will start streaming to \(serverUrl)")
    }
    
    public func close() {
        socket.close()
    }
    
    deinit {
        socket.close()
    }
}

// MARK: - TSWriterDelegate
extension SRTStream: TSWriterDelegate {
    public func didOutput(_ data: Data) {
        // send here
    }
}
