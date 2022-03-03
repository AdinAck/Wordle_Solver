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
func get_wordle(words: [String], green: String, not_allowed: String, orange: [String]) -> [String]{
    var possible: [String] = []
    
    let lower_words = words.map { word in
        word.lowercased()
    }
    
    var must_contain = ""
    
    for info in orange {
        for char in info {
            if char != "_" {
                must_contain.append(char)
            }
        }
    }
    
    let filtered_words = lower_words.filter({ word in
        word.count == green.count &&
        !word.contains(where: { char in
            not_allowed.contains(char)
        }) &&
        !must_contain.contains(where: { char in
            !word.contains(char)
        }) &&
        !orange.contains(where: { info in
            zip(word, info).contains(where: { (c1, c2) in
                c1 == c2
        })
        })
    })
    
    for word in filtered_words {
        if !zip(green, word).filter({ (c1, c2) in
            c1 != "_"
        }).map({ (c1, c2) in
            c1 == c2
        }).contains(false) {
            possible.append(word)
        }
    }
    
    return possible
}

func help() {
    print("""
    --- Wordle Solver ---
    
    # Synopsis
    
    This program will display all words that satisfy the contraints of a given wordle board.
    
    # Usage
    
    First enter the locations and values of the green letters with underscores in between.
    
    Example:
        The final word is 'crane',
        We know 'c', 'a', and 'n',
        So we enter:
    
        'c_an_'
    
    Next enter the locations of orange letters for every row that contains orange letters.
    
    Example:
        The final word is 'nasty',
        We know 'a' and 's' are in the word:
    
        '__as_'
    
        We also know 'n' is in the word:
    
        '___n'
    
    Next we enter all letters that are not in the word:
    
        'gelpbc'
    
    --- Wordle Solver ---
    """)
}

// Main function
func main() {
    
    if CommandLine.arguments.contains("-h") {
        help()
        return
    }
    
    print("Enter green letters (\'_\' if unknown): ", terminator: "")
    let known = readLine()!

    var orange: [String] = []
    var recv: String? = nil
    
    while recv != "" {
        print("Enter orange letters (\'_\' if unknown, return when done): ", terminator: "")
        
        recv = readLine()
        
        if recv != "" {
            orange.append(recv!)
        }
    }

    print("Enter grey letters: ", terminator: "")
    let not_allowed = readLine()!.filter({ char in
        !known.contains(char)
    })
    
    print("Fetching word list...")

    do {
        let words = try get_words()
        print("Done.")

        print("Matching words...")
        let possible = get_wordle(words: words, green: known, not_allowed: not_allowed, orange: orange)
        
        print("Possible words:", possible.map {String($0)}.joined(separator: ", "))
    } catch {
        print("Failed.")
        return
    }
}

// Main
main()
