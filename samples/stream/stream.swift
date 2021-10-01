//
//  stream.swift
//  sample
//
//  Created by Eyevinn on 2021-09-29.
//

import Foundation
import SwiftSRT

@main
struct App {
    static func main() {
        // Initialise stream (and start server)
        let serverUrl = URL(string: "srt://0.0.0.0:1234")!
        let stream = try! SRTStream(serverUrl: serverUrl)
        stream.close()
    }
}
