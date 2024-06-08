//
//  GaugeTest.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 25/05/24.
//

import SwiftUI

struct LabeledGauge: View {
    @Binding var current: Double
    @State private var minValue = 0.0
    @State private var maxValue = 999.0


    var body: some View {
        Gauge(value: current, in: minValue...maxValue) {
            Text("BPM")
        } currentValueLabel: {
            Text("\(Int(current))")
        } minimumValueLabel: {
            Text("\(Int(minValue))")
        } maximumValueLabel: {
            Text("\(Int(maxValue))")
        }
        .gaugeStyle(SpeedometerGaugeStyle())
    }
}

struct SpeedometerGaugeStyle: GaugeStyle {
    private var purpleGradient = LinearGradient(gradient: Gradient(colors: [ Color(red: 207/255, green: 150/255, blue: 207/255), Color(red: 107/255, green: 116/255, blue: 179/255) ]), startPoint: .trailing, endPoint: .leading)
 
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
 
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .foregroundColor(.gray)
                .rotationEffect(.degrees(135))
 
            Circle()
                .trim(from: 0, to: 0.75 * configuration.value)
                .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round))
                .foregroundColor(.green)
                .rotationEffect(.degrees(135))
 
//            Circle()
//                .trim(from: 0, to: 0.75)
//                .stroke(Color.black, style: StrokeStyle(lineWidth: 10, lineCap: .butt, lineJoin: .round, dash: [1, 34], dashPhase: 0.0))
//                .rotationEffect(.degrees(135))
 
            VStack {
                Spacer()
                configuration.currentValueLabel
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
 
        }
        .frame(width: 300, height: 300)
 
    }
 
}

#Preview{
    LabeledGauge(current: .constant(800))
}
