import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    // MARK: - App Group 설정 (메인 앱과 동일해야 함)
    private let appGroupID = "group.prayAnswer.widget"
    private let sharedTextKey = "pendingSharedPrayerText"

    // MARK: - UI
    private let dimView = UIView()
    private let sheetView = UIView()
    private let handleBar = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let previewBox = UIView()
    private let previewLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    private var sharedText: String = ""

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        extractSharedText()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimView.alpha = 1
            self.sheetView.transform = .identity
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .clear

        // 딤 배경
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        dimView.addGestureRecognizer(tap)

        // 시트
        sheetView.backgroundColor = UIColor.systemBackground
        sheetView.layer.cornerRadius = 20
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.transform = CGAffineTransform(translationX: 0, y: 300)
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)

        // 핸들 바
        handleBar.backgroundColor = UIColor.systemFill
        handleBar.layer.cornerRadius = 2.5
        handleBar.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(handleBar)

        // 앱 아이콘 느낌의 이미지
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        iconImageView.image = UIImage(systemName: "hands.clap.fill", withConfiguration: config)
        iconImageView.tintColor = UIColor(red: 0.44, green: 0.51, blue: 0.98, alpha: 1)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(iconImageView)

        // 제목
        titleLabel.text = "기도제목으로 추가"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(titleLabel)

        // 텍스트 미리보기 박스
        previewBox.backgroundColor = UIColor.secondarySystemBackground
        previewBox.layer.cornerRadius = 12
        previewBox.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(previewBox)

        previewLabel.font = UIFont.systemFont(ofSize: 15)
        previewLabel.textColor = .secondaryLabel
        previewLabel.numberOfLines = 5
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        previewBox.addSubview(previewLabel)

        // 추가 버튼
        addButton.setTitle("PrayAnswer에 추가하기", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addButton.backgroundColor = UIColor(red: 0.44, green: 0.51, blue: 0.98, alpha: 1)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 14
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(addButton)

        // 취소 버튼
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(.secondaryLabel, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(cancelButton)

        // 레이아웃
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            handleBar.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 10),
            handleBar.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 36),
            handleBar.heightAnchor.constraint(equalToConstant: 5),

            iconImageView.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),

            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),

            previewBox.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            previewBox.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            previewBox.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),

            previewLabel.topAnchor.constraint(equalTo: previewBox.topAnchor, constant: 12),
            previewLabel.leadingAnchor.constraint(equalTo: previewBox.leadingAnchor, constant: 12),
            previewLabel.trailingAnchor.constraint(equalTo: previewBox.trailingAnchor, constant: -12),
            previewLabel.bottomAnchor.constraint(equalTo: previewBox.bottomAnchor, constant: -12),

            addButton.topAnchor.constraint(equalTo: previewBox.bottomAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 52),

            cancelButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 8),
            cancelButton.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
    }

    // MARK: - 공유 텍스트 추출

    private func extractSharedText() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else { return }

        for provider in attachments {
            // 일반 텍스트 우선
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] item, _ in
                    DispatchQueue.main.async {
                        let text = (item as? String) ?? ""
                        self?.applySharedText(text)
                    }
                }
                return
            }

            // URL (웹 주소)
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, _ in
                    DispatchQueue.main.async {
                        let text = (item as? URL)?.absoluteString ?? ""
                        self?.applySharedText(text)
                    }
                }
                return
            }
        }
    }

    private func applySharedText(_ text: String) {
        sharedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        previewLabel.text = sharedText.isEmpty ? "공유된 텍스트가 없습니다" : sharedText
        addButton.isEnabled = !sharedText.isEmpty
        addButton.alpha = sharedText.isEmpty ? 0.5 : 1.0
    }

    // MARK: - Actions

    @objc private func addTapped() {
        guard !sharedText.isEmpty else { return }

        // App Group UserDefaults에 저장
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(sharedText, forKey: sharedTextKey)
        defaults?.synchronize()

        // 애니메이션 후 완료
        UIView.animate(withDuration: 0.2, animations: {
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: 300)
            self.dimView.alpha = 0
        }, completion: { _ in
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        })
    }

    @objc private func cancelTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: 300)
            self.dimView.alpha = 0
        }, completion: { _ in
            self.extensionContext?.cancelRequest(withError: NSError(
                domain: Bundle.main.bundleIdentifier ?? "PrayAnswerShareExtension",
                code: 0
            ))
        })
    }
}
