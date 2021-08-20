//
//  Client.swift
//  swift-srt
//
//  Created by Jesper Lundqvist on 2021-08-20.
//

import Combine

public class SRTClient {
    public var publisher: AnyPublisher<Data, Never> {
        self.subject.eraseToAnyPublisher()
    }
    private let subject = PassthroughSubject<Data, Never>()
    private let socket: SRTSocket
    private var running = false
    
    public init(url: URL) {
        self.socket = SRTSocket()
        try! self.socket.bind(to: url)
        self.socket.set(option: .rcvsyn, value: 1)
        self.socket.listen(withBacklog: 2)
    }
    
    public func start() {
        guard !running else {
            return
        }
        
        running = true
        
        DispatchQueue.global().async { [weak self] in
            let fd = self?.socket.accept()

            while let fd = fd, let subject = self?.subject, let running = self?.running, running {
                let data = fd.read(dataWithSize: 1316)
                subject.send(data)
            }
        }
    }
    
    public func stop() {
        running = false
    }
}
