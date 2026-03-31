// MARK: - Share Extension Setup (Xcode에서 수동 설정 필요)
//
// 이 파일을 사용하려면 Xcode에서 다음 단계를 수행하세요:
//
// 1. Xcode 메뉴: File > New > Target
// 2. "Share Extension" 선택 > Next
// 3. Product Name: "PrayAnswerShareExtension" 입력
// 4. Finish
// 5. 생성된 ShareViewController.swift 내용을 이 파일로 교체
// 6. Target > PrayAnswerShareExtension > Signing & Capabilities:
//    "App Groups" 추가 > "group.prayAnswer.widget" 선택
// 7. Target > PrayAnswer (메인 앱) > Signing & Capabilities:
//    "App Groups"에 "group.prayAnswer.widget" 이미 있는지 확인
// 8. Info.plist에서 NSExtensionActivationRule 확인 (아래 Info.plist 참조)

import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    // MARK: - UI

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let textPreview = UITextView()
    private let addButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let headerIcon = UIImageView()

    private var sharedText: String = ""

    // App Group identifier (메인 앱의 위젯과 동일)
    private let appGroupID = "group.prayAnswer.widget"
    private let sharedTextKey = "pendingSharedPrayerText"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        extractSharedText()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // 컨테이너
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // 헤더 아이콘
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        headerIcon.image = UIImage(systemName: "hands.clap.fill", withConfiguration: config)
        headerIcon.tintColor = UIColor(red: 0.4, green: 0.5, blue: 1.0, alpha: 1.0)
        headerIcon.translatesAutoresizingMaskIntoConstraints = false

        // 제목
        titleLabel.text = "기도제목으로 추가"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 텍스트 미리보기
        textPreview.font = UIFont.systemFont(ofSize: 15)
        textPreview.textColor = .secondaryLabel
        textPreview.backgroundColor = UIColor.secondarySystemBackground
        textPreview.layer.cornerRadius = 10
        textPreview.isEditable = false
        textPreview.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textPreview.translatesAutoresizingMaskIntoConstraints = false

        // 추가 버튼
        addButton.setTitle("기도제목에 추가하기", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addButton.backgroundColor = UIColor(red: 0.4, green: 0.5, blue: 1.0, alpha: 1.0)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 12
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        // 취소 버튼
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(.secondaryLabel, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        // 레이아웃
        containerView.addSubview(headerIcon)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textPreview)
        containerView.addSubview(addButton)
        containerView.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 320),

            headerIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerIcon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -60),

            titleLabel.centerYAnchor.constraint(equalTo: headerIcon.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerIcon.trailingAnchor, constant: 8),

            textPreview.topAnchor.constraint(equalTo: headerIcon.bottomAnchor, constant: 16),
            textPreview.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textPreview.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textPreview.heightAnchor.constraint(equalToConstant: 100),

            addButton.topAnchor.constraint(equalTo: textPreview.bottomAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 50),

            cancelButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 8),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    // MARK: - Extract Shared Text

    private func extractSharedText() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else { return }

        for attachment in attachments {
            // 일반 텍스트
            if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] item, _ in
                    DispatchQueue.main.async {
                        if let text = item as? String {
                            self?.sharedText = text
                            self?.textPreview.text = text
                        }
                    }
                }
                return
            }

            // URL (웹페이지 등)
            if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, _ in
                    DispatchQueue.main.async {
                        if let url = item as? URL {
                            self?.sharedText = url.absoluteString
                            self?.textPreview.text = url.absoluteString
                        }
                    }
                }
                return
            }

            // 속성 텍스트
            if attachment.hasItemConformingToTypeIdentifier(UTType.rtf.identifier) {
                attachment.loadItem(forTypeIdentifier: UTType.rtf.identifier) { [weak self] item, _ in
                    DispatchQueue.main.async {
                        if let data = item as? Data,
                           let text = try? NSAttributedString(data: data, documentAttributes: nil).string {
                            self?.sharedText = text
                            self?.textPreview.text = text
                        }
                    }
                }
                return
            }
        }
    }

    // MARK: - Actions

    @objc private func addTapped() {
        guard !sharedText.isEmpty else {
            cancelTapped()
            return
        }

        // App Group UserDefaults에 저장
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(sharedText, forKey: sharedTextKey)
        defaults?.synchronize()

        // URL Scheme으로 앱 열기 (extensionContext 통해 직접 열기는 iOS에서 제한됨)
        // 앱이 포그라운드로 오면 PrayAnswerApp에서 pendingSharedPrayerText를 감지
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    @objc private func cancelTapped() {
        extensionContext?.cancelRequest(withError: NSError(
            domain: "PrayAnswerShareExtension",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "취소됨"]
        ))
    }
}
