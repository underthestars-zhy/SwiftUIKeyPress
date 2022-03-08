import SwiftUI

public extension View {
    func onKeyPress(_ keys: Binding<[UIKey]>) -> some View {
        self
            .modifier(KeyPressModifier(keys: keys))
    }
    
    func onKeyPress(_ action: @escaping ([UIKey]) -> ()) -> some View {
        self
            .modifier(DoOnKeyPressModifier(action: action))
    }
}

struct KeyPressModifier: ViewModifier {
    @Binding var keys: [UIKey]
    
    func body(content: Content) -> some View {
        content
            .background(KeyPressView(keys: $keys))
    }
}

struct DoOnKeyPressModifier: ViewModifier {
    @State var keys: [UIKey] = []
    
    var action: ([UIKey]) -> ()
    
    func body(content: Content) -> some View {
        content
            .background(KeyPressView(keys: $keys))
            .onChange(of: keys) { newValue in
                action(newValue)
            }
    }
}

struct KeyPressView: UIViewControllerRepresentable {
    typealias UIViewControllerType = KeyPressViewController
    
    class Coordinator: NSObject, KeyPressViewControllerDelegate {
        var parent: KeyPressView
        
        init(_ parent: KeyPressView) {
            self.parent = parent
        }
        
        func tap(_ key: [UIKey]) {
            self.parent.keys.append(contentsOf: key)
        }
    }
    
    @Binding var keys: [UIKey]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> KeyPressViewController {
        let controller = KeyPressViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: KeyPressViewController, context: Context) {
        
    }
}

class KeyPressViewController: UIViewController {
    var delegate: KeyPressViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        self.view.addSubview(UIHostingController(rootView: Color.clear.id(UUID())).view)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var result = [UIKey]()
        for press in presses {
            guard let key = press.key else { continue }
            
            result.append(key)
        }
        
        delegate?.tap(result)
        
        super.pressesBegan(presses, with: event)
    }
}

protocol KeyPressViewControllerDelegate {
    func tap(_ key: [UIKey])
}
