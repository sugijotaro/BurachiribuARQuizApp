
import Firebase

class FirebaseEventsService {
    
    ///チュートリアル開始イベント
    static func tutorialBegin() {
        print("チュートリアル開始イベント")
        DispatchQueue.main.async {
            Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: nil)
        }
    }
    
    ///チュートリアル終了イベント
    static func tutorialComplete() {
        print("チュートリアル終了イベント")
        DispatchQueue.main.async {
            Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: nil)
        }
    }
    
    ///AR素材ダウンロードイベント
    static func ARDownloadEvent(){
        print("AR素材ダウンロードイベント")
        DispatchQueue.main.async {
            Analytics.logEvent(AnalyticsEventSearch, parameters: [
                AnalyticsParameterSearchTerm: "AR素材ダウンロード"
            ])
        }
    }
    
    ///クイズの正誤判定イベント
    static func quizSelect(isCorrect: Bool, quizNumber: Int, selectedNumber: Int){
        print("クイズの正誤判定イベント")
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
    static func result(resultBoolArray: [Bool], score: Int){
        print("結果イベント")
        DispatchQueue.main.async {
            Analytics.logEvent(AnalyticsEventEarnVirtualCurrency, parameters: [
                AnalyticsParameterValue: score,
                AnalyticsParameterVirtualCurrencyName: resultBoolArray
            ])
        }
    }
    
}
