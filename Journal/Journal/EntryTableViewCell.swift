//
//  EntryTableViewCell.swift
//  Journal
//
//  Created by Lorenzo on 2/18/21.
//

import UIKit

class EntryTableViewCell: UITableViewCell {
    
    
    // MARK: Properties
    static let reuseIdentifier = "EntryCell"
    
    var entry: Entry? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: IB Ooutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }

    
    
    func updateViews() {
        guard let entry = entry else { return }
        titleLabel.text = entry.title
        bodyTextLabel.text = entry.bodyText
        dateLabel.text = "\(getFormattedDate(date: entry.timestamp!, format: "MMM dd yyyy"))\n\(getFormattedDate(date: entry.timestamp!, format: "HH:mm"))"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
