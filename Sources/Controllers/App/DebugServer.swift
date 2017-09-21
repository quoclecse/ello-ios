////
///  DebugServer.swift
//

struct DebugSettings {
    static let useStaging = "UseStaging"
    static let deepLinkURL = "DebugServer.deepLinkURL"
}

enum DebugServer: String {
    static var fromDefaults: DebugServer? {
        guard
            !Globals.isTesting,
            let name = GroupDefaults[DebugSettings.useStaging].string,
            let server = DebugServer(rawValue: name)
        else { return nil }
        return server
    }

    case ninja = "Ninja"
    case stage1 = "Stage 1"
    case stage2 = "Stage 2"

    var apiKeys: APIKeys {
        switch self {
        case .ninja: return APIKeys.ninja
        case .stage1: return APIKeys.stage1
        case .stage2: return APIKeys.stage2
        }
    }
}
