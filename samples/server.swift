//
//  server.swift
//  sample-server
//
//  Created by Jesper Lundqvist on 2021-08-23.
//

import Foundation
import swift_srt

@main
struct App {
    static func main() {
        // Start server
        let clientUrl = URL(string: "srt://0.0.0.0:1234")!
        let server = try! SRTServer(url: clientUrl)

        let cancellable = server.publisher.sink { data in
            print(String(data: data, encoding: .utf8)!)
        }

        print("Listening to " + clientUrl.absoluteString)

        server.start() { error in
            print("Error: " + error.localizedDescription)
        }

        // Wait a while before we stop
        Thread.sleep(forTimeInterval: 5)
        server.stop()
    }
}
