//
//  main.swift
//  sample
//
//  Created by Jesper Lundqvist on 2021-08-19.
//

import Foundation
import swift_srt

let url = URL(string: "srt://0.0.0.0:1234")!
let socket = SRTSocket()
try! socket.bind(to: url)
socket.listen(withBacklog: 2)
print("Listening to " + url.absoluteString)

let fd = socket.accept()
let chunk = fd.read(dataWithSize: 1316)
print(chunk.base64EncodedString())
