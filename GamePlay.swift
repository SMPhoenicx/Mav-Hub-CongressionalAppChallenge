import SwiftUI
import Combine

// MARK: - Models

struct WordleGame: Codable {
    enum GameState: String, Codable {
        case playing
        case won
        case lost
    }
    
    struct GuessResult: Codable {
        enum LetterResult: String, Codable {
            case correct
            case misplaced
            case absent
        }
        
        let word: String
        let results: [LetterResult]
    }
    
    let solution: String
    private(set) var guesses: [GuessResult] = []
    private(set) var currentAttempt: String = ""
    private(set) var keyboardState: [Character: GuessResult.LetterResult] = [:]
    private(set) var gameState: GameState = .playing
    private(set) var date: Date
    
    let maxAttempts = 6
    let wordLength = 6
    
    // Add custom encode and decode methods to handle the Character dictionary
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        solution = try container.decode(String.self, forKey: .solution)
        guesses = try container.decode([GuessResult].self, forKey: .guesses)
        currentAttempt = try container.decode(String.self, forKey: .currentAttempt)
        gameState = try container.decode(GameState.self, forKey: .gameState)
        date = try container.decode(Date.self, forKey: .date)
        
        // Decode the dictionary by converting characters to strings
        let stringKeyDict = try container.decode([String: GuessResult.LetterResult].self, forKey: .keyboardState)
        keyboardState = Dictionary(uniqueKeysWithValues: stringKeyDict.map {
            (Character($0.key), $0.value)
        })
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(solution, forKey: .solution)
        try container.encode(guesses, forKey: .guesses)
        try container.encode(currentAttempt, forKey: .currentAttempt)
        try container.encode(gameState, forKey: .gameState)
        try container.encode(date, forKey: .date)
        
        // Encode the dictionary by converting characters to strings
        let stringKeyDict = Dictionary(uniqueKeysWithValues: keyboardState.map {
            (String($0.key), $0.value)
        })
        try container.encode(stringKeyDict, forKey: .keyboardState)
    }
    
    enum CodingKeys: String, CodingKey {
        case solution, guesses, currentAttempt, keyboardState, gameState, date
    }
    
    init(solution: String, date: Date = Date()) {
        self.solution = solution.uppercased()
        self.date = date
    }
    
    mutating func addLetter(_ letter: Character) -> Bool {
        guard gameState == .playing, currentAttempt.count < wordLength else { return false }
        currentAttempt.append(letter)
        return true
    }
    
    mutating func removeLetter() -> Bool {
        guard gameState == .playing, !currentAttempt.isEmpty else { return false }
        currentAttempt.removeLast()
        return true
    }
    
    mutating func submitGuess(validWords: [String]) -> Bool {
        guard gameState == .playing,
              currentAttempt.count == wordLength else { return false }
        
        // Check if the word is in the valid words list - case insensitive comparison
        guard validWords.contains(where: { $0.uppercased() == currentAttempt.uppercased() }) else { return false }
        
        let results = evaluateGuess(currentAttempt)
        guesses.append(results)
        updateKeyboardState(from: results)
        
        // Check win condition
        if currentAttempt.uppercased() == solution.uppercased() {
            gameState = .won
        } else if guesses.count >= maxAttempts {
            gameState = .lost
        }
        
        currentAttempt = ""
        return true
    }
    
    private func evaluateGuess(_ guess: String) -> GuessResult {
        let upperGuess = guess.uppercased()
        var upperSolution = solution
        var results = Array(repeating: GuessResult.LetterResult.absent, count: wordLength)
        
        // First pass: Mark correct letters
        for i in 0..<wordLength {
            let guessChar = upperGuess[upperGuess.index(upperGuess.startIndex, offsetBy: i)]
            let solutionChar = upperSolution[upperSolution.index(upperSolution.startIndex, offsetBy: i)]
            
            if guessChar == solutionChar {
                results[i] = .correct
                // Replace the matched letter to avoid double counting
                let index = upperSolution.index(upperSolution.startIndex, offsetBy: i)
                upperSolution.replaceSubrange(index...index, with: "*")
            }
        }
        
        // Second pass: Mark misplaced letters
        for i in 0..<wordLength {
            if results[i] == .correct { continue }
            
            let guessChar = upperGuess[upperGuess.index(upperGuess.startIndex, offsetBy: i)]
            if let index = upperSolution.firstIndex(of: guessChar) {
                results[i] = .misplaced
                upperSolution.replaceSubrange(index...index, with: "*")
            }
        }
        
        return GuessResult(word: upperGuess, results: results)
    }
    
    private mutating func updateKeyboardState(from result: GuessResult) {
        for i in 0..<wordLength {
            let char = result.word[result.word.index(result.word.startIndex, offsetBy: i)]
            let letterResult = result.results[i]
            
            // Only update key state if it's not already marked correct or if new result is correct
            if keyboardState[char] != .correct {
                if letterResult == .correct || keyboardState[char] == nil {
                    keyboardState[char] = letterResult
                } else if letterResult == .misplaced && keyboardState[char] != .misplaced {
                    keyboardState[char] = letterResult
                }
            }
        }
    }
    
    func getScore() -> Int? {
        guard gameState == .won else { return nil }
        // Score is based on number of attempts (lower is better)
        return maxAttempts - guesses.count + 1
    }
}

// MARK: - Game Manager

class WordleGameManager: ObservableObject {
    @Published private(set) var game: WordleGame?
    @Published private(set) var canPlayToday: Bool = false
    @Published private(set) var validWords: [String] = []
    @Published var showGameCompletedAlert = false
    @Published var alertMessage = ""
    @Published private(set) var pastSolutions: [String] = []
    
    private let userDefaults = UserDefaults.standard
    private var gameTimer: AnyCancellable?
    
    private let wordsKey = "WordleValidWords"
    private let lastPlayedDateKey = "WordleLastPlayedDate"
    private let gameStateKey = "WordleGameState"
    private let pastSolutionsKey = "WordlePastSolutions"

    private func loadPastSolutions() {
        if let data = userDefaults.data(forKey: pastSolutionsKey),
           let saved = try? JSONDecoder().decode([String].self, from: data) {
            pastSolutions = saved
        }
    }

    private func savePastSolutions() {
        if let encoded = try? JSONEncoder().encode(pastSolutions) {
            userDefaults.set(encoded, forKey: pastSolutionsKey)
        }
    }

    init() {
        loadValidWords()
        checkCanPlayToday()
        loadOrCreateGame()
        startDailyTimer()
    }
    
    private func loadValidWords() {
        // Load words from the JSON file
        if let path = Bundle.main.path(forResource: "six_letter_words", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            do {
                // If the JSON is an array of strings
                let words = try JSONDecoder().decode([String].self, from: data)
                validWords = words
                print("Loaded \(words.count) words from JSON file")
            } catch {
                print("Error decoding words: \(error)")
                // Fallback to default words if there's an error
                loadDefaultWords()
            }
        } else {
            print("Could not find or load six_letter_words.json")
            loadDefaultWords()
        }
    }
    
    private func loadDefaultWords() {
        // Ensure we have 6-letter words as default
        validWords = [
            "action", "beauty", "caring", "design", "eating", "family",
            "garden", "hazard", "island", "jungle", "knight", "laptop",
            "master", "nature", "orange", "planet", "reason", "stream",
            "travel", "unique", "virtue", "winter", "yellow", "zigzag"
        ]
    }
    
    private func checkCanPlayToday() {
        if let lastPlayed = userDefaults.object(forKey: lastPlayedDateKey) as? Date {
            canPlayToday = !Calendar.current.isDate(lastPlayed, inSameDayAs: Date())
        } else {
            canPlayToday = true
        }
    }
    
    private func loadOrCreateGame() {
        // If player can play today, either load saved game or create new one
        if let savedData = userDefaults.data(forKey: gameStateKey),
           let savedGame = try? JSONDecoder().decode(WordleGame.self, from: savedData),
           Calendar.current.isDate(savedGame.date, inSameDayAs: Date()) {
            self.game = savedGame
        } else if canPlayToday {
            // Only create new game if you're allowed to play
            print("Created")
            createNewGame()
        }

    }
    
    func createNewGame() {
        guard canPlayToday, !validWords.isEmpty else { return }

        let unusedWords = validWords.filter { !pastSolutions.contains($0) }

        // If all words have been used, fallback to full list again (optional)
        let wordPool = unusedWords.isEmpty ? validWords : unusedWords

        if let solution = wordPool.randomElement() {
            game = WordleGame(solution: solution)
            pastSolutions.append(solution)
            saveGame()
            savePastSolutions() // New helper function to persist
        }
    }

    
    func startNewGame() {
        userDefaults.removeObject(forKey: gameStateKey)
        checkCanPlayToday()
        if canPlayToday {
            createNewGame()
        }
    }
    
    func addLetter(_ letter: Character) {
        guard var game = game, canPlayToday else { return }
        if game.addLetter(letter) {
            self.game = game
            saveGame()
        }
    }
    
    func removeLetter() {
        guard var game = game, canPlayToday else { return }
        if game.removeLetter() {
            self.game = game
            saveGame()
        }
    }
    
    func submitGuess() {
        guard var game = game, canPlayToday else { return }
        
        // Check if valid word length
        if game.currentAttempt.count != game.wordLength {
            // Word too short
            NotificationCenter.default.post(
                name: NSNotification.Name("InvalidWord"),
                object: nil,
                userInfo: ["message": "Enter a \(game.wordLength)-letter word"]
            )
            return
        }
        
        // Check if in word list
        if !validWords.contains(where: { $0.uppercased() == game.currentAttempt.uppercased() }) {
            NotificationCenter.default.post(
                name: NSNotification.Name("InvalidWord"),
                object: nil,
                userInfo: ["message": "Not in word list"]
            )
            return
        }
        
        // Valid word, continue with game
        let guessSubmitted = game.submitGuess(validWords: validWords)
        
        if guessSubmitted {
            self.game = game
            saveGame()
            
            if game.gameState != .playing {
                handleGameOver()
            }
        }
    }
    
    
    private func saveGame() {
        if let game = game, let encodedGame = try? JSONEncoder().encode(game) {
            userDefaults.set(encodedGame, forKey: gameStateKey)
        }
    }
    
    private func startDailyTimer() {
        // Check for date change every minute
        gameTimer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkCanPlayToday()
            }
    }
}

// MARK: - Keyboard View

struct KeyboardView: View {
    @ObservedObject var gameManager: WordleGameManager
    
    let layout = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["ENTER", "Z", "X", "C", "V", "B", "N", "M", "DEL"]
    ]
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(layout, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                handleKeyPress(key)
                            }
                        }) {
                            Text(key)
                                .font(.system(size: key.count > 1 ? 14 : 20, weight: .semibold, design: .monospaced))
                                .frame(minWidth: keyWidth(for: key), minHeight: 50)
                                .foregroundColor(.white)
                                .background(keyBackground(for: key))
                                .cornerRadius(12)
                                .shadow(color: keyShadowColor(for: key), radius: 5, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(keyBorderColor(for: key), lineWidth: 1)
                                )
                        }
                        .buttonStyle(KeyButtonStyle())
                        .disabled(!gameManager.canPlayToday)
                    }
                }
            }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 8)
    }
    
    private func handleKeyPress(_ key: String) {
        switch key {
        case "ENTER":
            gameManager.submitGuess()
        case "DEL":
            gameManager.removeLetter()
        default:
            if let char = key.first {
                gameManager.addLetter(char)
            }
        }
    }
    
    private func keyWidth(for key: String) -> CGFloat {
        if key == "ENTER" || key == "DEL" {
            return 50
        }
        return 30
    }
    
    private func keyBackground(for key: String) -> Color {
        guard let game = gameManager.game, key.count == 1 else {
            return Color(red: 0.2, green: 0.2, blue: 0.25)
        }
        
        if let state = game.keyboardState[Character(key.uppercased())] {
            switch state {
            case .correct:
                return Color.green.opacity(0.8)
            case .misplaced:
                return Color.yellow.opacity(0.8)
            case .absent:
                return Color(red: 0.3, green: 0.3, blue: 0.35)
            }
        }
        
        return Color(red: 0.2, green: 0.2, blue: 0.25)
    }
    
    private func keyBorderColor(for key: String) -> Color {
        guard let game = gameManager.game, key.count == 1, let char = key.first else {
            return Color.gray.opacity(0.4)
        }
        
        if let state = game.keyboardState[Character(key.uppercased())] {
            switch state {
            case .correct:
                return Color.green
            case .misplaced:
                return Color.yellow
            case .absent:
                return Color.gray.opacity(0.3)
            }
        }
        
        return Color.gray.opacity(0.4)
    }
    
    private func keyShadowColor(for key: String) -> Color {
        guard let game = gameManager.game, key.count == 1, let char = key.first else {
            return Color.blue.opacity(0.2)
        }
        
        if let state = game.keyboardState[Character(key.uppercased())] {
            switch state {
            case .correct:
                return Color.green.opacity(0.6)
            case .misplaced:
                return Color.yellow.opacity(0.6)
            case .absent:
                return Color.black.opacity(0.2)
            }
        }
        
        return Color.blue.opacity(0.2)
    }
}

struct KeyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .offset(y: configuration.isPressed ? 1 : 0)
            .animation(.spring(response: 0.1, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
// MARK: - Game Board View

struct GameBoardView: View {
    @ObservedObject var gameManager: WordleGameManager
    @State private var showVictoryAnimation = false
    @State private var boardGlowColor: Color = .clear
    @State private var shakeTrigger: Int = 0
    @State private var shakingRow: Int? = nil

    @State private var showInvalidWordBadge = false
    @State private var invalidWordMessage = ""

    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<6, id: \.self) { col in
                        CellView(
                            letter: letterFor(row: row, col: col),
                            state: stateFor(row: row, col: col)
                        )
                    }
                }
                .modifier(ShakeEffect(animatableData: row == shakingRow ? CGFloat(shakeTrigger) : 0))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            ZStack {
                // Strong glow behind
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.6))

                if boardGlowColor != .clear {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(boardGlowColor, lineWidth: 4)
                        .shadow(color: boardGlowColor.opacity(0.9), radius: 20)
                        .shadow(color: boardGlowColor.opacity(0.6), radius: 40)
                        .blur(radius: 2)
                }

                // Board border (on top of glow)
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        )
        .padding(.horizontal, 12)
        .overlay(
            Group {
                if showInvalidWordBadge {
                    VStack {
                        Text(invalidWordMessage)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.5), radius: 5)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                }
            }
        )
        .onAppear {
            if let state = gameManager.game?.gameState {
                switch state {
                case .won:
                    boardGlowColor = .yellow
                    showVictoryAnimation = true
                case .lost:
                    boardGlowColor = .red
                    showVictoryAnimation = true
                default:
                    break
                }
            }
        }
        .onChange(of: gameManager.game?.gameState) { newState in
            if newState == .won {
                withAnimation(.easeInOut(duration: 0.5)) {
                    boardGlowColor = .yellow
                    showVictoryAnimation = true
                }
            } else if newState == .lost {
                withAnimation(.easeInOut(duration: 0.5)) {
                    boardGlowColor = .red
                    showVictoryAnimation = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("InvalidWord"))) { notification in
            if let message = notification.userInfo?["message"] as? String {
                invalidWordMessage = message
                
                // Trigger shake
                if let game = gameManager.game {
                    withAnimation(.default){
                        shakingRow = game.guesses.count
                        shakeTrigger += 1
                    }
                }

                
                // Show badge
                withAnimation {
                    showInvalidWordBadge = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                       shakingRow = nil
                   }
                // Hide badge after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showInvalidWordBadge = false
                    }
                }
            }
        }
    }
    
    private func letterFor(row: Int, col: Int) -> String {
        guard let game = gameManager.game else { return "" }
        
        if row < game.guesses.count {
            // Completed guess
            let guess = game.guesses[row]
            return String(guess.word[guess.word.index(guess.word.startIndex, offsetBy: col)])
        } else if row == game.guesses.count && col < game.currentAttempt.count {
            // Current attempt
            let index = game.currentAttempt.index(game.currentAttempt.startIndex, offsetBy: col)
            return String(game.currentAttempt[index])
        }
        
        return ""
    }
    
    private func stateFor(row: Int, col: Int) -> CellView.CellState {
        guard let game = gameManager.game else { return .empty }
        
        if row < game.guesses.count {
            // Completed guess
            switch game.guesses[row].results[col] {
            case .correct:
                return .correct
            case .misplaced:
                return .misplaced
            case .absent:
                return .incorrect
            }
        } else if row == game.guesses.count && col < game.currentAttempt.count {
            // Current attempt
            return .active
        } else if row == game.guesses.count && col == game.currentAttempt.count {
            // Current position
            return .cursor
        }
        
        return .empty
    }
}

struct CellView: View {
    enum CellState {
        case empty
        case active
        case cursor
        case correct
        case misplaced
        case incorrect
    }
    
    let letter: String
    let state: CellState
    
    var body: some View {
        Text(letter)
            .font(.system(size: fontSize, weight: .bold))
            .frame(minWidth: cellSize, maxWidth: cellSize, minHeight: cellSize, maxHeight: cellSize)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: borderWidth)
                    .shadow(color: glowColor, radius: glowRadius)
            )
            .animation(.spring(response: 0.3), value: state)
    }
    
    // Adaptive sizing based on screen width
    private var cellSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - 56 // Account for padding (16 + 12) * 2 + some buffer
        let cellWidth = (availableWidth - 30) / 6 // 30 for spacing between cells (6 * 5)
        return max(min(cellWidth, 60), 42) // Min 42, max 60
    }
    
    private var fontSize: CGFloat {
        return cellSize * 0.48 // Font size proportional to cell size
    }
    
    private var backgroundColor: Color {
        switch state {
        case .correct:
            return Color.green.opacity(0.8)
        case .misplaced:
            return Color.yellow.opacity(0.8)
        case .incorrect:
            return Color.gray.opacity(0.6)
        default:
            return Color.black.opacity(0.3)
        }
    }
    
    private var textColor: Color {
        switch state {
        case .empty, .cursor:
            return Color.primary
        default:
            return Color.white
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .empty:
            return Color.gray.opacity(0.3)
        case .active:
            return Color.blue.opacity(0.8)
        case .cursor:
            return Color.cyan
        default:
            return backgroundColor
        }
    }
    
    private var borderWidth: CGFloat {
        switch state {
        case .cursor:
            return 2.5
        case .active:
            return 2
        default:
            return 1.5
        }
    }
    
    private var glowColor: Color {
        switch state {
        case .correct:
            return Color.green.opacity(0.8)
        case .misplaced:
            return Color.yellow.opacity(0.7)
        case .cursor:
            return Color.cyan.opacity(0.8)
        case .active:
            return Color.blue.opacity(0.5)
        default:
            return Color.clear
        }
    }
    
    private var glowRadius: CGFloat {
        switch state {
        case .correct:
            return 4
        case .misplaced:
            return 3
        case .cursor:
            return 5
        case .active:
            return 2
        default:
            return 0
        }
    }
}


struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            10 * sin(animatableData * .pi * 2), y: 0))
    }
}


// MARK: - User Profile View

struct UserProfileView: View {
    @ObservedObject private var leaderboardManager = LeaderboardManager.shared
    @State private var username: String
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        _username = State(initialValue: LeaderboardManager.shared.username)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Profile")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.words)
                    
                    HStack {
                        Text("Total Score")
                        Spacer()
                        Text("\(leaderboardManager.totalScore)")
                            .font(.headline)
                    }
                    
                    if let rank = leaderboardManager.currentRank(for: leaderboardManager.username) {
                        HStack {
                            Text("Current Rank")
                            Spacer()
                            Text("#\(rank)")
                                .font(.headline)
                        }
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        LeaderboardManager.shared.updateUsername(username)

                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Your Profile")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Improved Leaderboard View

struct GameLeaderboardView: View {
    @ObservedObject private var leaderboardManager = LeaderboardManager.shared
    @State private var showProfileView = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isRefreshing = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.1)]),
                startPoint: .top, endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("LEADERBOARD")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        showProfileView = true
                    }) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                // User stats card
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text(leaderboardManager.username)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(leaderboardManager.totalScore) pts")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer()

                    if let rank = leaderboardManager.currentRank(for: leaderboardManager.username) {
                        VStack(alignment: .trailing) {
                            Text("Your Rank")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            Text("#\(rank)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal)

                // Leaderboard List
                if leaderboardManager.isLoading {
                    Spacer()
                    ProgressView(progress: 0.8)
                        .foregroundColor(.white)
                    Spacer()
                } else if let error = leaderboardManager.errorMessage {
                    Spacer()
                    Text("⚠️ \(error)")
                        .foregroundColor(.red)
                    Spacer()
                } else if leaderboardManager.sortedLeaderboard().isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.05)).frame(width: 140, height: 140))

                        Text("No scores yet this month")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        Text("Complete a game to be the first on the leaderboard!")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(Array(leaderboardManager.sortedLeaderboard().enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRow(entry: entry, rank: index + 1)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Text("Leaderboard resets monthly")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 5)
                    .padding(.bottom, 10)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showProfileView) {
            UserProfileView()
        }
        .onAppear {
            leaderboardManager.fetchLeaderboard()
        }
    }
}

struct WelcomeCardView: View {
    @ObservedObject private var leaderboardManager = LeaderboardManager.shared
    @State private var enteredUsername = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var startGame: () -> Void
    
    private var shouldShowTextField: Bool {
        return leaderboardManager.username.isEmpty || leaderboardManager.username == "Player"
    }
    
    private var isPlayButtonEnabled: Bool {
        if shouldShowTextField {
            return !enteredUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !(enteredUsername.trimmingCharacters(in: .whitespacesAndNewlines) == "Player")
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 5) {
                Text("6-LETTER WORDLE")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("New Challenge Available")
                    .font(.system(size: 16))
                    .foregroundColor(.cyan)
            }
            
            // Decoration
            HStack(spacing: 8) {
                ForEach(0..<6) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.cyan.opacity(0.4), radius: 4)
                }
            }
            .padding(.vertical, 10)
            
            // Username input field (only shown if username is empty)
            if shouldShowTextField {
                VStack(spacing: 8) {
                    Text("Enter your username to start playing(Cannot be \"Player\"):")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    TextField("Username", text: $enteredUsername)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            isTextFieldFocused ? Color.cyan.opacity(0.8) : Color.white.opacity(0.3),
                                            lineWidth: isTextFieldFocused ? 2 : 1
                                        )
                                )
                        )
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            if isPlayButtonEnabled {
                                saveUsernameAndStartGame()
                            }
                        }
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Info text
            Text(shouldShowTextField ?
                 "" :
                 "Guess today's 6-letter word in 6 attempts.\nThe fewer guesses you use, the higher the score you get!")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Play button
            Button(action: {
                if shouldShowTextField {
                    saveUsernameAndStartGame()
                } else {
                    startGame()
                }
            }) {
                Text("PLAY NOW")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(isPlayButtonEnabled ? .black : .gray)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: isPlayButtonEnabled ?
                                [Color.cyan, Color.blue] :
                                [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(isPlayButtonEnabled ? 0.5 : 0.2), lineWidth: 1)
                    )
                    .shadow(color: isPlayButtonEnabled ? Color.cyan.opacity(0.5) : Color.clear, radius: 8)
            }
            .disabled(!isPlayButtonEnabled)
            .animation(.easeInOut(duration: 0.2), value: isPlayButtonEnabled)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.5), radius: 20)
        )
        .frame(maxWidth: 340)
        .animation(.easeInOut(duration: 0.3), value: shouldShowTextField)
    }
    
    private func saveUsernameAndStartGame() {
        let trimmedUsername = enteredUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedUsername == "Player" {return}
        if !trimmedUsername.isEmpty {
            leaderboardManager.username = trimmedUsername
            startGame()
        }
    }
}

struct CompletionBadgeView: View {
    let isWinner: Bool
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isWinner ? "trophy.fill" : "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(isWinner ? .yellow : .red)
            
            Text(isWinner ? "YOU WIN!" : "GAME OVER")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(
            Capsule()
                .fill(isWinner ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                .overlay(
                    Capsule()
                        .stroke(isWinner ? Color.green : Color.red, lineWidth: 1.5)
                )
                .shadow(color: isWinner ? Color.green.opacity(0.5) : Color.red.opacity(0.5), radius: 8)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            // Auto-dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}
struct LeaderboardRow: View {
    let entry: LeaderboardManager.LeaderboardEntry
    let rank: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank with medal for top 3
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(medalColor)
                        .frame(width: 36, height: 36)
                        .shadow(color: medalColor.opacity(0.6), radius: 4)
                }
                
                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(rank <= 3 ? .black : .white)
                    .frame(width: 36, height: 36)
                    .background(rank <= 3 ? Color.clear : Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Username
            Text(entry.username)
                .font(.system(size: 16, weight: rank <= 3 ? .bold : .medium))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Score
            Text("\(entry.score)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(rank <= 3 ? medalColor : .white)
            
            // Date
            Text(formatDate(entry.date))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(rowBackgroundColor)
                .overlay(
                    Capsule()
                        .stroke(rowBorderColor, lineWidth: 1)
                )
                .shadow(color: rank <= 3 ? medalColor.opacity(0.4) : Color.clear, radius: rank <= 3 ? 5 : 0)
        )
    }
    
    private var medalColor: Color {
        switch rank {
        case 1: return Color.yellow // Gold
        case 2: return Color(white: 0.8) // Silver
        case 3: return Color(red: 0.7, green: 0.4, blue: 0.2) // Bronze
        default: return Color.clear
        }
    }
    
    private var rowBackgroundColor: Color {
        switch rank {
        case 1: return Color.yellow.opacity(0.15)
        case 2: return Color(white: 0.8).opacity(0.15)
        case 3: return Color(red: 0.7, green: 0.4, blue: 0.2).opacity(0.15)
        default: return Color.white.opacity(0.07)
        }
    }
    
    private var rowBorderColor: Color {
        switch rank {
        case 1: return Color.yellow.opacity(0.5)
        case 2: return Color(white: 0.8).opacity(0.5)
        case 3: return Color(red: 0.7, green: 0.4, blue: 0.2).opacity(0.5)
        default: return Color.white.opacity(0.1)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Profile Button for Main Game View

struct ProfileButton: View {
    @Binding var showProfile: Bool
    @ObservedObject var leaderboardManager = LeaderboardManager.shared
    
    var body: some View {
        Button(action: {
            showProfile = true
        }) {
            HStack {
                Image(systemName: "person.circle")
                Text(leaderboardManager.username)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

// MARK: - Main Game View

struct WordleGameView: View {
    @StateObject private var gameManager = WordleGameManager()
    @State private var showLeaderboard = false
    @State private var showProfile = false
    @State private var showWelcomeCard = false
    @State private var showGameBoard = false
    @State private var showCompletionBadge = false
    @State private var showLeaderboardAtEnd = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.08, green: 0.08, blue: 0.15), Color(red: 0.04, green: 0.04, blue: 0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            ScrollView {
            // Main game content
            VStack(spacing: 5) {
                // Header
                HStack {
                    Text("6-LETTER WORDLE")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: Color.cyan.opacity(0.5), radius: 2)
                    
                    Spacer()
                    
                    if showGameBoard {
                        ProfileButton(showProfile: $showProfile)
                        
                        Button(action: {
                            showLeaderboard.toggle()
                        }) {
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .shadow(color: Color.yellow.opacity(0.5), radius: 3)
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding(.horizontal)
                
                if showGameBoard, let game = gameManager.game {
                    GameBoardView(gameManager: gameManager)
                    if game.gameState == .playing && gameManager.canPlayToday {
                        KeyboardView(gameManager: gameManager)
                            .padding(.bottom, 20)
                    }
                    else{
                        if let game = gameManager.game, game.gameState == .won{
                            Text("You Won!")
                                .foregroundStyle(.yellow)
                        }
                        else if game.gameState == .lost{
                            Text("You Lost")
                                .foregroundStyle(.red)
                        }
                        if let game = gameManager.game, game.gameState != .playing {
                            Text("You’ve completed today’s Sixdle! \n Come back tomorrow for more")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .padding(.bottom)
                                .multilineTextAlignment(.center)
                        }
                        
                    }
                }
                Spacer(minLength: 20)
            }
        }
            .padding(.bottom, 15)
            .padding(.top, 10)
            
            // Welcome card overlay
            if showWelcomeCard {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                WelcomeCardView(startGame: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showWelcomeCard = false
                        showGameBoard = true
                    }
                })
                .transition(.scale.combined(with: .opacity))
            }
            
            // Completion badge at top
            if showCompletionBadge, let game = gameManager.game {
                VStack {
                    CompletionBadgeView(
                        isWinner: game.gameState == .won,
                        isShowing: $showCompletionBadge
                    )
                    .padding(.top, 40)
                    
                    Spacer()
                }
            }
            if showLeaderboardAtEnd {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                VStack {
                    Spacer()
                    
                    // Use a custom view with dismiss handler
                    VStack {
                        // Header with dismiss button
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    showLeaderboardAtEnd = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding()
                            }
                        }
                        
                        // Leaderboard content
                        LeaderboardContentsView()
                            .frame(height: UIScreen.main.bounds.height * 0.7)
                    }
                    .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .cornerRadius(20)
                    .padding()
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .preferredColorScheme(.dark)
        // In WordleGameView's onAppear
        .onAppear {
            DispatchQueue.main.async {
                if gameManager.canPlayToday {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 0.5)) {
                            showWelcomeCard = true
                        }
                    }
                } else {
                    showWelcomeCard = false
                    showGameBoard = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GameWon"))) { _ in
            // Show victory badge
            withAnimation {
                showCompletionBadge = true
            }
            
            // Show leaderboard after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showLeaderboardAtEnd = true
                }
            }
        }
        .sheet(isPresented: $showLeaderboard) {
            GameLeaderboardView()
        }
        .sheet(isPresented: $showProfile) {
            UserProfileView()
        }
        .alert(isPresented: $gameManager.showGameCompletedAlert) {
            Alert(
                title: Text("Game Complete"),
                message: Text(gameManager.alertMessage),
                dismissButton: .default(Text("OK")) {
                    // Show completion badge and leaderboard after dismissing alert
                    withAnimation {
                        showCompletionBadge = true
                    }
                    
                    // Show leaderboard after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            showLeaderboardAtEnd = true
                        }
                    }
                }
            )
        }
    }
}

struct LeaderboardContentsView: View {
    @ObservedObject private var leaderboardManager = LeaderboardManager.shared
    
    var body: some View {
        VStack {
            // Title
            Text("LEADERBOARD")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.top)
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    // User stats
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text(leaderboardManager.username)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(leaderboardManager.totalScore) pts")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        Spacer()
                        
                        if let rank = leaderboardManager.currentRank(for: leaderboardManager.username) {
                            VStack(alignment: .trailing) {
                                Text("Your Rank")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("#\(rank)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    if leaderboardManager.sortedLeaderboard().isEmpty {
                        VStack {
                            Spacer()
                            
                            Image(systemName: "trophy")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow.opacity(0.7))
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(width: 140, height: 140)
                                )
                            
                            Text("No scores yet this month")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            Text("Complete a game to be the first on the leaderboard!")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                    } else {
                        // Leaderboard list
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(Array(leaderboardManager.sortedLeaderboard().enumerated()), id: \.element.id) { index, entry in
                                    LeaderboardRow(entry: entry, rank: index + 1)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Text("Leaderboard resets monthly")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 5)
                        .padding(.bottom, 10)
                }
                .padding(.vertical)
            }
        }
    }
}

// MARK: - Game Manager Extension

extension WordleGameManager {
    // In WordleGameManager
    func handleGameOver() {
        // Mark as played today
        userDefaults.set(Date(), forKey: lastPlayedDateKey)
        canPlayToday = false
        
        if let game = game {
            if game.gameState == .won {
                let attemptsUsed = game.guesses.count
                let scoreValue = game.getScore() ?? 0
                
                // Add score to user's total score in leaderboard
                LeaderboardManager.shared.addScore(score: scoreValue)
                alertMessage = "You won in \(attemptsUsed) attempts! Score: \(scoreValue)"
                
                NotificationCenter.default.post(name: NSNotification.Name("GameWon"), object: nil)
            } else {
                alertMessage = "Game over! The word was \(game.solution)"
                showGameCompletedAlert = true
            }
        }
    }
}

// MARK: - Preview

#Preview{
    TabControl()
}
