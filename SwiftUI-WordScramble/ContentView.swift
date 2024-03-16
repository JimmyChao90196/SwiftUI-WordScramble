//
//  ContentView.swift
//  SwiftUI-WordScramble
//
//  Created by JimmyChao on 2024/3/16.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var errorTitle = ""
    @State private var score = 0
    
    var body: some View {
        
        NavigationStack {
            List {
                Section {
                    TextField("Enter the word", text: $newWord)
                }
                
                Section("Current score") {
                    Text("The current score is \(score)")
                }
                
                Section("Used word") {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .textInputAutocapitalization(.never)
            .onSubmit { addNewWord() }
            .onAppear { startGame() }
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
            .toolbar{
                Button("Refresh") {
                    withAnimation {
                        usedWords.removeAll()
                        startGame()
                    }
                }
            }

        }
    }
    
    // MARK: - Functions -
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            showError(title: "Used word", message: "try and create something new")
            return
        }
        
        guard isPossible(word: answer) else {
            showError(title: "Not possible", message: "Use the provied letter ok ?")
            return
        }
        
        guard isReal(word: answer) else {
            showError(title: "Not a real word", message: "Do not try to invent word")
            return
        }
        
        guard isLonger(than: 2, word: answer) else {
            showError(title: "Too short", message: "Think of something longer than 2 letters")
            return
        }
        
        score += 1
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        // Reset
        newWord = ""
    }
    
    private func startGame() {
        guard let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt"),
              let startWords = try? String(contentsOf: startWordUrl)
        else { fatalError() }
        
        let allWords = startWords.components(separatedBy: "\n")
        
        rootWord = allWords.randomElement() ?? "silkworm"
    }
    
    private func isOriginal(word: String) -> Bool {
        if usedWords.contains(word) {
            return false
        } else {
            return true
        }
    }
    
    private func isPossible(word: String) -> Bool {
        var tempRootWord = rootWord
        for letter in word {
            guard let pos = tempRootWord.firstIndex(of: letter) else { return false }
            tempRootWord.remove(at: pos)
        }
        return true
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspellingRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspellingRange.location == NSNotFound
    }
    
    private func isLonger(than count: Int, word: String) -> Bool {
        if word.count > count {
            true
        } else {
            false
        }
    }
    
    // Helper function
    private func showError(title: String, message: String) {
        errorMessage = message
        errorTitle = title
        showingError = true
    }
}

#Preview {
    ContentView()
}
