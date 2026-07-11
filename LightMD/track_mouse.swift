import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSEvent.addGlobalMonitorForEvents(matching: [.otherMouseDown, .otherMouseUp, .swipe, .scrollWheel]) { event in
            print("Global:", event)
        }
        NSEvent.addLocalMonitorForEvents(matching: [.otherMouseDown, .otherMouseUp, .swipe, .scrollWheel]) { event in
            print("Local:", event.type, event.buttonNumber)
            return event
        }
    }
}
