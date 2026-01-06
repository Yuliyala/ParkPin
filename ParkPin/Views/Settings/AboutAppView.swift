import SwiftUI
import WebKit

struct WebViewScreen: View {
    let url: URL
    @Binding var showTabBar: Bool
    
    init(url: URL, showTabBar: Binding<Bool> = .constant(true)) {
        self.url = url
        self._showTabBar = showTabBar
    }
    
    var body: some View {
        WebView(url: url)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(false)
            .onAppear {
                showTabBar = false
            }
            .onDisappear {
                showTabBar = true
            }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

typealias AboutAppView = WebViewScreen


