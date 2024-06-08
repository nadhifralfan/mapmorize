//
//  MusicView.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 17/05/24.
//

import SwiftUI
import MusicKit

struct MusicPlayerView: View {
    @ObservedObject var musicPlayer: MusicManager

    var body: some View {
        HStack {
            if let artwork = musicPlayer.currentArtwork {
               ArtworkImage(artwork, width: 50)
                   .cornerRadius(8)
            } else{
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(musicPlayer.currentTitle)
                    .font(Font.system(.headline).bold())
                    .multilineTextAlignment(.center)
                Text(musicPlayer.currentArtist)
                    .font(.system(.subheadline))
            }
            Spacer()
            HStack(spacing: 10) {
                Button(action: {
                    if musicPlayer.playbackTime() < 5 {
                        musicPlayer.previous()
                    } else {
                        musicPlayer.seekForward()
                    }
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 30, height: 30)
                            .accentColor(.pink)
                            .shadow(radius: 10)
                        Image(systemName: "backward.fill")
                            .foregroundColor(.white)
                            .font(.system(.caption))
                    }
                }

                Button(action: {
                    if musicPlayer.status() == "Paused" || musicPlayer.status() == "Stopped" {
                        musicPlayer.playContinue()
                    } else {
                        musicPlayer.pause()
                    }
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 30, height: 30)
                            .accentColor(.pink)
                            .shadow(radius: 10)
                        Image(systemName: musicPlayer.getPlayingStatus() ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .font(.system(.caption))
                    }
                }

                Button(action: {
                    musicPlayer.playNext()
                    musicPlayer.updateCurrentTrackInfo()
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 30, height: 30)
                            .accentColor(.pink)
                            .shadow(radius: 10)
                        Image(systemName: "forward.fill")
                            .foregroundColor(.white)
                            .font(.system(.caption))
                    }
                }
            }
        }
        .padding()
        .onAppear {
            if musicPlayer.status() == "Playing" {
                musicPlayer.updatePlayingStatus(true)
            } else {
                musicPlayer.updatePlayingStatus(false)
            }
        }
    }
}

#Preview {
    MusicPlayerView(musicPlayer: MusicManager())
}
