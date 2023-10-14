//
//  ResultAttributes.swift
//  calculator
//
//  Created by mba on 2023/10/14.
//

import ActivityKit

struct ResultAttributes:ActivityAttributes{
    public typealias Result = ContentState
    
    public struct ContentState:Codable,Hashable{
        var expression:String
        var result:String
    }
}
