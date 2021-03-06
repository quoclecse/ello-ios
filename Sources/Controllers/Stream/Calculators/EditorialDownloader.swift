////
///  EditorialDownloader.swift
//


class EditorialDownloader {
    fileprivate typealias CellJob = (editorials: [Editorial], completion: Block)
    fileprivate var jobs: [CellJob] = []
    fileprivate var editorials: [Editorial] = []
    fileprivate var completion: Block = {}

    func processCells(_ editorialItems: [StreamCellItem], completion: @escaping Block) {
        guard editorialItems.count > 0 else {
            completion()
            return
        }

        let editorials = editorialItems.flatMap { item -> Editorial? in
            guard
                let editorial = item.jsonable as? Editorial,
                editorial.kind == .postStream,
                editorial.posts == nil
            else { return nil }
            return editorial
        }

        let job: CellJob = (editorials: editorials, completion: completion)
        jobs.append(job)
        if jobs.count == 1 {
            processJob(job)
        }
    }

    func finish() {
        guard let job = jobs.first else { return }
        jobs.remove(at: 0)
        job.completion()
        if let nextJob = jobs.safeValue(0) {
            processJob(nextJob)
        }
    }

    fileprivate func processJob(_ job: CellJob) {
        let editorials = job.editorials
        let (afterAll, done) = afterN {
            self.finish()
        }
        EditorialsGenerator.loadPostStreamEditorials(editorials, afterAll: afterAll)
        done()
    }
}
