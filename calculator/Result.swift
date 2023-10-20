//
//  Item.swift
//  calculator
//
//  Created by mba on 2023/10/10.
//

import Foundation
import SwiftData

@Model
class Result{
    var expression:String
    var result:String
    
    init(expression:String,result:String){
        self.expression=expression
        self.result=result
    }
}
