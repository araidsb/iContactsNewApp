//
//  ContactsDetailViewController.swift
//  iContactsNewApp
//
//  Created by Арай Дуйсебекова on 11.05.2023.
//

import UIKit
import MessageUI



class ContactsDetailViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var initialsLabel: UILabel!
    
    @IBOutlet weak var nameSurnameLabel: UILabel!
    
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var videoButton: UIButton!
    
    @IBOutlet weak var mailButton: UIButton!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var numberFieldButton: UIButton!
    
    @IBOutlet weak var undoDeleteButton: UIButton!
    
    @IBOutlet weak var deleteThisContactButton: UIButton!
    
    @IBOutlet weak var viewForCornerRadius: UIView!
    
    var text: String?
    var initials: String?
    var phoneNumber: String?
    
    var timer: Timer?
    var countDown: Int = 10
    
    
    weak var delegate: ContactsVCDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // для стилизации отображения приложения при смене темы в белом цете
        overrideUserInterfaceStyle = .light
        
        // Do any additional setup after loading the view.
        
        progressView.progressTintColor = .white
        
        progressView.trackTintColor = .blue
        
        // добавление кнопки Edit
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editContact))
        navigationItem.rightBarButtonItem = editButton
        
        nameSurnameLabel.text = text
        initialsLabel.text = initials
        numberFieldButton.setTitle(phoneNumber, for: .normal)
        
        //для редактирования границ View в котором находится label
        viewForCornerRadius.layer.cornerRadius = viewForCornerRadius.frame.height / 2
        
        scheduleTimer()
        
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        sendMessages()
    }
    @IBAction func messageIconPressed(_ sender: Any) {
        sendMessages()
    }
    @IBAction func callButtonPressed(_ sender: Any) {
        callNumber(phoneNumber: phoneNumber ?? "")
    }
    @IBAction func callIconPressed(_ sender: Any){
        callNumber(phoneNumber: phoneNumber ?? "")
    }
    @IBAction func videoButtonPressed(_ sender: Any) {
        makeFaceTimeCall(phoneNumber: phoneNumber ?? "")
    }
    @IBAction func videoIconPressed(_ sender: Any) {
        makeFaceTimeCall(phoneNumber: phoneNumber ?? "")
    }
    @IBAction func mailButtonPressed(_ sender: Any) {
    }
    @IBAction func numberButtonPressed(_ sender: Any) {
        callNumber(phoneNumber: phoneNumber ?? "")
    }
    
    // нажатие кнопки undo delete
    @IBAction func undoDeleteButtonPressed(_ sender: Any) {
        deleteThisContactButton.isHidden = false
        undoDeleteButton.isHidden = true
        
        // Скрытие progressView
        progressView.isHidden = true
        
        // Сброс таймера
        timer?.invalidate()
        timer = nil
    }
    // нажатие кнопки удаления контакта
    @IBAction func deleteThisContactButtonPressed(_ sender: Any) {
        deleteThisContact()
    }
    // функция для выполнения звонка
    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    // функция для отправки смс сообщений
    func sendMessages() {
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        
        if MFMessageComposeViewController.canSendText() {
            self.present(messageController, animated: true, completion: nil)
        } else {
            print("iMessage is not available")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // facetime call
    func makeFaceTimeCall(phoneNumber: String) {
        guard let url = URL(string: "facetime://\(phoneNumber)") else {
            print("wrong URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Couldn't make a FaceTime call")
        }
    }
    // функция удаления контакта
    func deleteThisContact() {
        
        let alertController = UIAlertController(title: "WARNING", message: "Are you sure you want to delete this contact?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (_) in
            self?.startDeleteProgress()
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] (_) in
            self?.cancelDeleteContact()
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        delegate?.deleteThisContact()
        navigationController?.popViewController(animated: true)
    }
    // начало процесса удаления
    func startDeleteProgress() {
        deleteThisContactButton.isHidden = true
        undoDeleteButton.isHidden = false
        
        progressView.isHidden = false
        timer?.invalidate()
        timer = nil
        
        countDown = 5
        
        scheduleTimer()
    }
    // отмена удаления контакта
    func cancelDeleteContact() {
        deleteThisContactButton.isHidden = false
        undoDeleteButton.isHidden = true
        
        progressView.isHidden = true
        
        timer?.invalidate()
        timer = nil
    }
    
    func scheduleTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerUI), userInfo: nil, repeats: true)
        
    }
    // обновление прогресса таймера
    @objc
    func updateTimerUI() {
        
        countDown -= 1
        
        progressView.progress = Float(5 - countDown) / 5
        print("Progress View \(progressView.progress)")
        
        if countDown == 0 {
            // Скрытие progressView
            progressView.isHidden = true
            
            // Отключение кнопки undoDelete
            undoDeleteButton.isHidden = true
            
            // Сброс таймера
            timer?.invalidate()
            timer = nil
        }
    }
    // функция для редактирования контакта
    @objc
    func editContact() {
        
        let alertController = UIAlertController(title: "Edit Contact", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = ViewController.firstName
        }
        alertController.addTextField { (textField) in
            textField.placeholder = ViewController.lastName
        }
        alertController.addTextField { (textField) in
            textField.placeholder = ViewController.phoneNumber
        }
        
        let addAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let firstNameTextField = alertController.textFields?[0], let lastNameTextField = alertController.textFields?[1], let phoneNumberTextField = alertController.textFields?[2],
                  let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let phoneNumber = phoneNumberTextField.text,
                  !firstName.isEmpty, !lastName.isEmpty, !phoneNumber.isEmpty else {
                self.showAlert(message: "Please fill in all fields")
                return
            }
            print("First name: \(firstName)")
            print("Last name: \(lastName)")
            print("Phone number: \(phoneNumber)")
        }
        alertController.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // выводит алерт о том что не все  поля заполнены
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// протокол делегирования для удаления контакта из списка контактов и редактирования контакта
protocol ContactsVCDelegate: AnyObject {
    func deleteThisContact()
    func editContact()
}
