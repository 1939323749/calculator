//
//  TextCalculatorView.swift
//  calculator
//
//  Created by mba on 2023/10/10.
//

import SwiftUI
import Expression
struct TextCalculatorView: View {
    @Binding var results : [Result]
    
    @State private var displayText = ""
    @State private var inputText = ""

    var body: some View {
        VStack{
            Text(displayText)
            TextField("input expression,e.g. 1+1",text: $inputText)
                .padding([.leading,.trailing],20)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Calculate",action:calculateText)
        }
    }
    func calculateText()->Void{
        inputText=inputText.lowercased()
        let expression=AnyExpression(inputText)
        var result:Double=0
        do{
            result = try expression.evaluate()
            if String(result).hasSuffix(".0"){
                results.append(Result(expression: inputText, result:String(result).replacingOccurrences(of: ".0", with: "")))
                displayText=String(result).replacingOccurrences(of: ".0", with: "")
            }else{
                results.append(Result(expression: inputText, result:String(result)))
                displayText=String(result)
            }
        }catch{
            displayText="Error"
        }
    }
}
