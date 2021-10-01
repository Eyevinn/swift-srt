//
//  TSWriterDelegate.swift
//  swift-srt
//
//  Created by Eyevinn on 2021-10-01.
//

import Foundation

public protocol TSWriterDelegate: AnyObject {
    func didOutput(_ data: Data)
}
