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
    @Binding var activity :Activity<ResultAttributes>?
    
    @State private var displayText=""
    @State private var inputText = ""
    @State private var isDynamicIslandActive=false

    var body: some View {
        NavigationView{
            VStack{
                if !displayText.elementsEqual("42"){
                    Text(displayText)
                        .font(.title)
                }else{
                    Text("42")
                        .font(.title)
                        .bold()
                        .foregroundStyle(LinearGradient(colors: [.yellow,.purple,.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                TextField("input expression,e.g. 1+1",text: $inputText)
                    .padding([.leading,.trailing],20)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Calculate",action: calculateText)
                    .buttonStyle(BorderedButtonStyle())
            }.navigationBarItems(trailing: Button(
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
            )
            .navigationBarItems(leading:InputNavigationBarItemView())
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
            Task{
                // It's weird that if using `update(using:...)`, xCode warns that this method was deprecated, but is using suggested `update(_:...)`, it's a compile error.
                await activity?.update(using:ResultAttributes.Result(expression: inputText, result: displayText))
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

struct InputNavigationBarItemView:View {
    var body: some View {
        Text("Input")
            .font(.title)
            .bold()
            .foregroundStyle(LinearGradient(colors: [Color.red,Color.green], startPoint: .topLeading, endPoint: .bottomTrailing))
            .padding(.leading)
    }
}
