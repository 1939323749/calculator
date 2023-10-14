//
//  CalculatorView.swift
//  calculator
//
//  Created by mba on 2023/10/10.
//

import SwiftUI
import Expression
import TipKit

struct AddToInputTip:Tip{
    var title: Text=Text("Add result to input area")
    var message: Text?=Text("Press result to add to input area.")
    var image: Image?=Image(systemName: "doc.on.clipboard")
}

struct CalculatorView: View {
    @Binding var displayText:String
    
    @State private var memText = ["0"]
    @State private var lastExp = "0"
    @State private var index = 0
    @State private var mode = "normal"    
    @State private var isPresented = false
    
    
    @Binding var results : [Result]
    var body: some View {
        VStack(spacing:12){
            Spacer()
            HStack{
                Spacer()
                Text(displayText).font(.largeTitle).padding(.trailing)
            }.padding()
            Spacer()
            HStack(spacing:16){
                CalculatorButton(text: "(", action: appendText)
                CalculatorButton(text: ")", action: appendText)
                CalculatorButton(text: "%", action: appendText)
                Button(action: {
                    isPresented=true
                }){
                    Text("Mode")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .background(Color.orange)
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                }.sheet(isPresented: $isPresented){
                    AdvancedMode(displayText: $displayText, memText: $memText, index: $index,results: $results)
                }
            }
            HStack(spacing:16){
                CalculatorButton(text: "C",action: emptyText)
                CalculatorButton(text: "Back",action: deleteText)
                CalculatorButton(text: "Redo",action: redoText)
                CalculatorButton(text: "Undo",action: undoText)
            }
            HStack(spacing:16){
                CalculatorButton(text: "1",action: appendText)
                CalculatorButton(text: "2",action: appendText)
                CalculatorButton(text: "3",action: appendText)
                CalculatorButton(text: "+", action: appendText)
            }
            HStack(spacing:16){
                CalculatorButton(text: "4",action: appendText)
                CalculatorButton(text: "5",action: appendText)
                CalculatorButton(text: "6",action: appendText)
                CalculatorButton(text: "-", action: appendText)
            }
            HStack(spacing:16){
                CalculatorButton(text: "7",action: appendText)
                CalculatorButton(text: "8",action: appendText)
                CalculatorButton(text: "9",action: appendText)
                CalculatorButton(text: "*",action: appendText)
            }
            HStack(spacing:16){
                CalculatorButton(text: "0",action: appendText)
                CalculatorButton(text: ".",action: appendText)
                CalculatorButton(text: "/",action: appendText)
                CalculatorButton(text: "=",action: calculateText)
            }
            }.padding()
        }
    func appendText(text:String)->Void{
        if displayText.elementsEqual("Error") {
            displayText=""
            displayText.append(text)
        }
        if (displayText=="0")&&(!text.elementsEqual(".")){
            displayText=text
            return
        }
        memText.append(displayText)
        index=memText.count-1
        displayText.append(text)
    }
    func emptyText(text:String)->Void{
        displayText="0"
    }
    func deleteText(text:String)->Void{
        if !(displayText.count==1){
            displayText.removeLast()
        }else{
            displayText="0"
        }
    }
    func calculateText(text:String)->Void{
        let expression = AnyExpression(displayText)
        memText.append(displayText)
        var result :Double = 0.0
        do {
            result = try expression.evaluate()
            if String(result).hasSuffix(".0"){
                results.append(Result(expression: displayText, result: String(result).replacingOccurrences(of: ".0", with: "")))
                displayText=String(result).replacingOccurrences(of: ".0", with: "")
            }else{
                results.append(Result(expression: displayText, result: String(result)))
                displayText=String(result)
            }
            lastExp=displayText
        }catch{
            let alert = UIAlertController(title: "Error", message: "Press redo to back to your last input", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true, completion: nil)
            }
            lastExp=displayText
            displayText="Error"
        }
    }
    func calculateText(text:String)->String{
        let expression = AnyExpression(displayText)
        var result :Double = 0.0
        var res=""
        do {
            result = try expression.evaluate()
            res=String(result)
        }catch{
            res="Error"
        }
        return res
    }
    func redoText(text:String)->Void{
        displayText=lastExp
    }
    func undoText(text:String)->Void{
        if index>0 {
            displayText=memText[index]
            index-=1
        }else if index==0{
            displayText=memText[0]
        }
    }
}

struct CalculatorButton: View{
    let text: String
    let action: (String)->Void
    
    @State private var isButtonActive = false
    var body: some View{
        Button(action: {
            self.action(self.text)
            self.isButtonActive = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isButtonActive = false
            }
        }) {
            if text.elementsEqual("=") {
                Text(text)
                    .font(.title)
                    .frame(width: 80, height: 80)
                    .background(isButtonActive ? Color.green : Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
            } else {
                Text(text)
                    .font(.title)
                    .frame(width: 80, height: 80)
                    .background(isButtonActive ? Color.green : Color.gray)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
            }
        }
    }
}

struct AdvancedMode:View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var displayText:String
    @Binding var memText:[String]
    @Binding var index:Int
    @Binding var results:[Result]
    
    @State private var isResultPressed=false
    
    var body: some View {
        Spacer()
        VStack(spacing:12){
            Spacer()
            List(results.suffix(5),id: \.self){result in
                HStack{
                    Text(result.expression)
                    Spacer()
                    Text(result.result).padding(.trailing,20)
                        .onTapGesture {
                            appendText(text: result.result)
                            isResultPressed=true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isResultPressed = false
                            }
                        }.foregroundColor(Color.blue)
                        .popoverTip(AddToInputTip())
                }
            }.padding([.top,.bottom],10)
            if results.count>0 && !isResultPressed{
                Text("Tip: Press result to add to input area.")
                    .foregroundStyle(Color.gray)
                    .font(.footnote)
            }
            if isResultPressed {
                Text("Result added to input area.")
                    .foregroundStyle(Color.gray)
                    .font(.footnote)
            }
            HStack(spacing:16){
                CalculatorButton(text: "pi", action: appendText)
                CalculatorButton(text: "pow", action: appendText)
                CalculatorButton(text: ",", action: appendText)
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("Close")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                }
            }
            HStack(spacing:16){
                CalculatorButton(text: "sin", action: appendText)
                CalculatorButton(text: "cos", action: appendText)
                CalculatorButton(text: "tan", action: appendText)
                CalculatorButton(text: "sqrt", action: appendText)
            }
            HStack(spacing:16){
                CalculatorButton(text: "asin", action: appendText)
                CalculatorButton(text: "acos", action: appendText)
                CalculatorButton(text: "atan", action: appendText)
                CalculatorButton(text: "log", action: appendText)
            }
            HStack(spacing:16){
                CalculatorButton(text: "floor", action: appendText)
                CalculatorButton(text: "ceil", action: appendText)
                CalculatorButton(text: "round", action: appendText)
                CalculatorButton(text: "abs", action: appendText)
            }
            Spacer()
        }
    }
    func appendText(text:String)->Void{
        if displayText.elementsEqual("Error") {
            displayText=""
            displayText.append(text)
        }
        if (displayText=="0")&&(!text.elementsEqual(".")){
            displayText=text
            return
        }
        memText.append(displayText)
        index=memText.count-1
        displayText.append(text)
    }
}
