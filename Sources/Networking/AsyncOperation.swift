////
///  AsyncOperation.swift
//

class AsyncOperation: Operation {
    typealias AsyncBlock = (@escaping () -> Void) -> Void
    var _block: AsyncBlock?
    var block: AsyncBlock? {
        get { return _block }
        set {
            guard _block == nil else { return }
            _block = newValue
            if Globals.isTesting {
                usleep(1000)
            }
            if isCancelled && _executing {
                isExecuting = false
            }
            else if let block = newValue, _executing {
                block(done)
            }
        }
    }

    private var _executing: Bool = false
    override var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _finished: Bool = false
    override var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    override var isAsynchronous: Bool { return true }

    init(block: AsyncBlock? = nil) {
        _block = block
        super.init()
    }

    override func start() {
        guard !isFinished else {
            return
        }
        guard !isCancelled else {
            done()
            return
        }

        isExecuting = true
        block?(done)
    }

    func run(_ block: @escaping () -> Void = {}) {
        self.block = { done in
            block()
            done()
        }
    }
}

private extension AsyncOperation {

    func done() {
        isExecuting = false
        isFinished = true
    }
}
