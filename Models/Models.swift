import Foundation

// MARK: - Device / Toy

enum ToyConnectionState: String, Codable {
    case connected, disconnected, pairing
}

struct Toy: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var brand: String
    var state: ToyConnectionState
    var batteryPercent: Int?
    var iconSystemName: String = "waveform.path.ecg"
}

enum ControlMode: String, CaseIterable, Identifiable, Codable {
    case recommended = "Recommended"
    case diy = "DIY"
    case videoSync = "Video Sync"
    case audioReactive = "Audio Reactive"
    case remote = "Remote"
    case games = "Games"

    var id: String { rawValue }

    var iconSystemName: String {
        switch self {
        case .recommended: return "hand.thumbsup.fill"
        case .diy: return "hand.draw.fill"
        case .videoSync: return "play.rectangle.fill"
        case .audioReactive: return "waveform"
        case .remote: return "link"
        case .games: return "gamecontroller.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .recommended: return "Curated presets"
        case .diy: return "Build your own pattern"
        case .videoSync: return "Tagged video timelines"
        case .audioReactive: return "React to system/game audio"
        case .remote: return "Let a partner control"
        case .games: return "Mini games"
        }
    }
}

// MARK: - Social

struct UserSummary: Identifiable, Codable {
    var id: UUID = UUID()
    var username: String
    var avatarSystemName: String = "person.crop.circle.fill"
    var level: Int
    var isVerified: Bool = false
}

struct Post: Identifiable, Codable {
    var id: UUID = UUID()
    var author: UserSummary
    var caption: String
    var likeCount: Int
    var categoryTag: String
    var timestamp: Date = Date()
}

struct ChatPreview: Identifiable, Codable {
    var id: UUID = UUID()
    var user: UserSummary
    var lastMessage: String
    var timestamp: Date
    var unread: Bool = false
}

// MARK: - Profile

struct CurrentUserProfile: Codable {
    var username: String
    var bio: String
    var level: Int
    var levelProgress: Int
    var levelCap: Int
    var following: Int
    var followers: Int
    var friends: Int
    var memberId: String
}
