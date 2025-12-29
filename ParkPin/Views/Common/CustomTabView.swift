import SwiftUI

struct CustomTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                image: selectedTab == 0 ? "tab1on" : "tab1",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            TabButton(
                image: selectedTab == 1 ? "tab2On" : "tab2",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            TabButton(
                image: selectedTab == 2 ? "tab3On" : "tab3",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
            
            TabButton(
                image: selectedTab == 3 ? "tab4On" : "tab4",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
        }
        .frame(height: 100)
        .background(Color.clear)
    }
}

struct TabButton: View {
    let image: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 85, height: 100)
        }
    }
}
