#!/bin/bash
# Launch cpbama avatar as a floating window

AVATAR_PATH="$HOME/clawd/cpbama-avatar/mini.html"

# Kill any existing instance
pkill -f "cpbama-avatar" 2>/dev/null

# Create a small Swift app that shows a floating WebView
cat > /tmp/cpbama_float.swift << 'EOF'
import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create floating window
        let windowRect = NSRect(x: 50, y: NSScreen.main!.frame.height - 200, width: 130, height: 160)
        
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // Create WebView
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        webView = WKWebView(frame: window.contentView!.bounds, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        
        let htmlPath = NSString(string: "~/clawd/cpbama-avatar/mini.html").expandingTildeInPath
        let url = URL(fileURLWithPath: htmlPath)
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        
        window.contentView = webView
        window.makeKeyAndOrderFront(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
EOF

# Compile and run
swiftc /tmp/cpbama_float.swift -o /tmp/cpbama_float -framework Cocoa -framework WebKit 2>/dev/null

if [ -f /tmp/cpbama_float ]; then
    /tmp/cpbama_float &
    echo "✅ cpbama floating avatar launched!"
else
    echo "❌ Failed to compile. Opening in browser instead..."
    open "$AVATAR_PATH"
fi
