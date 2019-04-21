//
//  IntentHandler.swift
//  MoviesIntent
//
//  Created by Spock on 2019/4/14.
//  Copyright © 2019 Spock. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        
        guard intent is MoviesIntent else {
            return self
        }
        return MoviesIntentHandler()
    }
}

class MoviesIntentHandler: NSObject, MoviesIntentHandling {
    
    func handle(intent: MoviesIntent, completion: @escaping (MoviesIntentResponse) -> Void) {
        guard let endpoint = intent.endpoint else {
            // 這邊的 failure 就是 Intent 裡 Response 的設 failure 設定
            completion(MoviesIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        // 這邊的 success 就是 Intent 裡 Response 的設 success 設定
        completion(MoviesIntentResponse.success(type: endpoint))
    }
}
