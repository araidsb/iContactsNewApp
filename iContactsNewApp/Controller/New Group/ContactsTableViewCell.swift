//
//  ContactsTableViewCell.swift
//  iContactsNewApp
//
//  Created by Арай Дуйсебекова on 11.05.2023.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    // для хранения идентификатора
    
    static let identifier: String = "ContactsTableViewCell"

    @IBOutlet weak var contactTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contactTextLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // для приведения ячейки в начальное состояние
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contactTextLabel.text = nil
    }
}
