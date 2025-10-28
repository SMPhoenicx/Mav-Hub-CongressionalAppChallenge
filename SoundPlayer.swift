import AVFoundation

class SoundPlayer {
    private var audioPlayer: AVAudioPlayer?
    
    // Volume property (0.0 to 1.0)
    var volume: Float = 1.0 {
        didSet {
            audioPlayer?.volume = volume
        }
    }
    
    func loadSound(named name: String) {
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("❌ Could not find sound file.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
        } catch {
            print("❌ Error creating audio player: \(error)")
        }
    }
    
    func playSound() {
        audioPlayer?.play()
    }
    
    func stopSound() {
        audioPlayer?.stop()
    }
    
    func setVolume(_ volume: Float) {
        self.volume = max(0.0, min(1.0, volume)) // Clamp between 0.0 and 1.0
    }
}
