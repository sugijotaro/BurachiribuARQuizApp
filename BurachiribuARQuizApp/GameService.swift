
import Foundation

let correctAnswer = [3,2,3,1,3,4,2,4,2,3]


class GameService {
    
    struct GameScore {
        //    let userSelectedNumberQ1: Int
        
        
    }
    
    static func isCorrect(quizNumber: Int, userSelectedNumber: Int) -> Bool{
        return userSelectedNumber == correctAnswer[quizNumber-1]
    }
    
    func resetScore(){
        for i in 1...10{
            UserDefaults(suiteName: "group.com.burachiribu")!.set(nil, forKey: "Q\(i)score")
        }
    }
    
    func recordScore(isCorrect: Bool, quizNumber: Int){
        UserDefaults(suiteName: "group.com.burachiribu")!.set(isCorrect, forKey: "Q\(quizNumber)score")
    }
    
}
