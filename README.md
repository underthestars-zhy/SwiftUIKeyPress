# SwiftUIKeyPress

SwiftUIKeyPress is a package to make up for the lack of keyboard input in SwiftUI.

![](SwiftUIKeyPress)

## How to use?

There are two ways that you can implement `SwiftUIPress`

First:

```swift
struct ContentView: View
    @State var keys = [UIKey]()

    var body: some View {
        Text(keys.map(\.characters).reduce("", +))
            .padding()
            .onKeyPress($keys)
    }
}
```

Second:

```swift
struct ContentView: View
    @State var keys = [UIKey]()

    var body: some View {
        Text(keys.map(\.characters).reduce("", +))
            .padding()
            .onKeyPress { keys in
                self.keys = keys
            }
    }
}
```

## A Tips

You only can use 1 `SwiftUIKeyPress` modifier on every one view. The others will not work.
