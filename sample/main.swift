//
//  main.swift
//  sample
//
//  Created by Jesper Lundqvist on 2021-08-19.
//

import Foundation
import swift_srt
import VideoToolbox

let url = URL(string: "srt://0.0.0.0:1234")!
let client = SRTClient(url: url)

let cancellable = client.publisher.sink { data in
    print("Recieved data of size \(data.count)")
}

print("Listening to " + url.absoluteString)

client.start()
Thread.sleep(forTimeInterval: 5)
client.stop()
