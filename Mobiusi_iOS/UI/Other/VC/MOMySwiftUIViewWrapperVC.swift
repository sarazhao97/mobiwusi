import SwiftUI

struct MOContentView: View {
    var body: some View {
        // For simplicity, we're not using the complex nav bar here for now
        Text("Hello from SwiftUI in a wrapper!")
    }
}

@objc(MOMySwiftUIViewWrapperVC)
class MOMySwiftUIViewWrapperVC: MOSwiftUIViewWrapperVCGeneric<MOContentView> {
    @objc init() {
        super.init(rootView: MOContentView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}