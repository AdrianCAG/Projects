// MediaLibrary.swift - Client code that works with the target interface

import Foundation

// MediaLibrary class - Client that works with the MediaItem interface
class MediaLibrary {
    private var items: [String: MediaItem] = [:]
    private var playlists: [String: [String]] = [:] // playlistName: [itemIds]
    private var searchIndex: [String: Set<String>] = [:] // keyword: [itemIds]
    
    // Add a media item to the library
    func addItem(_ item: MediaItem) {
        items[item.id] = item
        print("📥 Added '\(item.title)' to the library")
        
        // Update search index
        indexItem(item)
    }
    
    // Remove a media item from the library
    func removeItem(withId id: String) {
        if let item = items[id] {
            items.removeValue(forKey: id)
            print("📤 Removed '\(item.title)' from the library")
            
            // Remove from playlists
            for (playlistName, itemIds) in playlists {
                if itemIds.contains(id) {
                    playlists[playlistName] = itemIds.filter { $0 != id }
                }
            }
            
            // Remove from search index
            for (keyword, itemIds) in searchIndex {
                if itemIds.contains(id) {
                    searchIndex[keyword]?.remove(id)
                }
            }
        } else {
            print("⚠️ Item with ID '\(id)' not found in the library")
        }
    }
    
    // Get a media item by ID
    func getItem(withId id: String) -> MediaItem? {
        if let item = items[id] {
            // Update last accessed time
            var updatedItem = item
            updatedItem.lastAccessed = Date()
            items[id] = updatedItem
            return updatedItem
        }
        return nil
    }
    
    // Create a new playlist
    func createPlaylist(name: String) {
        if playlists[name] == nil {
            playlists[name] = []
            print("📋 Created playlist '\(name)'")
        } else {
            print("⚠️ Playlist '\(name)' already exists")
        }
    }
    
    // Add an item to a playlist
    func addItemToPlaylist(itemId: String, playlistName: String) {
        guard let item = items[itemId] else {
            print("⚠️ Item with ID '\(itemId)' not found in the library")
            return
        }
        
        if var playlist = playlists[playlistName] {
            if !playlist.contains(itemId) {
                playlist.append(itemId)
                playlists[playlistName] = playlist
                print("➕ Added '\(item.title)' to playlist '\(playlistName)'")
            } else {
                print("⚠️ Item '\(item.title)' is already in playlist '\(playlistName)'")
            }
        } else {
            print("⚠️ Playlist '\(playlistName)' not found")
        }
    }
    
    // Remove an item from a playlist
    func removeItemFromPlaylist(itemId: String, playlistName: String) {
        guard let item = items[itemId] else {
            print("⚠️ Item with ID '\(itemId)' not found in the library")
            return
        }
        
        if var playlist = playlists[playlistName] {
            if playlist.contains(itemId) {
                playlist.removeAll { $0 == itemId }
                playlists[playlistName] = playlist
                print("➖ Removed '\(item.title)' from playlist '\(playlistName)'")
            } else {
                print("⚠️ Item '\(item.title)' is not in playlist '\(playlistName)'")
            }
        } else {
            print("⚠️ Playlist '\(playlistName)' not found")
        }
    }
    
    // Get all items in a playlist
    func getPlaylistItems(playlistName: String) -> [MediaItem] {
        if let playlist = playlists[playlistName] {
            return playlist.compactMap { items[$0] }
        } else {
            print("⚠️ Playlist '\(playlistName)' not found")
            return []
        }
    }
    
    // Play an item
    func playItem(withId id: String) -> Bool {
        if let item = getItem(withId: id) {
            print("▶️ Playing '\(item.title)'")
            return item.play()
        } else {
            print("⚠️ Item with ID '\(id)' not found in the library")
            return false
        }
    }
    
    // Stop playing an item
    func stopItem(withId id: String) {
        if let item = getItem(withId: id) {
            print("⏹️ Stopping '\(item.title)'")
            item.stop()
        } else {
            print("⚠️ Item with ID '\(id)' not found in the library")
        }
    }
    
    // Search for items
    func searchItems(query: String) -> [MediaItem] {
        let keywords = query.lowercased().split(separator: " ").map(String.init)
        var resultIds = Set<String>()
        
        for keyword in keywords {
            if let ids = searchIndex[keyword] {
                if resultIds.isEmpty {
                    resultIds = ids
                } else {
                    resultIds = resultIds.intersection(ids)
                }
            }
        }
        
        let results = resultIds.compactMap { items[$0] }
        print("🔍 Found \(results.count) items matching '\(query)'")
        return results
    }
    
    // Filter items by type
    func filterByType(_ type: MediaType) -> [MediaItem] {
        let filtered = items.values.filter { $0.type == type }
        print("🔍 Found \(filtered.count) items of type '\(type.description)'")
        return filtered
    }
    
    // Filter items by source
    func filterBySource(_ source: String) -> [MediaItem] {
        let filtered = items.values.filter { $0.sourceType == source }
        print("🔍 Found \(filtered.count) items from source '\(source)'")
        return filtered
    }
    
    // Get all items
    func getAllItems() -> [MediaItem] {
        return Array(items.values)
    }
    
    // Get library statistics
    func getStatistics() -> String {
        let totalItems = items.count
        let totalPlaylists = playlists.count
        
        var typeCount: [MediaType: Int] = [:]
        var sourceCount: [String: Int] = [:]
        var totalSize: Int = 0
        
        for item in items.values {
            typeCount[item.type, default: 0] += 1
            sourceCount[item.sourceType, default: 0] += 1
            totalSize += item.size
        }
        
        var stats = "=== Media Library Statistics ===\n"
        stats += "Total Items: \(totalItems)\n"
        stats += "Total Playlists: \(totalPlaylists)\n"
        
        if totalSize > 0 {
            let kb = Double(totalSize) / 1024.0
            let mb = kb / 1024.0
            let gb = mb / 1024.0
            
            if gb >= 1.0 {
                stats += "Total Size: \(String(format: "%.2f GB", gb))\n"
            } else if mb >= 1.0 {
                stats += "Total Size: \(String(format: "%.2f MB", mb))\n"
            } else {
                stats += "Total Size: \(String(format: "%.2f KB", kb))\n"
            }
        }
        
        stats += "\nItems by Type:\n"
        for (type, count) in typeCount.sorted(by: { $0.key.description < $1.key.description }) {
            stats += "  \(type.description): \(count)\n"
        }
        
        stats += "\nItems by Source:\n"
        for (source, count) in sourceCount.sorted(by: { $0.key < $1.key }) {
            stats += "  \(source): \(count)\n"
        }
        
        return stats
    }
    
    // Private helper method to index an item for searching
    private func indexItem(_ item: MediaItem) {
        // Index title words
        let titleWords = item.title.lowercased().split(separator: " ").map(String.init)
        for word in titleWords {
            searchIndex[word, default: []].insert(item.id)
        }
        
        // Index creator
        let creatorWords = item.creator.lowercased().split(separator: " ").map(String.init)
        for word in creatorWords {
            searchIndex[word, default: []].insert(item.id)
        }
        
        // Index tags
        for tag in item.tags {
            let tagWords = tag.lowercased().split(separator: " ").map(String.init)
            for word in tagWords {
                searchIndex[word, default: []].insert(item.id)
            }
        }
        
        // Index metadata values
        for (_, value) in item.metadata {
            let valueWords = value.lowercased().split(separator: " ").map(String.init)
            for word in valueWords {
                searchIndex[word, default: []].insert(item.id)
            }
        }
    }
}
