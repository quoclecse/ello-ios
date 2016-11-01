////
///  ProfileLinksSizeCalculator.swift
//

import FutureKit


public struct ProfileLinksSizeCalculator {

    public func calculate(item: StreamCellItem, maxWidth: CGFloat) -> Future<CGFloat> {
        let promise = Promise<CGFloat>()
        guard let
            user = item.jsonable as? User,
            externalLinks = user.externalLinksList
        where externalLinks.count > 0
        else {
            promise.completeWithSuccess(0)
            return promise.future
        }

        promise.completeWithSuccess(ProfileLinksSizeCalculator.calculateHeight(externalLinks, maxWidth: maxWidth))
        return promise.future
    }

    public static func calculateHeight(externalLinks: [ExternalLink], maxWidth: CGFloat) -> CGFloat {
        let iconsCount = externalLinks.filter({ $0.iconURL != nil }).count
        let (perRow, _) = ProfileLinksSizeCalculator.calculateIconsBoxWidth(externalLinks, maxWidth: maxWidth)
        let iconsRows = max(0, ceil(Double(iconsCount) / Double(perRow)))
        let iconsHeight = CGFloat(iconsRows) * ProfileLinksView.Size.iconSize.height + CGFloat(max(0, iconsRows - 1)) * ProfileLinksView.Size.iconMargins

        let textLinksCount = externalLinks.filter{$0.iconURL == nil && $0.text != ""}.count
        let linksHeight = CGFloat(textLinksCount) * ProfileLinksView.Size.linkHeight + CGFloat(max(0, textLinksCount - 1)) * ProfileLinksView.Size.verticalLinkMargin
        return ProfileLinksView.Size.margins.top + ProfileLinksView.Size.margins.bottom + max(iconsHeight, linksHeight)
    }

    public static func calculateIconsBoxWidth(externalLinks: [ExternalLink], maxWidth: CGFloat) -> (Int, CGFloat) {
        let iconsCount = externalLinks.filter({ $0.iconURL != nil }).count
        let textLinksCount = externalLinks.filter{$0.iconURL == nil && $0.text != ""}.count
        let cellWidth = max(0, maxWidth - ProfileLinksView.Size.margins.left - ProfileLinksView.Size.margins.right)
        let perRow: Int
        let iconsBoxWidth: CGFloat
        if textLinksCount > 0 {
            perRow = 3
            let maxNumberOfIconsInRow = CGFloat(min(perRow, iconsCount))
            let maxIconsWidth = ProfileLinksView.Size.iconSize.width * maxNumberOfIconsInRow
            let iconsMargins = ProfileLinksView.Size.iconMargins * max(0, maxNumberOfIconsInRow - 1)
            iconsBoxWidth = max(0, maxIconsWidth + iconsMargins)
        }
        else {
            iconsBoxWidth = cellWidth
            perRow = Int(cellWidth/(ProfileLinksView.Size.iconSize.width + ProfileLinksView.Size.iconMargins))
        }

        return (perRow, iconsBoxWidth)
    }
}

private extension ProfileLinksSizeCalculator {}
