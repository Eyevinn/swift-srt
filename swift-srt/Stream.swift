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
        do {
            try self.socket.connect(to: serverUrl)
        }
        catch {
            print("Connection error: \(error.localizedDescription)")
        }
    }
    
    public func close() {
        self.socket.close()
    }
    
    deinit {
        self.socket.close()
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
