////
///  Screen.swift
//

import SnapKit


// Easy keyboard views: pin an anchor to `keyboardAnchor.top`. It'll animate
// automatically, too.
class Screen: UIView {
    let keyboardAnchor = UIView()
    fileprivate var keyboardTopConstraint: Constraint!
    fileprivate var keyboardWillShowObserver: NotificationObserver?
    fileprivate var keyboardWillHideObserver: NotificationObserver?

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(keyboardAnchor)
        backgroundColor = .white

        screenInit()
        style()
        bindActions()
        setText()
        arrange()
        layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        screenInit()
        style()
        bindActions()
        setText()
        arrange()
        layoutIfNeeded()
    }

    deinit {
        teardownKeyboardObservers()
    }

    func style() {}
    func bindActions() {}
    func setText() {}
    func arrange() {}

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil && window == nil {
            setupKeyboardObservers()
            keyboardWillChange(Keyboard.shared, animated: false)
        }
        else if newWindow == nil && window != nil {
            teardownKeyboardObservers()
        }
    }

    fileprivate func setupKeyboardObservers() {
        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: keyboardWillChangeAnimated)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: keyboardWillChangeAnimated)
    }

    fileprivate func teardownKeyboardObservers() {
        keyboardWillShowObserver?.removeObserver()
        keyboardWillHideObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardWillHideObserver = nil
    }

    func keyboardWillChangeAnimated(_ keyboard: Keyboard) {
        keyboardWillChange(keyboard, animated: true)
    }

    func keyboardWillChange(_ keyboard: Keyboard, animated: Bool) {
        let bottomInset = keyboard.keyboardBottomInset(inView: self)
        animate(duration: keyboard.duration, options: keyboard.options, animated: animated) {
            self.keyboardTopConstraint.update(offset: -bottomInset)
            self.keyboardIsAnimating(keyboard)
            self.layoutIfNeeded()
        }
    }

    func keyboardIsAnimating(_ keyboard: Keyboard) {}

    fileprivate func screenInit() {
        keyboardAnchor.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            keyboardTopConstraint = make.top.equalTo(self.snp.bottom).constraint
        }
    }
}
