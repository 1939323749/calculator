//
//  HistoryView.swift
//  calculator
//
//  Created by mba on 2023/10/10.
//

import SwiftUI
import TipKit
import SwiftData

struct CopyToPasteboardTip:Tip{
    var title: Text=Text("Copy to pasteboard")
    var message: Text?=Text("Press expression to calculate, press result to copy to pasteboard.")
}

struct HistoryView: View {
    var count:Int = 0
    var modelContext:ModelContext
    @Query var results:[Result]
    @Binding var displayText:String
    
    var body: some View {
        NavigationSplitView{
            VStack{
                if results.count==0{
                    Image(systemName: "doc.questionmark")
                        .imageScale(.large)
                    Text("History is empty.")
                        .font(.footnote)
                }else{
                    List{
                        ForEach(results){ result in
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
                        }
                        .onDelete(perform: deleteResult)
                    }
                    .padding([.top,.bottom],10)
                    Spacer()
                    Text("Tips: Press expression to calculate, press result to copy to pasteboard.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.gray)
                        .font(.footnote)
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Text("History")
                        .bold()
                        .font(.title)
                        .foregroundStyle(LinearGradient(colors: [Color.green,Color.blue], startPoint: .bottomLeading, endPoint: .topTrailing))
                }
                ToolbarItem(placement: .topBarTrailing){
                    EditButton()
                }
            }
        }detail: {
            Text("History")
        }
    }
    
    func deleteResult(offsets:IndexSet){
        withAnimation{
            for index in offsets{
                modelContext.delete(results[index])
            }
        }
    }
}
