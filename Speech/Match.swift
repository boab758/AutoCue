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
    private var lowMergeThreshold = 10 // in words
    
    
    //assumes non-empty array and only 1 maximum value, could be 2 though
    private func highestProbabilityStringIndex(probabilityArray:[Double]) -> Int {
        print(probabilityArray)
        return probabilityArray.index(of: probabilityArray.max()!)!
    }
    
    //need to check range limits when range is provided for efficient searching
    func compareStringWithSentences(googleString givenString:String) -> Int {
        print(givenString)
        if givenString.wordCount() < 5 {
            return min
        }
        if givenString.wordCount() > lowMergeThreshold {
            let spokenString = takeLastPartOfString(givenString)
            var allPercentages = [Double]()
            for index in min...(min+1) {
                if index >= (sentences.count - 1) {
                    break
                }
                allPercentages.append(matchPercentage(testString: spokenString.tokenize(), matchAgainstIndex: index))
            }
            let probabilityIndex = highestProbabilityStringIndex(probabilityArray: allPercentages)
            min += probabilityIndex
            return min
        } else {
            let spokenString = givenString
            var allPercentages = [Double]()
            for index in min...(min+1) {
                if index >= (sentences.count - 1) {
                    break
                }
                allPercentages.append(matchPercentage(testString: spokenString.tokenize(), matchAgainstIndex: index))
            }
            let probabilityIndex = highestProbabilityStringIndex(probabilityArray: allPercentages)
            min += probabilityIndex
            return min
        }
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
            print(sentenceTokens)
            print(sentenceTokens.filter({$0.wordCount() < lowMergeThreshold}).count)
            
        } while (sentenceTokens.filter({$0.wordCount() < lowMergeThreshold}).count > 0)
        
        sentenceTokens.append("END OF SPEECH")
        sentences = sentenceTokens
        
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
