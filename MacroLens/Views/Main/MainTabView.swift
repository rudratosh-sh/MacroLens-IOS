import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
//            // Home Tab
//            HomeView()
//                .tabItem {
//                    Image(systemName: "house.fill")
//                    Text("Home")
//                }
//                .tag(0)
//            
//            // Food Log Tab
//            FoodLogView()
//                .tabItem {
//                    Image(systemName: "fork.knife")
//                    Text("Log Food")
//                }
//                .tag(1)
            
            // Progress Tab
            ProgressView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
                .tag(0)
            
            // Recipes Tab
//            RecipesView()
//                .tabItem {
//                    Image(systemName: "book.fill")
//                    Text("Recipes")
//                }
//                .tag(3)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(1)
        }
        .accentColor(.primaryStart)
    }
}
