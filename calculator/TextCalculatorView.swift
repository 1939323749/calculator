//
//  TextCalculatorView.swift
//  calculator
//
//  Created by mba on 2023/10/10.
//

import SwiftUI
import Expression
import ActivityKit
import TipKit

struct StartLiveActivityTip:Tip{
    var title: Text=Text("Try Live Activity")
    var message: Text?=Text("Press to toggle live activity.")
}

struct TextCalculatorView: View {
    @Binding var results : [Result]
    
    @State private var displayText=""
    @State private var inputText = ""
    @State private var activity :Activity<ResultAttributes>?=nil
    @State private var isDynamicIslandActive=false

    var body: some View {
        NavigationView{
            VStack{
                Text(displayText)
                TextField("input expression,e.g. 1+1",text: $inputText)
                    .padding([.leading,.trailing],20)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Calculate",action:calculateText)
            }.navigationBarItems(trailing:Button(
                action:{
                    toggleActivity()
                }){
                    if !isDynamicIslandActive{
                        Image(systemName: "wand.and.stars")
                            .popoverTip(StartLiveActivityTip())
                    }else{
                        Image(systemName: "wand.and.stars.inverse")
                            .popoverTip(StartLiveActivityTip())
                    }
                }
            ).navigationTitle("Input")
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
    func toggleActivity(){
        if !isDynamicIslandActive{
            startActivity()
            isDynamicIslandActive=true
        }else{
            stopActivity()
            isDynamicIslandActive=false
        }
    }
    func stopActivity(){
        let state=ResultAttributes.Result(expression: inputText, result: displayText)
        Task{
            let content=ActivityContent(state: state, staleDate: .now)
            await activity?.end(content,dismissalPolicy: .immediate)
        }
    }
    func startActivity(){
        let attributes=ResultAttributes()
        let state=ResultAttributes.Result(expression: inputText, result: displayText)
        let content=ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .second, value: 10, to: Date())!)
        activity=try? Activity<ResultAttributes>.request(attributes: attributes, content: content,pushType: nil)
    }
}
