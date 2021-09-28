
import Firebase

class FirebaseEventsService {
    
    ///チュートリアル開始イベント
    static func tutorialBegin() {
        DispatchQueue.main.async {
            Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: nil)
        }
    }
    
    ///チュートリアル終了イベント
    static func tutorialComplete() {
        DispatchQueue.main.async {
            Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: nil)
        }
    }
    
    ///AR素材ダウンロードイベント
    static func ARDownloadEvent(){
        DispatchQueue.main.async {
            Analytics.logEvent(AnalyticsEventSearch, parameters: [
                AnalyticsParameterSearchTerm: "AR素材ダウンロード"
            ])
        }
    }
    
    ///クイズの正誤判定イベント
    static func quizSelect(isCorrect: Bool, quizNumber: Int, selectedNumber: Int){
        if isCorrect{
            DispatchQueue.main.async {
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterContentType: "Q\(quizNumber)_correct",
                    AnalyticsParameterContent: selectedNumber
                ])
            }
        }else{
            DispatchQueue.main.async {
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterContentType: "Q\(quizNumber)_incorrect",
                    AnalyticsParameterContent: selectedNumber
                ])
            }
        }
    }
    
    ///結果イベント
    static func result(scoreData: [Int], score: Int){
        let data = scoreData.map({ (value: Int) -> String in
            return "\(value)"
        }).joined(separator: ",").dropFirst(2)
        
        DispatchQueue.main.async {
            Analytics.logEvent(AnalyticsEventEarnVirtualCurrency, parameters: [
                AnalyticsParameterValue: score,
                AnalyticsParameterVirtualCurrencyName: data
            ])
        }
    }
    
}
