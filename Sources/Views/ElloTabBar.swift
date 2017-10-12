////
///  ElloTabBar.swift
//

class ElloTabBar: UITabBar {
    struct Size {
        static let height: CGFloat = calculateHeight()
        static let topOffset: CGFloat = calculateTopOffset()

        static private func calculateHeight() -> CGFloat {
            if Globals.isIphoneX {
                return 74
            }
            return 44
        }

        static private func calculateTopOffset() -> CGFloat {
            if Globals.isIphoneX {
                return 11
            }
            return 1
        }
    }

    private var redDotViews = [(ElloTab, UIView)]()
    private var tabbarButtons: [UIControl] {
        return subviews.flatMap { $0 as? UIControl }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        privateInit()
    }

    convenience init() {
        self.init(frame: .zero)
        privateInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    private func privateInit() {
        self.backgroundColor = UIColor.white
        self.isTranslucent = false
        self.isOpaque = true
        self.barTintColor = UIColor.white
        self.tintColor = UIColor.black
        self.clipsToBounds = true
        self.shadowImage = UIImage.imageWithColor(UIColor.white)
    }

    func addRedDotFor(tab: ElloTab) -> UIView {
        let redDot: UIView
        if let entryIndex = (redDotViews.index { $0.0 == tab }) {
            redDot = redDotViews[entryIndex].1
        }
        else {
            redDot = UIView()
            redDot.backgroundColor = UIColor.red
            redDot.isHidden = true
            let redDotEntry = (tab, redDot)
            redDotViews.append(redDotEntry)
            addSubview(redDot)
        }

        positionRedDot(redDot, forTab: tab)
        return redDot
    }

    private func tabBarFrameAtIndex(_ index: Int) -> CGRect {
        let tabBarButtons = subviews.filter {
            $0 is UIControl
        }.sorted {
            $0.frame.minX < $1.frame.minX
        }
        return tabBarButtons.safeValue(index)?.frame ?? .zero
    }

    private func positionTabButton(_ button: UIControl) {
        button.frame.origin.y = Size.topOffset
    }

    private func positionRedDot(_ redDot: UIView, forTab tab: ElloTab) {
        let radius: CGFloat = 3
        let diameter = radius * 2
        let tabBarItemFrame = tabBarFrameAtIndex(tab.rawValue)
        let item = items?[tab.rawValue]
        let imageHalfWidth: CGFloat = (item?.selectedImage?.size.width ?? 0) / 2
        let x = tabBarItemFrame.midX + imageHalfWidth + tab.redDotMargins.x
        let frame = CGRect(x: x, y: tab.redDotMargins.y, width: diameter, height: diameter)

        redDot.layer.cornerRadius = radius
        redDot.frame = frame
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for (tab, redDot) in redDotViews {
            positionRedDot(redDot, forTab: tab)
        }
        for tabButton in tabbarButtons {
            positionTabButton(tabButton)
        }
    }

}
