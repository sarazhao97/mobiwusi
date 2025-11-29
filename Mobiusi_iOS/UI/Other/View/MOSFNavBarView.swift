import SwiftUI

#if canImport(UIKit)
import UIKit

@MainActor private func getSafeAreaTop() -> CGFloat {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    return window?.safeAreaInsets.top ?? 20
}
#else
private func getSafeAreaTop() -> CGFloat {
    return 20
}
#endif

public struct MOSFNavBarView: View {
    @State private var safeAreaTop: CGFloat
    @State private var leftBtnImageName: String?
    @State private var leftBtnTitle: String?
    private var title: String
    @State private var rightViews: [AnyView]
    private var leftBtnAction: (() -> Void)?

    public init(
        leftBtnImageName: String? = nil,
        leftBtnTitle: String? = nil,
        title: String,
        rightViews: [AnyView],
        leftBtnAction: (() -> Void)? = nil
    ) {
        _safeAreaTop = State(initialValue: getSafeAreaTop())
        _leftBtnImageName = State(initialValue: leftBtnImageName)
        _leftBtnTitle = State(initialValue: leftBtnTitle)
        self.title = title
        _rightViews = State(initialValue: rightViews)
        self.leftBtnAction = leftBtnAction
    }

    public var body: some View {
        ZStack {
            Color.green
            VStack {
                Spacer(minLength: 0)
				HStack(alignment: .center, spacing: 10){
                    HStack {
                        Button {
                            if let leftBtnAction {
                                leftBtnAction()
                            }
                        } label: {
                            if let leftBtnTitle {
                                Text(leftBtnTitle)
                            }
                            if let leftBtnImageName {
                                Image(leftBtnImageName)
                            }
                        }
                        .padding(.leading, 10)
                        .disabled(leftBtnImageName == nil && leftBtnTitle == nil)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text(title)
                        .lineLimit(1)
                        .fixedSize()
                        .layoutPriority(1)

                    HStack(spacing: 0) {
                        ForEach(Array(rightViews.enumerated()), id: \.offset) { _, item in
                            item
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(height: 44)
            }
        }
        .frame(height: safeAreaTop + 44)
    }
}

struct MOSFNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        MOSFNavBarView(leftBtnTitle: "Back", title: "Preview Title", rightViews: [AnyView(Text("R"))])
    }
}
