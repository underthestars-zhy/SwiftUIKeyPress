import SwiftUI

#if os(macOS)

typealias UIViewControllerRepresentable = NSViewControllerRepresentable
typealias UIViewController = NSViewController
typealias UIHostingController = NSHostingController
public struct UIKey: Equatable {
    public let characters: String?
    public let flag: NSEvent.ModifierFlags?
    public let event: NSEvent
}

#endif

public extension View {
    func onKeyPress(_ keys: Binding<[UIKey]>) -> some View {
        self
            .modifier(KeyPressModifier(keys: keys))
    }
    
    func onKeyPress(_ action: @escaping ([UIKey]) -> ()) -> some View {
        self
            .modifier(DoOnKeyPressModifier(action: action))
    }
    
    func onKeyUpdate(_ action: @escaping ([UIKey]) -> ()) -> some View {
        self
            .modifier(DoOnUpdateKeyPressModifier(action: action))
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

struct DoOnUpdateKeyPressModifier: ViewModifier {
    @State var keys: [UIKey] = []
    @State var last: [UIKey] = []
    
    var action: ([UIKey]) -> ()
    
    func body(content: Content) -> some View {
        content
            .background(KeyPressView(keys: $keys))
            .onChange(of: keys) { newValue in
#if !os(macOS)
                action(newValue[last.endIndex...].map { $0 })
                last = newValue
#else
                action(newValue[last.endIndex...].map { $0 })
                last = newValue
#endif
            }
    }
}

struct KeyPressView: UIViewControllerRepresentable {
#if !os(macOS)
    typealias UIViewControllerType = KeyPressViewController
    
    typealias NSViewControllerType = KeyPressViewController
#endif
    
    class Coordinator: NSObject, KeyPressViewControllerDelegate {
        var parent: KeyPressView
        
        init(_ parent: KeyPressView) {
            self.parent = parent
        }
        
#if os(macOS)
        func tap(_ key: UIKey) {
            self.parent.keys.append(key)
        }
#else
        func tap(_ key: [UIKey]) {
            self.parent.keys.append(contentsOf: key)
        }
#endif
    }
    
    @Binding var keys: [UIKey]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
#if !os(macOS)
    func makeUIViewController(context: Context) -> KeyPressViewController {
        let controller = KeyPressViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: KeyPressViewController, context: Context) {
        
    }
#else
    func makeNSViewController(context: Context) -> KeyPressViewController {
        let controller = KeyPressViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateNSViewController(_ nsViewController: KeyPressViewController, context: Context) {
        
    }
#endif
}

class KeyPressViewController: UIViewController {
    var delegate: KeyPressViewControllerDelegate? = nil
    
    override func viewDidLoad() {
#if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
#else
        view.backgroundColor = .red
        view.layer.opacity = 0.1
#endif
    }
    
#if !os(macOS)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var result = [UIKey]()
        for press in presses {
            guard let key = press.key else {
                continue }
            
            result.append(key)
        }
        
        delegate?.tap(result)
        
        super.pressesBegan(presses, with: event)
    }
    
    
#else
    override func keyDown(with event: NSEvent) {
        delegate?.tap(UIKey.init(characters: event.characters, flag: event.modifierFlags, event: event))
    }
    
    override func loadView() {
        self.view = KeyView()
    }
    
    override var acceptsFirstResponder: Bool {
        true
    }
    
    class KeyView: NSView {
        override var acceptsFirstResponder: Bool { true }
        
        override func keyDown(with event: NSEvent) {
            
        }
    }
    
#endif
}

protocol KeyPressViewControllerDelegate {
#if !os(macOS)
    func tap(_ key: [UIKey])
#else
    func tap(_ key: UIKey)
#endif
}
