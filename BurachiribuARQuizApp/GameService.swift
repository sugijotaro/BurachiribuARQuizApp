
import Foundation

let correctAnswer = [3,2,3,1,3,4,2,4,2,3]


class GameService {
    
    struct GameScore {
        //    let userSelectedNumberQ1: Int
        
        
    }
    
    static func isCorrect(quizNumber: Int, userSelectedNumber: Int) -> Bool{
        return userSelectedNumber == correctAnswer[quizNumber-1]
    }
    
    static func resetScore(){
        for i in 1...10{
            UserDefaults(suiteName: "group.com.burachiribu")!.set(nil, forKey: "Q\(i)score")
        }
    }
    
    static func recordScore(isCorrect: Bool, quizNumber: Int){
        UserDefaults(suiteName: "group.com.burachiribu")!.set(isCorrect, forKey: "Q\(quizNumber)score")
    }
    
    static func resultScoreInt() -> Int {
        var score = 0
        for i in 1...10{
            if UserDefaults(suiteName: "group.com.burachiribu")!.bool(forKey: "Q\(i)score") ?? false {
                score += 1
            }
        }
        return score
    }
    
    static func resultBoolArray() -> [Bool] {
        var resultArray: [Bool] = []
        for i in 1...10{
            if UserDefaults(suiteName: "group.com.burachiribu")!.bool(forKey: "Q\(i)score") ?? false {
                resultArray += [true]
            }else{
                resultArray += [false]
            }
        }
        return resultArray
    }
    
    static func resultName(score: Int) -> String{
        if score > 9{
            return "えいえんのブラチリブ部員"
        } else if score > 7{
            return "カリスマブラチリブ部員"
        } else if score > 5{
            return "スーパーブラチリブ部員"
        } else if score > 3{
            return "まことのブラチリブ部員"
        } else {
            return "ふつうのブラチリブ部員"
        }
    }
}
