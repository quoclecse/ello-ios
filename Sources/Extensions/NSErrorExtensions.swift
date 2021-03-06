////
///  NSErrorExtensions.swift
//

extension NSError {
    var elloError: ElloNetworkError? {
        return userInfo[NSLocalizedFailureReasonErrorKey] as? ElloNetworkError
    }

    static func uncastableJSONAble() -> NSError {
        return NSError.networkError(nil, code: ElloErrorCode.jsonMapping)
    }

}

extension Error {
    var elloErrorMessage: String? {
        let error = self as NSError
        if let elloError = error.elloError {
            return elloError.title
        }
        if let reason = error.userInfo[NSLocalizedFailureReasonErrorKey] as? String {
            return reason
        }
        return nil
    }
}
