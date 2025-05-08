# Media Library Adapter Pattern App

A Swift console application that demonstrates the Adapter design pattern by integrating multiple incompatible media sources into a unified media library system.

## Overview

This application simulates a media management platform that can work with various media sources (Spotify, YouTube, local files) through a consistent interface. The Adapter pattern allows these incompatible systems to work together seamlessly, providing users with a unified experience regardless of where their media comes from.

## Design Pattern: Adapter

The Adapter pattern is a structural design pattern that allows objects with incompatible interfaces to collaborate. It acts as a wrapper that converts the interface of one class into another interface that clients expect.

### Types of Adapters Demonstrated

1. **Object Adapter**: Uses composition to adapt one interface to another (e.g., `SpotifyTrackAdapter`)
2. **Class Adapter**: Uses inheritance to adapt interfaces (not used in this implementation due to Swift's lack of multiple inheritance)

### Key Components in This Implementation

1. **Target (`MediaItem` protocol)**: Defines the domain-specific interface that the client uses.
2. **Client (`MediaLibrary`)**: Collaborates with objects conforming to the Target interface.
3. **Adaptee (e.g., `SpotifyTrack`, `YouTubeVideo`, `LocalFile`)**: Defines existing interfaces that need adapting.
4. **Adapter (e.g., `SpotifyTrackAdapter`, `YouTubeVideoAdapter`, `LocalFileAdapter`)**: Adapts the Adaptee's interface to the Target interface.
5. **Adapter Factory (`AdapterFactory`)**: Creates appropriate adapters based on the source type.

## Project Structure

```
MediaLibraryAdapterPatternApp/
├── Sources/
│   ├── MediaItem.swift           # Target interface
│   ├── MediaLibrary.swift        # Client
│   ├── SpotifyAPI.swift          # Adaptee
│   ├── SpotifyAdapter.swift      # Adapter
│   ├── YouTubeAPI.swift          # Adaptee
│   ├── YouTubeAdapter.swift      # Adapter
│   ├── LocalFileSystem.swift     # Adaptee
│   ├── LocalFileAdapter.swift    # Adapter
│   ├── AdapterFactory.swift      # Factory for creating adapters
│   └── main.swift                # Application entry point
└── Package.swift                 # Swift package definition
```

## Features

- Unified interface for different media sources (Spotify, YouTube, local files)
- Search across all media sources with a single query
- Play media from any source through a consistent interface
- Sort and filter media by various properties (type, creator, duration, etc.)
- View detailed metadata for any media item
- Create playlists with media from multiple sources
- Export media information in various formats

## How the Adapter Pattern is Applied

In this application:

1. The `MediaItem` protocol defines a common interface that all media items must implement.
2. Each media source has its own native interface:
   - `SpotifyTrack` with Spotify-specific properties and methods
   - `YouTubeVideo` with YouTube-specific properties and methods
   - `LocalFile` with filesystem-specific properties and methods
3. Adapter classes wrap these native objects and implement the `MediaItem` interface:
   - `SpotifyTrackAdapter` adapts `SpotifyTrack` to `MediaItem`
   - `YouTubeVideoAdapter` adapts `YouTubeVideo` to `MediaItem`
   - `LocalFileAdapter` adapts `LocalFile` to `MediaItem`
4. The `MediaLibrary` client works exclusively with the `MediaItem` interface, unaware of the underlying implementations.

### Example Adaptation

For example, the `SpotifyTrackAdapter`:
- Takes a `SpotifyTrack` object in its constructor
- Maps Spotify-specific properties (like `trackName`, `artistName`, `durationMs`) to `MediaItem` properties (`title`, `creator`, `duration`)
- Implements `MediaItem` methods by delegating to the wrapped `SpotifyTrack` object
- Handles any necessary conversions (e.g., duration from milliseconds to seconds)

## Benefits of the Adapter Pattern

1. **Decoupling**: The client code (`MediaLibrary`) is decoupled from the specific implementations of media sources.
2. **Reusability**: Existing classes can be reused even if their interfaces don't match what's needed.
3. **Flexibility**: New media sources can be integrated by simply creating new adapters, without modifying existing code.
4. **Single Responsibility**: Each adapter is responsible only for the conversion between interfaces.

## Running the Application

To run the application:

```bash
cd /path/to/MediaLibraryAdapterPatternApp
swift build
swift run
```

## Usage Example

The application allows you to:

1. Browse media from different sources in a unified library
2. Search for media across all sources with a single command
3. Create playlists with media from multiple sources
4. Play any media item regardless of its source
5. View detailed information about any media item

## Implementation Details

- The application uses Swift's protocol-oriented programming approach.
- Adapters handle not only property mapping but also behavior adaptation.
- The `AdapterFactory` implements the Factory pattern to create the appropriate adapter based on the media source.
- Error handling is implemented to deal with source-specific issues (authentication, network problems, file access).
- Media quality and size calculations are adapted based on source-specific information.
