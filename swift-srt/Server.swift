//
//  Server.swift
//  swift-srt
//
//  Created by Jesper Lundqvist on 2021-08-20.
//

import Combine

public class SRTServer {
    public var publisher: AnyPublisher<Data, Never> {
        self.subject.eraseToAnyPublisher()
    }
    private let subject = PassthroughSubject<Data, Never>()
    private let socket: SRTSocket
    private var running = false
    
    public init(url: URL) throws {
        self.socket = SRTSocket()
        try self.socket.bind(to: url)
        try self.socket.listen(withBacklog: 2)
    }
    
    public func start(onError: ((SRTError) -> Void)? = nil) {
        guard !running else {
            return
        }
        
        running = true
        
        DispatchQueue.global().async { [weak self] in
            do {
                let fd = try self?.socket.accept()

                while let fd = fd, let subject = self?.subject, let running = self?.running, running {
                    let data = try fd.read(dataWithSize: 1316)
                    subject.send(data)
                }
            }
            catch {
                if let srtError = error as? SRTError {
                    onError?(srtError)
                }
            }
        }
    }
    
    public func stop() {
        running = false
    }
}
