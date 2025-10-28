//
//  SafariView.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 4/18/25.
//


import SwiftUI
import WebKit

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)

        let container = WebViewContainer(webView: webView, url: url, isPresented: $isPresented)
        return UIHostingController(rootView: container)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


struct WebViewContainer: View {
    let webView: WKWebView
    let url: URL
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Dismiss (X) Button
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .padding(8)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Shortened URL
                Text(url.host ?? url.absoluteString)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer()

                // Reload Button
                Button {
                    webView.reload()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .padding(8)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                // Open in External Browser
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Image(systemName: "safari")
                        .padding(8)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)

            Divider()

            WebView(webView: webView)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}



struct WebView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
