import SwiftUI

struct DeleteAlertView: View {
    let title: String
    let message: String
    let onDelete: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.custom("FontdinerSwanky", size: 35))
                .foregroundColor(.white)
            
            Text(message)
                .font(.custom("Montserrat-ExtraBold", size: 20))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            HStack(spacing: 20) {
                Button(action: onDismiss) {
                    Text("Cancel")
                        .font(.custom("Montserrat-ExtraBold", size: 20))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: onDelete) {
                    Text("Clear")
                        .font(.custom("Montserrat-ExtraBold", size: 20))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(Color(hex: "6A6361"))
        .cornerRadius(29)
        .overlay(
            RoundedRectangle(cornerRadius: 29)
                .stroke(Color(hex: "5B5B5A"), lineWidth: 3)
        )
        .padding(.horizontal, 32)
    }
}


