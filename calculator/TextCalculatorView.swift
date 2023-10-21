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
import SwiftData

struct StartLiveActivityTip:Tip{
    var title: Text=Text("Try Live Activity")
    var message: Text?=Text("Press to toggle live activity.")
}

struct TextCalculatorView: View {
    var modelContext:ModelContext
    @Query var results:[Result]
    @Binding var activity :Activity<ResultAttributes>?
    
    @State private var displayText=""
    @State private var inputText = ""
    @State private var isDynamicIslandActive=false
    @FocusState private var isInputting:Bool

    var body: some View {
        NavigationSplitView{
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
                .focused($isInputting)
                Button("Calculate",action: calculateText)
                    .buttonStyle(BorderedButtonStyle())
            }
            .toolbar{
                ToolbarItem(placement:.topBarLeading){
                    TopbarItemLeading()
                }
                ToolbarItem(placement:.topBarTrailing){
                    Button(
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
                }
            }
        }detail: {
            Text("Text calculator")
        }
    }
    func calculateText()->Void{
        isInputting.toggle()
        inputText=inputText.lowercased()
        let expression=AnyExpression(inputText)
        var result:Double=0
        do{
            result = try expression.evaluate()
            if String(result).hasSuffix(".0"){
                modelContext.insert(Result(expression: inputText, result:String(result).replacingOccurrences(of: ".0", with: "")))
//                results.append(Result(expression: inputText, result:String(result).replacingOccurrences(of: ".0", with: "")))
                displayText=String(result).replacingOccurrences(of: ".0", with: "")
            }else{
                modelContext.insert(Result(expression: inputText, result:String(result)))
//                results.append(Result(expression: inputText, result:String(result)))
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

struct TopbarItemLeading:View {
    var body: some View {
        Text("Input")
            .font(.title)
            .bold()
            .foregroundStyle(LinearGradient(colors: [Color.red,Color.green], startPoint: .topLeading, endPoint: .bottomTrailing))
            .padding(.leading)
    }
}

#Preview{
    @Environment(\.modelContext) var modelContext
    @State var activity :Activity<ResultAttributes>?=nil
    return TextCalculatorView(modelContext: modelContext, activity: $activity)
}
