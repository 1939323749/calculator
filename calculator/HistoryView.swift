//
//  HistoryView.swift
//  calculator
//
//  Created by mba on 2023/10/10.
//

import SwiftUI
import TipKit

struct CopyToPasteboardTip:Tip{
    var title: Text=Text("Copy to pasteboard")
    var message: Text?=Text("Press expression to calculate, press result to copy to pasteboard.")
}

struct HistoryView: View {
    var count:Int = 0
    
    @Binding var results : [Result]
    @Binding var displayText:String
    
    var body: some View {
        VStack{
            Text("History")
                .bold()
                .padding(.top,50)
                .font(.title)
                .foregroundStyle(LinearGradient(colors: [Color.green,Color.blue], startPoint: .bottomLeading, endPoint: .topTrailing))
            Spacer()
            List(results,id: \.self){result in
                HStack{
                    Text(result.expression)
                        .onTapGesture {
                            displayText=result.expression
                    }
                    Spacer()
                    Text(result.result).padding(.trailing,20)
                        .onTapGesture{
                            UIPasteboard.general.string=result.result
                        }
                        .popoverTip(CopyToPasteboardTip())

                }
            }.padding([.top,.bottom],10)
            Spacer()
            Text("Tips: Press expression to calculate, press result to copy to pasteboard.")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.gray)
                .font(.footnote)
        }
    }
}
