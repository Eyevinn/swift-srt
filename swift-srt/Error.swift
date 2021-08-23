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

extension SRTError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error."
        case .esockfail:
            return "An error occurred when trying to call a system function on an internally used UDP socket."
        case .etimeout:
            return "The operation timed out."
        case .econnsetup:
            return "General setup error resulting from internal system state."
        case .enoconn:
            return "The socket is not connected."
        case .econnsock:
            return "The socket is currently connected and therefore performing the required operation is not possible."
        case .erdperm:
            return "Read permission was denied when trying to read from file."
        case .easyncfail:
            return "General asynchronous failure."
        case .esclosed:
            return "A socket that was vital for an operation called in blocking mode has been closed during the operation."
        case .epollempty:
            return "The epoll container currently has no subscribed sockets."
        case .econnrej:
            return "Connection has been rejected."
        case .efile:
            return "General filesystem error."
        case .einvrdoff:
            return "Failure when trying to read from a given position in the file."
        case .einvop:
            return "Invalid operation performed for the current state of a socket."
        case .erdvnoserv:
            return "The required operation cannot be performed when the socket is set to rendezvous mode."
        case .einvsock:
            return "The API function required an ID of an entity (socket or group) and it was invalid."
        case .enolisten:
            return "The socket passed for the operation is required to be in the listen state."
        case .eduplisten:
            return "The port tried to be bound for listening is already busy."
        case .epeererr:
            return "Receiver peer is writing to a file that the agent is sending."
        case .ewrperm:
            return "Write permission was denied when trying to write to a file."
        case .einvalbufferapi:
            return "The function was used incorrectly in the stream (buffer) API."
        case .erdvunbound:
            return "An attempt was made to connect to a socket set to rendezvous mode that was not first bound."
        case .esysobj:
            return "System was unable to allocate system specific objects."
        case .enoserver:
            return "Connection timed out while attempting to connect to the remote address."
        case .easyncsnd:
            return "Sending operation is not ready to perform."
        case .einvwroff:
            return "Failed to set position in the written file."
        case .einvalmsgapi:
            return "The function was used incorrectly in the message API."
        case .eunboundsock:
            return "The operation to be performed on a socket requires that it first be explicitly bound."
        case .econgest:
            return "With SRTO_TSBPDMODE and SRTO_TLPKTDROP set to true, some packets were dropped by sender."
        case .enobuf:
            return "System was unable to allocate memory for buffers."
        case .econnlost:
            return "The socket was properly connected, but the connection has been broken."
        case .einvparam:
            return "Call parameters for API functions have some requirements that were not satisfied."
        case .einvpollid:
            return "The epoll ID passed to an epoll function is invalid."
        case .easyncrcv:
            return "Receiving operation is not ready to perform."
        case .esecfail:
            return "A possible tampering with the handshake packets was detected, or encryption request wasn't properly fulfilled."
        case .elargemsg:
            return "Size exceeded."
        case .econnfail:
            return "General connection failure of unknown details."
        case .ethread:
            return "System was unable to spawn a new thread when requried."
        case .eboundsock:
            return "The socket is currently bound and the required operation cannot be performed in this state."
        case .eresource:
            return "System or standard library error reported unexpectedly for unknown purpose."
        }
    }
}
