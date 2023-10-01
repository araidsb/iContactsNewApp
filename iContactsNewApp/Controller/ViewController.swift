//
//  ViewController.swift
//  iContactsNewApp
//
//  Created by Арай Дуйсебекова on 11.05.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    static let contactInfoKey: String = "contactInfo"
    
    // алфавит для отображения сбоку списка контактов
    private let alphabet = "abcdefghijklmnopqrstuvwxyz"
    
    static let firstName: String = ""
    static let lastName: String = ""
    static let phoneNumber: String = ""
    
    //  MARK: новый массив для хранения отсортированных контактов
    var sortedContactInfoArrayOfDictionaries: [Contact] = []
    
    
    struct Contact: Codable {
        let firstName: String
        let lastName: String
        let phoneNumber: String
    }
    
    enum ContactIndex: String, CaseIterable {
        case firstName
        case lastName
        
        var title: String {
            switch self {
            case .firstName:
                return "First Name"
            case .lastName:
                return "Last Name"
            }
        }
        // MARK: для сортировки контактов
        func getIndexValue(for contact: ViewController.Contact) -> String {
            switch self {
            case .firstName:
                return contact.firstName
            case .lastName:
                return contact.lastName
            }
        }
    }
    
    var contactInfoArrayOfDictionaries: [Contact] = [] {
        didSet {
            print("Value of variable ContactInfoArrayOfDictionaries was changed")
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // фон для того чтобы интерфейс во всех темах был светлым
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
        
        //tableview
        tableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: ContactsTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        //        tableView.rowHeight = 60
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(getContactInfo), for: .valueChanged)
        
        // segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.sendActions(for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getContactInfo()
    }
    
    // MARK: функция при нажатии кнопки + открывает UIAlertController
    @IBAction func addButtonPressed(_ sender: Any) {
        addContact()
    }
    
    // MARK: SegmentedControl
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Сортировка по имени
            sortedContactInfoArrayOfDictionaries = contactInfoArrayOfDictionaries.sorted { ContactIndex.firstName.getIndexValue(for: $0) < ContactIndex.firstName.getIndexValue(for: $1) }
        case 1:
            // Сортировка по фамилии
            sortedContactInfoArrayOfDictionaries = contactInfoArrayOfDictionaries.sorted { ContactIndex.lastName.getIndexValue(for: $0) < ContactIndex.lastName.getIndexValue(for: $1) }
        default:
            break
        }
        
        tableView.reloadData()
        getContactInfo()
    }
    
    
    // MARK: функция для добавления контакта
    func addContact() {
        let alertController = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "First name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Last name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Phone number"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let firstNameTextField = alertController.textFields?[0], let lastNameTextField = alertController.textFields?[1], let phoneNumberTextField = alertController.textFields?[2],
                  let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let phoneNumber = phoneNumberTextField.text,
                  !firstName.isEmpty, !lastName.isEmpty, !phoneNumber.isEmpty else {
                self.showAlert(message: "Please fill in all fields")
                return
            }
            guard self.isValidPhoneNumber(phoneNumber: phoneNumber) else {
                self.showAlert(message: "Invalid phone number format")
                return
            }
            print("First name: \(firstName)")
            print("Last name: \(lastName)")
            print("Phone number: \(phoneNumber)")
            
            self.saveContactInfoAsStruct(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
        }
        alertController.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: выводит алерт о том что не все  поля заполнены
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    // функция проверки правильности заполнения поля для номера
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phoneNumber)
    }
    
    // MARK: функция необходимая для сохранения контакта в телефоне
    func saveContactsInfo(firstName: String, lastName: String, phoneNumber: String) {
        let contactInfo: [String: Any] = ["firstName": firstName, "lastName": lastName,"phoneNumber": phoneNumber]
        let contactInfoArray: [[String: Any]] = getContactInfoArray() + [contactInfo]
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(contactInfoArray, forKey: ViewController.contactInfoKey)
        
    }
    // MARK: сохранение контактов как структуры
    func saveContactInfoAsStruct(firstName: String,lastName: String,phoneNumber: String) {
        let contact: Contact = Contact(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
        sortedContactInfoArrayOfDictionaries.append(contact)
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(sortedContactInfoArrayOfDictionaries)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: ViewController.contactInfoKey)
        } catch {
            print("Couldn't encode given [Contact] into data with error: \(error.localizedDescription)" )
        }
    }
    func getAllContacts() -> [Contact] {
        var result: [Contact] = []
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.object(forKey: ViewController.contactInfoKey) as? Data {
            do {
                let decoder = JSONDecoder()
                result = try decoder.decode([Contact].self, from: data)
                
            } catch {
                print("Couldn't decode given data [Contact with error \(error.localizedDescription)")
            }
        }
        return result
    }
    
    // MARK: функция для извлечения данных о контакте
    
    @objc
    func getContactInfo() {
        tableView.refreshControl?.endRefreshing()
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            // Сортировка по имени
            sortedContactInfoArrayOfDictionaries = getAllContacts().sorted { $0.firstName < $1.firstName }
        case 1:
            // Сортировка по фамилии
            sortedContactInfoArrayOfDictionaries = getAllContacts().sorted { $0.lastName < $1.lastName }
        default:
            break
        }
        
        tableView.reloadData()
    }
    // MARK: возвращает полные имя и фамилию для выбранного контакта
    func getSingleContactInfo(index: Int, from contactArray: [Contact]) -> String? {
        guard index >= 0 && index < contactArray.count else {
            return nil
        }
        
        let contact: Contact = contactArray[index]
        
        let fullName = "\(contact.firstName) \(contact.lastName)"
        return fullName
    }
    
    //MARK: возвращает инициалы фамилии и имени для лейбла
    
    func getSingleContactInitials(index: Int) -> String? {
        guard index >= 0 && index < sortedContactInfoArrayOfDictionaries.count else {
            return nil
        }
        
        let contact: Contact = sortedContactInfoArrayOfDictionaries[index]
        
        let firstNameInitial = contact.firstName.isEmpty ? "" : String(contact.firstName.prefix(1))
        let lastNameInitial = contact.lastName.isEmpty ? "" : String(contact.lastName.prefix(1))
        
        let initials = "\(firstNameInitial)\(lastNameInitial)"
        return initials
    }
    
    
    // MARK: функция для вывода номера на ContactsDetailViewController
    
    func getPhoneNumber(index: Int)-> String? {
        guard index >= 0 && index < sortedContactInfoArrayOfDictionaries.count else {
            return nil
        }
        
        let contact: Contact = sortedContactInfoArrayOfDictionaries[index]
        
        return contact.phoneNumber
    }
    
    func getContactInfoArray() -> [[String: Any]] {
        let userDefaults = UserDefaults.standard
        let array = userDefaults.array(forKey: ViewController.contactInfoKey) as? [[String: Any]]
        return array ?? []
    }
    
    // MARK: SWIPE TO DELETE
    private func swipeToDelete(at index: Int) {
        guard index >= 0 && index < sortedContactInfoArrayOfDictionaries.count else {
            return
        }
        
        sortedContactInfoArrayOfDictionaries.remove(at: index)
        
        saveContactInfoArray()
        
        tableView.reloadData()
    }
    
    private func saveContactInfoArray() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(sortedContactInfoArrayOfDictionaries)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: ViewController.contactInfoKey)
        } catch {
            print("Couldn't encode contactInfoArrayOfDictionaries into data with error: \(error.localizedDescription)" )
        }
    }
}

// MARK: UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedContactInfoArrayOfDictionaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.identifier, for: indexPath) as! ContactsTableViewCell
        cell.contactTextLabel.text = getSingleContactInfo(index: indexPath.row, from: sortedContactInfoArrayOfDictionaries)
        return cell
    }
    // MARK:  Методы UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = ContactsDetailViewController(nibName: "ContactsDetailViewController", bundle: nil)
        viewController.delegate = self
        viewController.text = getSingleContactInfo(index: indexPath.row,from: sortedContactInfoArrayOfDictionaries)
        viewController.initials = getSingleContactInitials(index: indexPath.row)
        viewController.phoneNumber = getPhoneNumber(index: indexPath.row)
        navigationController?.pushViewController(viewController, animated: true)
    }
    // MARK: функция для отображения сбоку алфавита для сортировки контактов
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Array(alphabet.uppercased()).compactMap({"\($0)"})
    }
}

//    MARK: функция swipe to delete( расширение UITableViewDelegate)
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            swipeToDelete(at: indexPath.row)
        }
    }
}

// расширение для делегирования некоторых функций со второго вью контроллера в первый

extension ViewController: ContactsVCDelegate {
    func editContact() {
        
    }
    func deleteThisContact() {
        
        tableView.reloadData()
    }
}

