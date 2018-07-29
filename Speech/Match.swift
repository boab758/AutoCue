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
    //    var rawData:String? = nil
    
    private(set) var sentences = [String]()
    
    //could be computed property, but efficiency calls for it to be computed in init()
    private var sentencesWordCount = [Int:Int]()
    
    //myMagicNumbers
    private var min = 0
    private var range = 2
    private var mergeThreshold = 10
    
    
    //assumes non-empty array and only 1 maximum value, could be 2 though
    private func highestProbabilityStringIndex(probabilityArray:[Double]) -> Int {
        return probabilityArray.index(of: probabilityArray.max()!)!
    }
    
    //need to check range limits when range is provided for efficient searching
    func compareStringWithSentences(googleString spokenString:String) -> Int {
        var allPercentages = [Double]()
        for index in min..<(min+range) {
            allPercentages.append(matchPercentage(testString: spokenString.components(separatedBy: CharacterSet.whitespaces), matchAgainstIndex: index))
        }
        let probabilityIndex = highestProbabilityStringIndex(probabilityArray: allPercentages)
        min += probabilityIndex
//        return stringForViewController(index: min)
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
    
    //configuration of script
    private func paragraphToSentence(string s:String) -> [String] {
        var array = s.components(separatedBy: CharacterSet.init(charactersIn: ",.;—")).filter({!($0.isEmpty)})
        var hasSmallFragment = false
        repeat {
            hasSmallFragment = false
            var firstSmallFragment:Int? = nil
            for index in array.indices {
                if array[index].count < mergeThreshold {
                    hasSmallFragment = true
                    firstSmallFragment = index
                }
            }
            if let index = firstSmallFragment {
                if index != 0 {
                    array[index - 1] = array[index - 1] + array[index]
                    array.remove(at: index)
                }
            }
            
        } while hasSmallFragment
        return array
    }
    
    func fakeInit(document:String){
        //REMOVE BELOW FOR TESTING
        str = document
        //REMOVE TOP FOR TESTING
        sentences = paragraphToSentence(string: str)
        for index in sentences.indices {
            sentencesWordCount[index] = sentences[index].components(separatedBy:CharacterSet.whitespaces).count
        }
    }
    
    //unnecessary
    private var str = "Of course, in one sense, the first essential for a man’s being a good citizen is his possession of the home virtues of which we think when we call a man by the emphatic adjective of manly. No man can be a good citizen who is not a good husband and a good father, who is not honest in his dealings with other men and women, faithful to his friends and fearless in the presence of his foes, who has not got a sound heart, a sound mind, and a sound body; exactly as no amount of attention to civil duties will save a nation if the domestic life is undermined, or there is lack of the rude military virtues which alone can assure a country’s position in the world. In a free republic the ideal citizen must be one willing and able to take arms for the defense of the flag, exactly as the ideal citizen must be the father of many healthy children. A race must be strong and vigorous; it must be a race of good fighters and good breeders, else its wisdom will come to naught and its virtue be ineffective; and no sweetness and delicacy, no love for and appreciation of beauty in art or literature, no capacity for building up material prosperity can possibly atone for the lack of the great virile virtues."
}
































extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
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
