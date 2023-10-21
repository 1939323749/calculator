//
//  ContentView.swift
//  calculator
//
//  Created by mba on 2023/10/10.
//

import ActivityKit
import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var activity :Activity<ResultAttributes>?=nil
    @Environment(\.modelContext) private var modelContext
    @Query  var results:[Result]
    @State private var displayText="0"
    
    var body: some View {
        VStack{
            GeometryReader{geometry in
                NavigationView{
                    HStack{
                        Button(action:{}){
                            Text("hello")
                        }.padding(.leading)
                    }
                }.frame(height:geometry.size.height*0.1)
                Spacer()
                TabView{
                    CalculatorView(displayText: $displayText, activity: $activity, modelContext: modelContext).tabItem{
                        Image(systemName: "keyboard")
                        Text("Cal")
                    }
                    TextCalculatorView(modelContext: modelContext, activity: $activity).tabItem{
                        Image(systemName: "textformat.12")
                        Text("Input")
                    }
                    HistoryView(modelContext:modelContext,displayText: $displayText).tabItem{
                        Image(systemName: "pencil.and.ruler")
                        Text("History")
                    }
                }
            }
        }
    }
}

