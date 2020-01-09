import Foundation

class LanguageAnalysis {
    private static func wordsIn(text: String) -> [String]{
        
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = text.components(separatedBy: chararacterSet)
        
        return components.filter { !$0.isEmpty }
        
    }
    
    private static func sentencesIn(text: String) -> [String] {
        
        if (!text.contains(".") && !text.contains("?") && !text.contains("!")){
            return [text]
        }
        
        let charset = CharacterSet(charactersIn: ".?!")
        
        return text.components(separatedBy: charset)
        
    }
    
    private static func syllablesIn(word: String) -> Double{
        return Double(SyllableCounter.shared.count(word: word))
    }
    
    private static func languageOf(text: String) -> String{
        
        if let language = NSLinguisticTagger.dominantLanguage(for: text) {
            return language
        } else {
            return ""
        }
    }
    
    private static func syllablesIn(text: String) -> Double {
        
        var count = 0.0
        let words = self.wordsIn(text: text)
        
        for word in words {
            count += self.syllablesIn(word: word)
        }
        
        return count
    }
    
    private static func charactersIn(text: String) -> Double {
        return Double(text.filter{$0.isLetter}.count)
    }
    
    /**
     
     Flesch-Kincaid reading ease formula: 206.835 - 1.015 x (words/sentences) - 84.6 x (syllables/words)
     
     Flesch-Kincaid reading ease, is based on a ranking scale of 0-100, and the higher your score, the better. Low scores indicate text that is complicated to understand.

     For most business writing, a score of 65 is a good target, and scores between 60 and 80 should generally be understood by 12 to 15 year olds.
     
     - >90: A1
     - 90-80: A2
     - 80-70: B1
     - 70-60: B2
     - 60-50: C1
     - 50-0: C2
     
     */
    static func flesh_kincaid_reading_ease(text: String) -> Double{
        
        let words_per_sentence = Double(Double(wordsIn(text: text).count) / Double(sentencesIn(text: text).count - 1))
        let syllables_per_word = Double(syllablesIn(text: text) / Double(wordsIn(text: text).count))
        
        return 206.835 - 1.015 * words_per_sentence - 84.6 * syllables_per_word
    }
    
    /**
     
     Flesch-Kincaid grade level formula: 0.39 x (words/sentences) + 11.8 x (syllables/words) - 15.59.
     
     Flesch-Kincaid grade level, tells you the American school grade you would need to be in to comprehend the material on the page.
     
     As a measure, most of your writing should be able to be understood by students in seventh grade.

     For example, The Huffington Post’s website has an average grade level of about 7, meaning that it should be easily understood by 12 to 13 year olds.
     
     */
    static func flesh_kincaid_grade_level(text: String) -> Double {
        
        let words_per_sentence = Double(Double(wordsIn(text: text).count) / Double(sentencesIn(text: text).count - 1))
        let syllables_per_word = Double(syllablesIn(text: text) / Double(wordsIn(text: text).count))
        
        return 0.39 * words_per_sentence + 11.8 * syllables_per_word - 15.59
        
    }
    
    /**
     
     Developed by linguists Meri Coleman and T.L. Liau, the Coleman Liau Index is designed to evaluate the U.S. grade level necessary to understand the text.

     Instead of syllables per word and sentence lengths, the Coleman Liau Index relies on characters and uses computerized assessments to understand characters more easily and accurately.

     Coleman and Liau developed the formula to automatically calculate writing samples instead of manually coding the text. Unlike syllable-based readability indicators, the Coleman Liau Index does not require users to take into account the syllable-counts in the text. Therefore, passages can easily be scanned into a word processor to calculate the Coleman Liau Index.

     According to Coleman and Liau, word length in letters is a better predictor of readability than word length in syllables.

     Coleman Liau Index formula: 5.89 x (characters/words) - 0.3 x (sentences/words) – 15.8.
     
     */
    
    static func coleman_liau_index(text: String) -> Double {
        
        let characters_per_word = charactersIn(text: text) / Double(wordsIn(text: text).count)
        let words_per_sentence = Double(Double(sentencesIn(text: text).count - 1) / Double(wordsIn(text: text).count))
        
        return 5.89 * characters_per_word - 0.3 * words_per_sentence - 15.8
        
    }
    
    /**
     
     The automated readability index is a readability test designed to measure the how easy your text is to understand. Similar to other popular readability tools, the ARI gives you an estimate of the U.S. grade level necessary to comprehend a passage of text.

     For example, if your ARI score is 10, then your text should be understood by high school students.

     ARI is derived from ratios that represent word difficulty (number of letters per word) and sentence difficulty (number of words per sentence).

     Most readability scores consist of two factors. The first factor relates to sentence structure, and typically measures the average number of words per sentence. Readability indices also take into account word structure, and are generally based on the average number of syllables per word or the proportion of easy words determined by referencing a word list.

     Automated Readability Index formula: 4.71 x (characters/words) + 0.5 x (words/sentences) - 21.43.
     
     */
    
    static func automated_readability_index(text: String) -> Double {

        let characters_per_word = charactersIn(text: text) / Double(wordsIn(text: text).count)
        let words_per_sentence = Double(Double(wordsIn(text: text).count) / Double(sentencesIn(text: text).count - 1))

        return 4.71 * characters_per_word + 0.5 * words_per_sentence - 21.43
    }
    
    /**
     
     The SMOG grade is a measure of readability that estimates the years of education needed to understand a piece of writing. SMOG is an acronym for Simple Measure of Gobbledygook.

     SMOG is widely used, particularly for checking health messages. The SMOG grade yields a 0.985 correlation with a standard error of 1.5159 grades with the grades of readers who had 100% comprehension of test materials.

     The formula for calculating the SMOG grade was developed by G. Harry McLaughlin as a more accurate and more easily calculated substitute for the Gunning fog index and published in 1969. To make calculating a text's readability as simple as possible an approximate formula was also given — count the words of three or more syllables in three 10-sentence samples, estimate the count's square root (from the nearest perfect square), and add 3.

     A 2010 study published in the Journal of the Royal College of Physicians of Edinburgh stated that “SMOG should be the preferred measure of readability when evaluating consumer-oriented healthcare material.” The study found that “The Flesch-Kincaid formula significantly underestimated reading difficulty compared with the gold standard SMOG formula.”

     Applying SMOG to other languages lacks statistical validity.
     
     */
    
    static func smog_index(text: String) -> Double {
        
        var polysyllables = 0.0
        let sentences = sentencesIn(text: text)
        
        for sentence in sentences {
            
            let words = wordsIn(text: sentence)
            
            for word in words {
                
                if syllablesIn(word: word) >= 3 {
                    polysyllables += 1
                }
                
            }
        }
        
        let root = sqrt(polysyllables * (30 / Double(sentences.count - 1)))
        
        return 1.0430 * root + 3.1291
        
    }
    
    /**
     Step 1: Select a sample text of 150 words.

     Step 2: Count N, i.e., the number of single-syllable words in the sample text.

     Step 3: Divide N by 10.

     Step 4: Subtract the result obtained in Step 3 from 20.

     The mathematical formula is:

     GL = 20 – (N/10)

     Where,

     GL = Grade Level

     N = Number of monosyllabic words in the sample text.
     */
    
    static func forcast(text: String) -> Double {
        
        var monosyllables = 0.0
        var word_count = 1
        
        for sentence in sentencesIn(text: text) {
            for word in wordsIn(text: sentence) {
                
                if word_count == 150 {
                    return 20.0 - (monosyllables / 10)
                }
                
                if syllablesIn(word: word) == 1 {
                    monosyllables += 1
                }
                
                word_count += 1
            }
        }
        
        return 1.0
    }
    
    /**
     Step 1: Select a sample passage of around 100 words.

     Step 2: Calculate the exact number of words and sentences in the sample passage.

     Step 3: Divide the number of words with the number of sentences to arrive at Average Sentence Length (ASL)

     Step 4: Apply the formula:

     GL = 0.0778(ASL) + 0.0455(NS) – 2.2029
     
     TO GET THE (NS) VALUE: Divide total number of syllables in the passage into the total number of words. This will give you the average syllable length. Multiply the average syllable length with 0.0455. Then multiply this number with 100. The final number is the number of syllables (NS). (Note: do not multiple this number with .0455 again).
     
     */
    
    static func powers_sumner_kearl(text: String) -> Double {
        
        let words = wordsIn(text: text)
        let words_per_sentence = Double(Double(words.count) / Double(sentencesIn(text: text).count - 1))
        let syllable_per_word = Double(syllablesIn(text: text) / Double(words.count)) * 100
        
        return 0.0778 * words_per_sentence + 0.0455 * syllable_per_word - 2.2029
        
    }
    
    /**
     LIX is a readability measure to calculate the difficulty of reading a foreign text. The Lix Formula was developed by Swedish scholar Carl-Hugo Björnsson. The LIX readability formula is as follows:

     LIX = A/B + (C x 100)/A, where

     A = Number of words
     B = Number of periods (defined by period, colon or capital first letter)
     C = Number of long words (More than 6 letters)
     */
    
    static func lix(text: String) -> Double{
        
        let words = wordsIn(text: text)
        
        let periods = Double(text.filter{$0.isPunctuation}.count)
        var long_words = 0.0
        
        for word in words {
            if word.count >= 6 {
                long_words += 1
            }
        }
        
        long_words = long_words * 100
        
        return Double(words.count) / periods + long_words / Double(words.count)
        
    }
    
    /**
     The formula for Gunning Fog is 0.4 [(words/sentences) + 100 (complex words/words)], where complex words are defined as those containing three or more syllables.

     What is immediately apparent when looking at this calculation is its simplicity compared to some other readability tests.

     For example, for the Flesch Reading Ease test, the numbers within the formula are rounded up to three decimal places 206.835-1.015 (words/sentences) - .836 (syllables/words).

     At the time that the index was created, the ease of calculation of the Gunning Fog score would have been of particular importance as the calculation would have been done by hand.

     Created as a human algorithm, the Gunning Fog formula could be followed and applied by anybody, no equipment necessary.

     Even now when readability formulas are typically run on a computer rather than by hand, the simplicity of Gunning Fog’s formula is still highly praised.

     The fact that the Gunning Fog index was designed as a human algorithm does, however, raise a few issues when translating the formula into computerised format. This results in some modifications to the rules of the original version.

     For example, Gunning proposed that the test be conducted on excerpts of 10 sentences of text or around 100 words. Going much beyond this would make for a tiresome job if conducting the calculation by hand.

     However, when a Gunning Fog score is calculated by software such as ReadablePro, the analysis is conducted on the text as a whole, regardless of how many sentences it contains.

     In addition, the index states that proper nouns, familiar jargon, or compound words are not included in the analysis. Also, common suffixes such as -ed, or -ing are not counted as a syllable. So, in the statement Gloria followed her supernatural instinct, only supernatural would count as a complex word.

     In the computer imitation of the formula, proper nouns are ignored if these fall at the beginning of a sentence but not within the lines as the algorithm struggles to detect these instances.

     When it comes to common suffixes such as -ed, the complexity of the English language makes it difficult to machine detect when the -ed at the end of a word is a suffix and when it is not, e.g. mend-ed vs. moped.

     So, while online versions of the Gunning Fog index mirror the basic calculation, necessary adaptations mean that the computerised version is not a perfect copy of the original formula as proposed by Gunning (1944).
     */
    
    static func gunning_fog_index(text: String) -> Double {
        
        let words = wordsIn(text: text)
        let sentences = sentencesIn(text: text)
        var complex_words = 0.0
        
        for word in words {
            if syllablesIn(word: word) >= 3 {
                complex_words += 1
            }
        }
        
        let word_per_sentence = Double(words.count) / Double(sentences.count)
        
        return 0.4 * word_per_sentence + 100 * complex_words / Double(words.count)
        
    }
    
    static func variety(text: String) -> Double {
        
        var index = [String : Int]()
        let words = wordsIn(text: text)
        
        index.reserveCapacity(Int(Double(words.count) * 0.6))
        
        for word in words {
            
            let lowercased_word = word.lowercased()
            
            if let frequency = index[lowercased_word] {
                index[lowercased_word] = frequency + 1
            }else {
                index[lowercased_word] = 1
            }
            
        }
        
        return Double(Double(index.count) / Double(words.count))
        
    }
    
    static func richness(text: String) -> Double {
        
//        var common_words = ""
//
//        let file = "common_words.txt" //this is the file. we will write to and read from it
//
//        if let dir = FileManager.default.contents(atPath: <#T##String#>) {
//
//            let fileURL = dir.appendingPathComponent(file)
//
//            do {
//                common_words = try String(contentsOf: fileURL, encoding: .utf8)
//            }catch {
//            print("Could not open file.")
//            }
//        }
//
//        print(common_words)
        
        return 1.0
    }
}

class SyllableCounter {
  
  // MARK: - Shared instance
  
  static let shared = SyllableCounter()
  
  // MARK: - Private properties
  
  private var addSyllables: [NSRegularExpression]!
  private var subSyllables: [NSRegularExpression]!
  
  private let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
  
  // MARK: - Error enum
  
  private enum SyllableCounterError: Error {
    case badRegex(String)
    case missingExceptionsDataAsset
    case badExceptionsData(String)
  }
  
  // MARK: - Constructors
  
  init() {
    do {
      try populateAddSyllables()
      try populateSubSyllables()
    }
    catch SyllableCounterError.badRegex(let pattern) {
      print("Bad Regex pattern: \(pattern)")
    }
    catch SyllableCounterError.badExceptionsData(let info) {
      print("Problem parsing exceptions dataset: \(info)")
    }
    catch {
      print("An unexpected error occured while initializing the syllable counter.")
    }
  }
  
  // MARK: - Setup
  
  private func populateAddSyllables() throws {
    try addSyllables = buildRegexes(forPatterns: [
      "ia", "riet", "dien", "iu", "io", "ii",
      "[aeiouy]bl$", "mbl$", "tl$", "sl$", "[aeiou]{3}",
      "^mc", "ism$", "(.)(?!\\1)([aeiouy])\\2l$", "[^l]llien", "^coad.",
      "^coag.", "^coal.", "^coax.", "(.)(?!\\1)[gq]ua(.)(?!\\2)[aeiou]", "dnt$",
      "thm$", "ier$", "iest$", "[^aeiou][aeiouy]ing$"])
  }
  
  private func populateSubSyllables() throws {
    try subSyllables = buildRegexes(forPatterns: [
      "cial", "cian", "tia", "cius", "cious",
      "gui", "ion", "iou", "sia$", ".ely$",
      "ves$", "geous$", "gious$", "[^aeiou]eful$", ".red$"])
  }
  
  private func buildRegexes(forPatterns patterns: [String]) throws -> [NSRegularExpression] {
    return try patterns.map { pattern -> NSRegularExpression in
      do {
        let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .anchorsMatchLines])
        return regex
      }
      catch {
        throw SyllableCounterError.badRegex(pattern)
      }
    }
  }
  
  // MARK: - Public methods
  
  func count(word: String) -> Int {
    if word.count <= 1 {
      return word.count
    }
    
    var mutatedWord = word.lowercased(with: Locale(identifier: "en_US")).trimmingCharacters(in: .punctuationCharacters)
    
    if mutatedWord.last == "e" {
      mutatedWord = String(mutatedWord.dropLast())
    }
    
    var count = 0
    var previousIsVowel = false
    
    for character in mutatedWord {
      let isVowel = vowels.contains(character)
      if isVowel && !previousIsVowel {
        count += 1
      }
      previousIsVowel = isVowel
    }
    
    for pattern in addSyllables {
      let matches = pattern.matches(in: mutatedWord, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: mutatedWord.count))
      if !matches.isEmpty {
        count += 1
      }
    }
    
    for pattern in subSyllables {
      let matches = pattern.matches(in: mutatedWord, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: mutatedWord.count))
      if !matches.isEmpty {
        count -= 1
      }
    }
    
    return (count > 0) ? count : 1
  }
  
}

var text = """

“Well, Prince, so Genoa and Lucca are now just family estates of the
Buonapartes. But I warn you, if you don’t tell me that this means war,
if you still try to defend the infamies and horrors perpetrated by that
Antichrist—I really believe he is Antichrist—I will have nothing
more to do with you and you are no longer my friend, no longer my
‘faithful slave,’ as you call yourself! But how do you do? I see I
have frightened you—sit down and tell me all the news.”

"""

LanguageAnalysis.flesh_kincaid_grade_level(text: text)
LanguageAnalysis.flesh_kincaid_reading_ease(text: text)
LanguageAnalysis.coleman_liau_index(text: text)
LanguageAnalysis.automated_readability_index(text: text)
LanguageAnalysis.smog_index(text: text)
LanguageAnalysis.forcast(text: text)
LanguageAnalysis.powers_sumner_kearl(text: text)
LanguageAnalysis.lix(text: text)
LanguageAnalysis.gunning_fog_index(text: text)

LanguageAnalysis.variety(text: text)
LanguageAnalysis.richness(text: text)
