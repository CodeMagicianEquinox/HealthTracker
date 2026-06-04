//
//  ContentView.swift
//  HealthTracker Watch App
//
//  Created by Tim Terrance on 6/1/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthViewModel = HealthViewModel()
    
    var body: some View {
        NavigationStack {
            MainDashboardView(healthviewModel: healthViewModel)
            
        }
        .onAppear {
            //refresh current daily totals
            healthViewModel.refreshDailyTotals()
        }
    }
}

#Preview {
    ContentView()
}
