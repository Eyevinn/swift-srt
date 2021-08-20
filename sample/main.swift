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
let socket = SRTSocket()

// SRTO_RCVSYN to true
socket.set(option: .rcvsyn, value: 1)

try! socket.bind(to: url)
socket.listen(withBacklog: 2)

print("Listening to " + url.absoluteString)

let fd = socket.accept()

for _ in 1...100 {
    let chunk = fd.read(dataWithSize: 1316)
    print("Recieved message of length \(chunk.count)")
}

socket.close()
