//
//  MusicKit.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 16/05/24.
//

import Foundation
import MusicKit

class MusicManager: ObservableObject {
    public var systemMusicPlayer = SystemMusicPlayer.shared
    private var isPlaying: Bool = false
    @Published public var currentTitle: String = "Title"
    @Published public var currentArtist: String = "Artist"
    @Published public var currentArtwork: Artwork?
    
    func seekForward(){
        Task {
            do {
                systemMusicPlayer.beginSeekingForward()
            }
        }
    }
    
    func playbackTime() -> TimeInterval {
        return systemMusicPlayer.playbackTime
    }
    
    func status() -> String {
        switch systemMusicPlayer.state.playbackStatus {
        case .playing:
            return "Playing"
        case .paused:
            return "Paused"
        case .stopped:
            return "Stopped"
        case .interrupted:
            return "Interrupted"
        case .seekingBackward:
            return "Seeking Backward"
        default:
            return "Unknown"
        }
    }
    
    func playNext() {
        Task {
            do {
                try await systemMusicPlayer.skipToNextEntry()
                updateCurrentTrackInfo()
            } catch {
                print("Error skipping to next song: \(error.localizedDescription)")
            }
        }
    }
    
    func previous() {
        Task {
            do {
                try await systemMusicPlayer.skipToPreviousEntry()
                updateCurrentTrackInfo()
            } catch {
                print("Error skipping to previous song: \(error.localizedDescription)")
            }
        }
    }
    
    func playContinue() {
        Task {
            do {
                try await systemMusicPlayer.play()
                updatePlayingStatus(true)
                updateCurrentTrackInfo()
            } catch {
                print("Error playing the song: \(error.localizedDescription)")
            }
        }
    }
    
    func pause() {
        Task {
            do {
                systemMusicPlayer.pause()
                updatePlayingStatus(false)
            }
        }
    }
    
    func stop() {
        Task {
            do {
                systemMusicPlayer.stop()
                updatePlayingStatus(true)
            }
        }
    }

    func play(songID: MusicItemID) {
        Task {
            do {
                let status = await MusicAuthorization.request()
                
                switch status {
                case .authorized:
                    let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: songID)
                    let response = try await request.response()
                    
                    guard let song = response.items.first else {
                        return
                    }
                    try await systemMusicPlayer.queue.insert(song, position: .afterCurrentEntry)
                    try await systemMusicPlayer.skipToNextEntry()
                    try await systemMusicPlayer.play()
                    systemMusicPlayer.state.repeatMode = .one
                    updatePlayingStatus(true)
                    updateCurrentTrackInfo()
                default:
                    print("Not authorized music player")
                    break
                }
            } catch {
                print("Error playing the song: \(error.localizedDescription)")
            }
        }
    }
    
    func getPlayingStatus() -> Bool {
        return isPlaying
    }
    
    func updatePlayingStatus(_ playing: Bool) {
        self.isPlaying = playing
    }
    
    func updateCurrentTrackInfo() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            self.currentTitle = self.systemMusicPlayer.queue.currentEntry?.title ?? "Title"
            self.currentArtist = self.systemMusicPlayer.queue.currentEntry?.subtitle ?? "Artist"
            self.currentArtwork = self.systemMusicPlayer.queue.currentEntry?.artwork ?? nil
        }
    }
}
