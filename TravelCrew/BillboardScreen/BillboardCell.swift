import UIKit

class BillboardCell: UITableViewCell {

    // UI Components
    private let containerView = UIView()
    private let headerStackView = UIStackView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let contentLabel = UILabel()
    private let stackView = UIStackView()
    private let voteTitleLabel = UILabel()
    private let photoImageView = UIImageView()
    private var photoImageHeightConstraint: NSLayoutConstraint?

    // Flag to indicate if voting has been completed
  
    private var voteId: String?

    // Computed property to check and store voting state
    private var hasVoted: Bool {
        get {
            guard let voteId = voteId else { return false }
            return UserDefaults.standard.bool(forKey: "hasVoted_\(voteId)")
        }
        set {
            guard let voteId = voteId else { return }
            UserDefaults.standard.set(newValue, forKey: "hasVoted_\(voteId)")
        }
    }

    // Closure to handle choice selection
    var choiceSelectedHandler: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        // Add subviews to containerView
        containerView.addSubview(headerStackView)
        containerView.addSubview(voteTitleLabel)
        containerView.addSubview(contentLabel)
        containerView.addSubview(stackView)
        containerView.addSubview(photoImageView)

        // Configure headerStackView
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.distribution = .equalSpacing
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        // Configure titleLabel and authorLabel
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .gray
        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .darkGray
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(authorLabel)

        // Configure voteTitleLabel
        voteTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        voteTitleLabel.textColor = .black
        voteTitleLabel.textAlignment = .left
        voteTitleLabel.numberOfLines = 0
        voteTitleLabel.lineBreakMode = .byWordWrapping
        voteTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure contentLabel
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure stackView
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Configure photoImageView
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        photoImageHeightConstraint = photoImageView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            // Container View Constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Header Stack View Constraints
            headerStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            headerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            headerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),

            // Vote Title Label Constraints
            voteTitleLabel.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 8),
            voteTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            voteTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),

            // Content Label Constraints (For Notice Type)
            contentLabel.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),

            // Stack View Constraints (For Choices in Vote Type)
            stackView.topAnchor.constraint(equalTo: voteTitleLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            photoImageView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 8),
            photoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            photoImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            photoImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
        ])
    }
    
    func configureNotice(title: String, authorText: String, content: String) {
        resetCell()
        titleLabel.text = title
        authorLabel.text = authorText
        contentLabel.text = content
        contentLabel.isHidden = false
        voteTitleLabel.isHidden = true
        stackView.isHidden = true
        photoImageView.isHidden = true
        
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    func configureVote(title: String, authorText: String, choices: [String], votes: [String: Int], voteId: String,     nums: Int,
    totalNums: Int, choiceSelectedHandler: @escaping (String) -> Void) {
        resetCell()
        self.choiceSelectedHandler = choiceSelectedHandler
        self.voteId = voteId
        titleLabel.text = "Vote"
        authorLabel.text = authorText
        
       

        // 显示 voteTitleLabel 和 stackView，隐藏 contentLabel
        voteTitleLabel.isHidden = false
        stackView.isHidden = false
        contentLabel.isHidden = true
        photoImageView.isHidden = true
        
       
            
     
        // 配置 voteTitleLabel
        voteTitleLabel.text = "\(title) (\(nums)/\(totalNums) voted)"
        voteTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        voteTitleLabel.textColor = .black
        voteTitleLabel.textAlignment = .left
        voteTitleLabel.numberOfLines = 0
        voteTitleLabel.lineBreakMode = .byWordWrapping

        // 清空 stackView 中的子视图
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        

        // 检查是否已投票
        if hasVoted {
            updateVoteUI(choices: choices, votes: votes)
            return
        }

        // 创建投票选项
        for choice in choices {
            let choiceStackView = UIStackView()
            choiceStackView.axis = .horizontal
            choiceStackView.alignment = .center
            choiceStackView.distribution = .fillProportionally
            choiceStackView.spacing = 10

            let bulletLabel = UILabel()
            bulletLabel.text = "•"
            bulletLabel.font = UIFont.systemFont(ofSize: 16)
            bulletLabel.textColor = .gray

            let choiceLabel = UILabel()
            choiceLabel.text = choice
            choiceLabel.textAlignment = .left
            choiceLabel.font = UIFont.systemFont(ofSize: 16)
            choiceLabel.lineBreakMode = .byTruncatingTail
            choiceLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            choiceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

           
            let thumbUpButton = UIButton(type: .system)
            thumbUpButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            thumbUpButton.tintColor = .systemBlue
            thumbUpButton.addAction(UIAction { _ in
                self.hasVoted = true
                self.choiceSelectedHandler?(choice)
                self.updateVoteUI(choices: choices, votes: votes)
            }, for: .touchUpInside)

            // 配置 thumbUpButton 的优先级，确保它靠右对齐
            thumbUpButton.setContentHuggingPriority(.required, for: .horizontal)
            thumbUpButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            choiceStackView.addArrangedSubview(bulletLabel)
            choiceStackView.addArrangedSubview(choiceLabel)
            choiceStackView.addArrangedSubview(thumbUpButton)

            stackView.addArrangedSubview(choiceStackView)
        }
        
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    private func updateVoteUI(choices: [String], votes: [String: Int]) {
        // Clear the stack view and show vote counts
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        
        for choice in choices {
            let voteCount = votes[choice] ?? 0

            // Create a horizontal stack view for each choice
            let choiceStackView = UIStackView()
            choiceStackView.axis = .horizontal
            choiceStackView.alignment = .center
            choiceStackView.distribution = .fill
            choiceStackView.spacing = 10

            // Bullet Point Label
            let bulletLabel = UILabel()
            bulletLabel.text = "•"
            bulletLabel.font = UIFont.systemFont(ofSize: 16)
            bulletLabel.textColor = .gray
            bulletLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            
            let choiceLabel = UILabel()
            choiceLabel.text = choice
            choiceLabel.textAlignment = .left
            choiceLabel.font = UIFont.systemFont(ofSize: 16)
            choiceLabel.lineBreakMode = .byTruncatingTail
            choiceLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            choiceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)


            // Vote Count Label
            let voteCountLabel = UILabel()
            voteCountLabel.text = "\(voteCount) votes"
            voteCountLabel.textAlignment = .right
            voteCountLabel.font = UIFont.boldSystemFont(ofSize: 14)
            voteCountLabel.textColor = .gray
            voteCountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            // Add the labels to the choice stack view
            choiceStackView.addArrangedSubview(bulletLabel)
            choiceStackView.addArrangedSubview(choiceLabel)
            choiceStackView.addArrangedSubview(voteCountLabel)

            // Add the choice stack view to the main stack view
            stackView.addArrangedSubview(choiceStackView)
        }
    }
    
    private func resetCell() {
        // 重置所有视图状态
        contentLabel.isHidden = true
        voteTitleLabel.isHidden = true
        stackView.isHidden = true
        photoImageView.isHidden = true
        photoImageHeightConstraint?.constant = 0
        // 清空文本内容
        contentLabel.text = nil
        voteTitleLabel.text = nil
        titleLabel.text = nil
        authorLabel.text = nil
        photoImageView.image = nil
        photoImageHeightConstraint?.isActive = false

        // 移除 stackView 中的所有子视图
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 强制更新布局
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    func configurePhoto(title: String, authorText: String, photoUrl: String) {
        resetCell()
        titleLabel.text = title
        authorLabel.text = authorText
        contentLabel.isHidden = true
        voteTitleLabel.isHidden = true
        stackView.isHidden = true
        photoImageView.isHidden = false
        photoImageHeightConstraint?.isActive = true

        photoImageHeightConstraint?.constant = 200
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
        loadImage(from: photoUrl)

        photoImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        photoImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func photoTapped() {
        guard let image = photoImageView.image else { return }
        let fullScreenVC = PhotoFullScreenViewController()
        fullScreenVC.photoImage = image
        UIApplication.shared.keyWindow?.rootViewController?.present(fullScreenVC, animated: true)
    }

    private func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.photoImageView.image = image
                }
            } else {
                print("Failed to load image from URL: \(url)")
            }
        }
    }
}
