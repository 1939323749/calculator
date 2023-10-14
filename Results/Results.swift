//
//  Results.swift
//  Results
//
//  Created by mba on 2023/10/14.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ResultWidget:Widget{
    var body: some WidgetConfiguration{
        ActivityConfiguration(for: ResultAttributes.self){context in
            ResultWidgetView(context: context)
        }dynamicIsland: {context in
            DynamicIsland{
                DynamicIslandExpandedRegion(.center){
                    Text(context.state.result)
                        .font(.title)
                    Text(context.state.expression)
                        .font(.subheadline)
                }
            }compactLeading: {
                Image(systemName: "macpro.gen3.server")
            }compactTrailing: {
                
            }minimal: {
                
            }
        }
    }
}

struct ResultWidgetView:View {
    let context:ActivityViewContext<ResultAttributes>
    var body: some View {
        Text(context.state.result)
            .font(.title)
        Text(context.state.expression)
            .font(.subheadline)
    }
}
