//
//  Match.swift
//  Speech
//
//  Created by Swift Development Environment on 26/6/18.
//  Copyright © 2018 Google. All rights reserved.
//

import Foundation

class Match
{
    
    private(set) var sentences = [String]()
    private var sentencesWordCount = [Int:Int]()
    
    //myMagicNumbers
    var min = 0
    static let threshold = 40
    private var lowMergeThreshold = (Match.threshold / 4) // in words
    
    private func highestProbabilityStringIndex(probabilityArray:[Double]) -> Int {
        print(probabilityArray)
        if probabilityArray[1] > (0.95 * probabilityArray[0]) {
            return 1
        }
        return probabilityArray.index(of: probabilityArray.max()!)!
    }
    
    //need to check range limits when range is provided for efficient searching
    func compareStringWithSentences(googleString givenString:String) -> Int {
        
        if givenString.wordCount() < 7 {
            print(givenString)
            return min
        }
        let spokenString:String
        if givenString.wordCount() > lowMergeThreshold {
            spokenString = takeLastPartOfString(givenString)
        } else {
            spokenString = givenString
        }
        print(spokenString)
        var allPercentages = [Double]()
        for index in min...(min+1) {
            print("index = \(index), sentence.count = \(sentences.count)")
            if index == (sentences.count) {
                print("called")
                allPercentages.append(0.0)
            }
            allPercentages.append(matchPercentage(testString: spokenString.tokenize(), matchAgainstIndex: index))
        }
        let probabilityIndex = highestProbabilityStringIndex(probabilityArray: allPercentages)
        min += probabilityIndex
        return min
    }
    
    private func matchPercentage(testString someString:[String], matchAgainstIndex index:Int) -> Double {
        var counter = 0.0
        someString.forEach {
            if sentences[index].containsIgnoringCase(find: $0) {
                counter += 1
            }
        }
        return counter / Double(sentencesWordCount[index]!)
    }
    
    private func takeLastPartOfString(_ str:String) -> String {
        let array = str.tokenize()
        var newString = ""
        for index in array.indices {
            if index > (str.wordCount() - lowMergeThreshold) {
                newString = newString + " " + array[index]
            }
        }
        return newString
    }
    
    func fakeInit(document:String){
        
        var sentenceTokens = document.components(separatedBy: CharacterSet.init(charactersIn: ",.;—")).filter({!($0.isEmpty)})
        repeat {
            var lastIndex = 0
            for index in sentenceTokens.indices {
                if sentenceTokens[index].wordCount() < lowMergeThreshold {
                    lastIndex = index
                }
            }
            if lastIndex != 0 {
                sentenceTokens[lastIndex - 1] = sentenceTokens[lastIndex - 1] + sentenceTokens.remove(at: lastIndex)
            }
            
        } while (sentenceTokens.filter({$0.wordCount() < lowMergeThreshold}).count > 0)
        
        sentenceTokens.append("END OF SPEECH")
        sentences = sentenceTokens
        
        print(sentences)
        
        for index in sentences.indices {
            sentencesWordCount[index] = sentences[index].wordCount()
        }
    }
    
}



















extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func wordCount() -> Int {
        return tokenize().count
    }
    
    func tokenize() -> [String] {
        return self.components(separatedBy:CharacterSet.whitespaces).filter({!($0.isEmpty)})
    }
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func removingCharacters(inCharacterSet forbiddenCharacters:CharacterSet) -> String
    {
        var filteredString = self
        while true {
            if let forbiddenCharRange = filteredString.rangeOfCharacter(from: forbiddenCharacters)  {
                filteredString.removeSubrange(forbiddenCharRange)
            }
            else {
                break
            }
        }
        
        return filteredString
    }
}
