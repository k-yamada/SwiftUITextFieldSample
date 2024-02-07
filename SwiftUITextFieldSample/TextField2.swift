import SwiftUI
import UIKit

final class TextField2Coordinator: NSObject, UITextFieldDelegate {
    var control: TextField2

    init(_ control: TextField2) {
        self.control = control
        super.init()
        control.textField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
        control.textField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        control.textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        control.textField.addTarget(self, action: #selector(textFieldEditingDidEndOnExit(_:)), for: .editingDidEndOnExit)
    }

    @objc private func textFieldEditingDidBegin(_ textField: UITextField) {
        control.onEditingChanged(true)
    }

    @objc private func textFieldEditingDidEnd(_ textField: UITextField) {
        control.onEditingChanged(false)
    }

    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        control.text = textField.text ?? ""
    }

    @objc private func textFieldEditingDidEndOnExit(_ textField: UITextField) {
        control.onCommit()
    }

    @objc func onCancel(_ button: UIButton) {
        control.onCancel?()
    }
}

struct TextField2: UIViewRepresentable {
    private let title: String?
    @Binding var text: String
    let textField = UITextField()
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void
    var onCancel: (() -> Void)? = nil
    private var keyboardType: UIKeyboardType = .default
    private var clearButtonMode: UITextField.ViewMode = .always

    init(_ title: String?,
         text: Binding<String>,
         onEditingChanged: @escaping (Bool) -> Void = { _ in },
         onCommit: @escaping () -> Void = {}
    ) {
        self.title = title
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }

    func makeCoordinator() -> TextField2Coordinator {
        TextField2Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        // TextFieldのコンテンツが領域をはみ出さないようにする
        // https://stackoverflow.com/a/59193838
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textField.placeholder = title
        textField.delegate = context.coordinator
        textField.clearButtonMode = clearButtonMode
        textField.keyboardType = keyboardType
        if onCancel != nil {
            textField.inputAccessoryView = makeToolbar(context: context)
        }
        return textField
    }

    // NOTE: @Bindingの値が変更された時、updateUIViewが呼び出される
    func updateUIView(_ uiView: UITextField, context: Context) {
        // NOTE: 変換候補がない場合(markedTextRange == nil)のみtextをセットする.
        // この条件がないと、ユーザが入力した1文字目が変換対象にならないことがある.
        if uiView.text != text && uiView.markedTextRange == nil {
            uiView.text = text
        }
    }

    private func makeToolbar(context: Context) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: .zero, y: .zero, width: textField.frame.size.width, height: 44))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: context.coordinator,
            action: #selector(context.coordinator.onCancel(_:))
        )
        toolbar.setItems([spacer, cancelButton], animated: true)
        return toolbar
    }
}

extension TextField2 {
    func keyboardType(_ keyboardType: UIKeyboardType) -> TextField2 {
        var view = self
        view.keyboardType = keyboardType
        return view
    }

    func clearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> TextField2 {
        var view = self
        view.clearButtonMode = clearButtonMode
        return view
    }

    func onCancel(_ action: @escaping () -> Void) -> TextField2 {
        var view = self
        view.onCancel = action
        return view
    }
}
