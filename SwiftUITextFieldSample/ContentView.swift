import SwiftUI

struct ContentView: View {
    enum Field: Hashable {
        case keyword1
        case keyword2
    }

    @State private var keyword1 = ""
    @State private var keyword2 = ""

    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: EmptyView()) {
                    TextField("TextField", text: $keyword1)
                        .onChange(of: keyword1) { keyword in
                            print("onChangeKeword1: \(keyword)")
                        }
                        .focused($focusedField, equals: .keyword1)
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                HStack {
                                    Spacer()
                                    Button("Cancel"){
                                        self.focusedField = nil
                                    }
                                }
                            }
                        }

                    TextField2("TextField2",
                               text: $keyword2,
                               onEditingChanged: { isEditing in
                        print("onEditingChanged: \(isEditing)")
                    },
                               onCommit: {
                        print("onCommit")
                    })
                    .clearButtonMode(.whileEditing)
                    .onCancel { focusedField = nil }
                    .onChange(of: keyword2) { keyword in
                        print("onChangeKeword2: \(keyword)")
                    }
                    .focused($focusedField, equals: .keyword2)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
