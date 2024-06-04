//
//  LuxMeterReference.swift
//  Future of Fit
//
//  Created by Seth Schofill on 3/3/24.
//


import SwiftUI
import StoreKit

struct LuxMeterReference: Identifiable {
    let reference: String
    let value: String
    let id = UUID()
}
// References for chart.
let references = [
    LuxMeterReference(reference: "Too dark to run outdoors, consider wearing lights or waiting for more daylight before running", value: "< 400"),
    LuxMeterReference(reference: "Minimal light, run with caution of surroundings.", value: "400 - 5,000"),
    LuxMeterReference(reference: "Full daylight, enjoy your run!", value: "5,000 - 25,000"),
    LuxMeterReference(reference: "Direct sunlight, consider wearing sunglasses to avoid glare, or run at a later time.", value: "25,000 - 100,000")
]

struct ReferenceView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        
        if horizontalSizeClass == .compact{
            HStack {
                List(references) {
                    Text(String("\($0.reference):\t \($0.value) Lux"))
                }
            }
        } else {
            Table(references) {
                TableColumn("Reference", value: \.reference)
                TableColumn("Value", value: \.value)
            }
        }
    }
}
