////
///  DrawerViewController.swift
//

protocol DrawerResponder: class {
    func showDrawerViewController()
}

class DrawerViewController: BaseElloViewController {
    @IBOutlet weak var tableView: UITableView!
    weak var navigationBar: ElloNavigationBar!
    var isLoggingOut = false

    override var backGestureEdges: UIRectEdge { return .right }

    let dataSource = DrawerViewDataSource()

    required init() {
        super.init(nibName: "DrawerViewController", bundle: .none)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addLeftButtons()
        setupTableView()
        registerCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        postNotification(StatusBarNotifications.statusBarVisibility, value: true)
    }
}

// MARK: UITableViewDelegate
extension DrawerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemForIndexPath(indexPath) else { return }

        if let tracking = item.tracking {
            Tracker.shared.tappedDrawer(tracking)
        }

        switch item.type {
        case let .external(link):
            postNotification(ExternalWebNotification, value: link)
        case .invite:
            let responder: InviteResponder? = findResponder()
            responder?.onInviteFriends()
        case .logout:
            isLoggingOut = true
            nextTick {
                self.dismiss(animated: true, completion: {
                     postNotification(AuthenticationNotifications.userLoggedOut, value: ())
                })
            }
        case .debugger:
            let appViewController = self.appViewController
            nextTick {
                self.dismiss(animated: true, completion: {
                    nextTick {
                        appViewController?.showDebugController()
                    }
                })
            }
        default: break
        }
    }
}

// MARK: View Helpers
private extension DrawerViewController {
    func setupTableView() {
        tableView.backgroundColor = .grey6
        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    func addLeftButtons() {
        let logoView = UIImageView(image: InterfaceImage.elloLogo.normalImage)
        let logoY: CGFloat = Globals.statusBarHeight + 10
        logoView.frame = CGRect(x: 15, y: logoY, width: 24, height: 24)
        navigationBar.addSubview(logoView)
    }

    func registerCells() {
        tableView.register(DrawerCell.nib(), forCellReuseIdentifier: DrawerCell.reuseIdentifier)
    }
}
