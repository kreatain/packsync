

import UIKit

class BillboardView: UIView {

    // UI Components
    let tableView = UITableView()
    let inputTextField = UITextField()
    let plusButton = UIButton(type: .system)
    let sendButton = UIButton(type: .system)
    let labelLoginPrompt: UILabel = {
            let label = UILabel()
            label.text = "Please create an account or log in to view the Billboard."
            label.textAlignment = .center
            label.textColor = .gray
            label.isHidden = true
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup UI elements
    private func setupUI() {
        self.backgroundColor = .white
        
        addSubview(labelLoginPrompt)

        // TableView setup
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)

        // Plus button setup
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plusButton)

        // Input text field setup
        inputTextField.placeholder = "Enter your message..."
        inputTextField.borderStyle = .roundedRect
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputTextField)

        // Send button setup (using a paper plane icon)
        let sendImage = UIImage(systemName: "paperplane.fill")
        sendButton.setImage(sendImage, for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sendButton)
    }

    // Setup Auto Layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // TableView constraints
            
            labelLoginPrompt.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelLoginPrompt.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelLoginPrompt.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            labelLoginPrompt.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputTextField.topAnchor, constant: -10),

            // Plus button constraints
            plusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            plusButton.centerYAnchor.constraint(equalTo: inputTextField.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 40),

            // Input text field constraints
            inputTextField.leadingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: 10),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            inputTextField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            inputTextField.heightAnchor.constraint(equalToConstant: 40),

            // Send button constraints
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
}
