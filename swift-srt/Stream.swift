//
//  SRTStream.swift
//  swift-srt
//
//  Created by Eyevinn on 2021-09-27.
//

import Foundation

public class SRTStream {
    private let socket: SRTSocket
    private var connected: Bool = false
    
    public init(serverUrl: URL) throws {
        self.socket = SRTSocket(sender: true)
        print("Will start streaming to \(serverUrl)")
        do {
            try self.socket.connect(to: serverUrl)
            self.connected = true
        }
        catch {
            print("Connection error: \(error.localizedDescription)")
        }
    }
    
    public func close() {
        if(self.connected) {
            self.socket.close()
        }
    }
    
    deinit {
        if(self.connected) {
            self.socket.close()
        }
        
    }
}

// MARK: - TSWriterDelegate
extension SRTStream: TSWriterDelegate {
    public func didOutput(_ data: Data) {
        do {
            try self.socket.write(data: data)
        }
        catch {
            print("Connection error: \(error.localizedDescription)")
        }
    }
}
