//
//  Error.swift
//  swift-srt
//
//  Created by Jesper Lundqvist on 2021-08-22.
//

import Foundation

public enum SRTError: Int, Error {
    case unknown
    case esockfail = 1003
    case etimeout = 6003
    case econnsetup = 1000
    case enoconn = 2002
    case econnsock = 5002
    case erdperm = 4002
    case easyncfail = 6000
    case esclosed = 1005
    case epollempty = 5014
    case econnrej = 1002
    case efile = 4000
    case einvrdoff = 4001
    case einvop = 5000
    case erdvnoserv = 5007
    case einvsock = 5004
    case enolisten = 5006
    case eduplisten = 5011
    case epeererr = 7000
    case ewrperm = 4004
    case einvalbufferapi = 5010
    case erdvunbound = 5008
    case esysobj = 3003
    case enoserver = 1001
    case easyncsnd = 6001
    case einvwroff = 4003
    case einvalmsgapi = 5009
    case eunboundsock = 5005
    case econgest = 6004
    case enobuf = 3002
    case econnlost = 2001
    case einvparam = 5003
    case einvpollid = 5013
    case easyncrcv = 6002
    case esecfail = 1004
    case elargemsg = 5012
    case econnfail = 2000
    case ethread = 3001
    case eboundsock = 5001
    case eresource = 3000
}
