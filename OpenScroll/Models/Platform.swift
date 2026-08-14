import Foundation

struct Platform: Identifiable, Hashable {
    let id: String
    let name: String
    let homeURL: URL
    let icon: String // SF Symbol name
}

extension Platform {
    static let all: [Platform] = [
        Platform(id: "instagram", name: "Instagram",
                 homeURL: URL(string: "https://www.instagram.com")!,
                 icon: "camera"),
        Platform(id: "youtube", name: "YouTube",
                 homeURL: URL(string: "https://m.youtube.com")!,
                 icon: "play.rectangle"),
        Platform(id: "reddit", name: "Reddit",
                 homeURL: URL(string: "https://www.reddit.com")!,
                 icon: "bubble.left.and.bubble.right"),
        Platform(id: "tiktok", name: "TikTok",
                 homeURL: URL(string: "https://www.tiktok.com/following")!,
                 icon: "music.note"),
        Platform(id: "facebook", name: "Facebook",
                 homeURL: URL(string: "https://m.facebook.com")!,
                 icon: "person.2"),
        Platform(id: "x", name: "X",
                 homeURL: URL(string: "https://x.com/home")!,
                 icon: "at"),
    ]
}
