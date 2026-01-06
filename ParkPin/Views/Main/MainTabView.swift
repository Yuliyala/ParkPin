import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showTabBar = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    ParkingView(showTabBar: $showTabBar)
                case 1:
                    TimerView(showTabBar: $showTabBar)
                        .onAppear {
                            showTabBar = true
                        }
                case 2:
                    NotesView(showTabBar: $showTabBar, selectedTab: $selectedTab)
                case 3:
                    SettingsView(showTabBar: $showTabBar)
                        .onAppear {
                            showTabBar = true
                        }
                default:
                    ParkingView(showTabBar: $showTabBar)
                }
            }
            
            if showTabBar {
                CustomTabView(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

