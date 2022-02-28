//
//  main.swift
//  Wordle_Solver
//
//  Created by Adin Ackerman on 2/28/22.
//

import Foundation

/**
 Retreives the word set from a word databse.

 - Throws: `URLError.badURL`
    If the URL is a bad URL.
 - Throws: `URLError.cannotParseResponse`
    If the website contents are unable to be parsed.

 - Returns: A list of strings representing each word in the dictionary.
 */
func get_words() throws -> [String] {
    guard let url = URL(string: "http://www.mieliestronk.com/corncob_caps.txt") else {
        throw URLError(.badURL)
    }
        
    do {
        let contents = try String(contentsOf: url)
        return contents.components(separatedBy: "\r\n")
    } catch {
        throw URLError(.cannotParseResponse)
    }
}

/**
 Finds list of possible words that satisfy the given contraints.
 
 - Parameters:
    - words: The list of available words.
    - known: The string representing the known characters and positions.
    - not_allowed: Characters that are not in the target word.
    - must_contain: Characters that are in the target word at an unknown position and multiplicity.
 
 - Returns: List of possible words.
 */
func get_wordle(words: [String], known: String, not_allowed: String, must_contain: String) -> [String]{
    var possible: [String] = []
    
    let lower_words = words.map { word in
        word.lowercased()
    }
    
    let filtered_words = lower_words.filter({ word in
        word.count == known.count &&
        !word.contains(where: { char in
            not_allowed.contains(char)
        }) &&
        !must_contain.contains(where: { char in
            !word.contains(char)
        })
    })
    
    for word in filtered_words {
        if !zip(known, word).filter({ (l1, l2) in
            l1 != "_"
        }).map({ (l1, l2) in
            l1 == l2
        }).contains(false) {
            possible.append(word)
        }
    }
    
    return possible
}

// Main function
func main() {
    print("Enter known letters (\'_\' if unknown): ", terminator: "")
    let known = readLine()

    print("Enter letters that must be in the word: ", terminator: "")
    let must_contain = readLine()

    print("Disallowed letters: ", terminator: "")
    let not_allowed = readLine()

    if not_allowed!.contains(where: { char in known!.contains(char) }) {
        print("Warning: not_allowed characters and known characters intersect. Correct words may be omitted.")
    }
    
    print("Fetching word list...")

    do {
        let words = try get_words()
        print("Done.")

        print("Matching words...")
        let possible = get_wordle(words: words, known: known!, not_allowed: not_allowed!, must_contain: must_contain!)
        
        print("Possible words:", possible.map {String($0)}.joined(separator: ", "))
    } catch {
        print("Failed.")
        return
    }
}

// Main

main()
