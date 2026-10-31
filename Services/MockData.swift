import Foundation

enum MockData {
    static let toy = Toy(name: "Nova", brand: "Generic BLE", state: .disconnected, batteryPercent: nil)

    static let users: [UserSummary] = [
        UserSummary(username: "thisKITTYpurrs", level: 4),
        UserSummary(username: "nightowl42", level: 9, isVerified: true),
        UserSummary(username: "vonaschenbach", level: 2),
        UserSummary(username: "dawnofwar400", level: 6)
    ]

    static let posts: [Post] = [
        Post(author: users[1], caption: "finally got my DIY pattern tuned in, this one slaps", likeCount: 41, categoryTag: "DIY"),
        Post(author: users[2], caption: "rate my shelf setup", likeCount: 12, categoryTag: "Life"),
        Post(author: users[3], caption: "sound mode reacting to my playlist rn and it's unreal", likeCount: 77, categoryTag: "Toy"),
        Post(author: users[0], caption: "happy spooky season to all my fellow gremlins 🎃", likeCount: 22, categoryTag: "Life")
    ]

    static let chats: [ChatPreview] = [
        ChatPreview(user: users[1], lastMessage: "you still up for a sync session later?", timestamp: Date().addingTimeInterval(-300), unread: true),
        ChatPreview(user: users[2], lastMessage: "that pattern you sent is so good", timestamp: Date().addingTimeInterval(-3600)),
        ChatPreview(user: users[3], lastMessage: "added you back 🙌", timestamp: Date().addingTimeInterval(-86400))
    ]

    static let profile = CurrentUserProfile(
        username: "yourUsername",
        bio: "building this thing, mostly to see if i can",
        level: 4,
        levelProgress: 885,
        levelCap: 5000,
        following: 12,
        followers: 8,
        friends: 3,
        memberId: "10492021"
    )
}
