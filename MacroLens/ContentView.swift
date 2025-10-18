//
//  ContentView.swift
//  MacroLens
//
//  Path: MacroLens/ContentView.swift
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("MacroLens")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Food Macro Tracking App")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("App is ready to build!")
                .font(.body)
                .foregroundColor(.green)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
