import UIKit
import UniformTypeIdentifiers

// MARK: - Pending Prayer Data

private struct PendingSharedPrayer: Codable {
    let content: String
    let target: String
    let targetDate: Double?      // Date.timeIntervalSince1970, nil이면 D-Day 없음
    let notificationEnabled: Bool
}

// MARK: - ShareViewController

class ShareViewController: UIViewController, UITextViewDelegate {

    private let appGroupID = "group.prayAnswer.widget"
    private let pendingKey = "pendingSharedPrayerData"
    private let accent     = UIColor(red: 0.44, green: 0.51, blue: 0.98, alpha: 1)

    // MARK: - UI
    private let scrollView     = UIScrollView()
    private let headerView     = UIView()
    private let targetField    = UITextField()
    private let contentTV      = UITextView()
    private let placeholder    = UILabel()

    // D-Day
    private let ddaySwitch     = UISwitch()
    private let datePicker     = UIDatePicker()
    private var datePickerHeightConstraint: NSLayoutConstraint!

    // 알림
    private let notifSwitch    = UISwitch()

    // MARK: - loadView

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemGroupedBackground
    }

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        buildHeader()
        buildScrollContent()
        extractSharedText()
    }

    // MARK: - Header

    private func buildHeader() {
        headerView.backgroundColor = .systemGroupedBackground
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let cancelBtn = makeTextButton("취소", action: #selector(cancelTapped))
        let saveBtn   = makeTextButton("저장", action: #selector(saveTapped))
        saveBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)

        let titleLabel = UILabel()
        titleLabel.text = "기도제목 추가"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let sep = UIView()
        sep.backgroundColor = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false

        [cancelBtn, titleLabel, saveBtn, sep].forEach { headerView.addSubview($0) }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),

            cancelBtn.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            cancelBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            saveBtn.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            saveBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            sep.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            sep.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    // MARK: - Scroll Content

    private func buildScrollContent() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let pad: CGFloat = 16

        // ── 기도대상자 카드 ──────────────────────────────────
        let targetCard = makeCard()
        scrollView.addSubview(targetCard)

        let targetLabel = makeSectionLabel("기도대상자")
        let targetSep   = makeSep()
        targetField.placeholder = "이름 또는 대상 (선택)"
        targetField.font = .systemFont(ofSize: 16)
        targetField.returnKeyType = .next
        targetField.translatesAutoresizingMaskIntoConstraints = false

        [targetLabel, targetSep, targetField].forEach { targetCard.addSubview($0) }

        NSLayoutConstraint.activate([
            targetCard.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: pad),
            targetCard.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: pad),
            targetCard.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -pad),
            targetCard.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -pad * 2),

            targetLabel.topAnchor.constraint(equalTo: targetCard.topAnchor, constant: 12),
            targetLabel.leadingAnchor.constraint(equalTo: targetCard.leadingAnchor, constant: 16),
            targetSep.topAnchor.constraint(equalTo: targetLabel.bottomAnchor, constant: 8),
            targetSep.leadingAnchor.constraint(equalTo: targetCard.leadingAnchor, constant: 16),
            targetSep.trailingAnchor.constraint(equalTo: targetCard.trailingAnchor, constant: -16),
            targetField.topAnchor.constraint(equalTo: targetSep.bottomAnchor, constant: 10),
            targetField.leadingAnchor.constraint(equalTo: targetCard.leadingAnchor, constant: 16),
            targetField.trailingAnchor.constraint(equalTo: targetCard.trailingAnchor, constant: -16),
            targetField.bottomAnchor.constraint(equalTo: targetCard.bottomAnchor, constant: -14),
        ])

        // ── 기도 내용 카드 ───────────────────────────────────
        let contentCard = makeCard()
        scrollView.addSubview(contentCard)

        let contentLabel = makeSectionLabel("기도 내용")
        contentTV.font = .systemFont(ofSize: 16)
        contentTV.backgroundColor = .clear
        contentTV.isScrollEnabled = false
        contentTV.delegate = self
        contentTV.translatesAutoresizingMaskIntoConstraints = false

        placeholder.text = "기도 내용을 입력하세요"
        placeholder.font = .systemFont(ofSize: 16)
        placeholder.textColor = .placeholderText
        placeholder.translatesAutoresizingMaskIntoConstraints = false

        [contentLabel, contentTV, placeholder].forEach { contentCard.addSubview($0) }

        NSLayoutConstraint.activate([
            contentCard.topAnchor.constraint(equalTo: targetCard.bottomAnchor, constant: pad),
            contentCard.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: pad),
            contentCard.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -pad),

            contentLabel.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 12),
            contentLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            contentTV.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 6),
            contentTV.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 12),
            contentTV.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -12),
            contentTV.bottomAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: -12),
            contentTV.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            placeholder.topAnchor.constraint(equalTo: contentTV.topAnchor, constant: 8),
            placeholder.leadingAnchor.constraint(equalTo: contentTV.leadingAnchor, constant: 5),
        ])

        // ── D-Day 카드 ───────────────────────────────────────
        let ddayCard = makeCard()
        scrollView.addSubview(ddayCard)

        let ddayRowLabel = makeRowLabel("D-Day 설정")
        ddaySwitch.isOn = false
        ddaySwitch.onTintColor = accent
        ddaySwitch.addTarget(self, action: #selector(ddaySwitchChanged), for: .valueChanged)
        ddaySwitch.translatesAutoresizingMaskIntoConstraints = false

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        datePicker.tintColor = accent
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.alpha = 0

        let ddaySep = makeSep()
        [ddayRowLabel, ddaySwitch, ddaySep, datePicker].forEach { ddayCard.addSubview($0) }

        datePickerHeightConstraint = datePicker.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            ddayCard.topAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: pad),
            ddayCard.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: pad),
            ddayCard.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -pad),

            ddayRowLabel.topAnchor.constraint(equalTo: ddayCard.topAnchor, constant: 14),
            ddayRowLabel.leadingAnchor.constraint(equalTo: ddayCard.leadingAnchor, constant: 16),
            ddayRowLabel.bottomAnchor.constraint(equalTo: ddaySep.topAnchor, constant: -14),
            ddaySwitch.centerYAnchor.constraint(equalTo: ddayRowLabel.centerYAnchor),
            ddaySwitch.trailingAnchor.constraint(equalTo: ddayCard.trailingAnchor, constant: -16),

            ddaySep.leadingAnchor.constraint(equalTo: ddayCard.leadingAnchor, constant: 16),
            ddaySep.trailingAnchor.constraint(equalTo: ddayCard.trailingAnchor, constant: -16),

            datePicker.topAnchor.constraint(equalTo: ddaySep.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: ddayCard.leadingAnchor, constant: 16),
            datePicker.bottomAnchor.constraint(equalTo: ddayCard.bottomAnchor),
            datePickerHeightConstraint,
        ])

        // ── 알림 카드 ────────────────────────────────────────
        let notifCard = makeCard()
        scrollView.addSubview(notifCard)

        let notifRowLabel = makeRowLabel("알림 받기")
        notifSwitch.isOn = false
        notifSwitch.onTintColor = accent
        notifSwitch.translatesAutoresizingMaskIntoConstraints = false

        [notifRowLabel, notifSwitch].forEach { notifCard.addSubview($0) }

        NSLayoutConstraint.activate([
            notifCard.topAnchor.constraint(equalTo: ddayCard.bottomAnchor, constant: pad),
            notifCard.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: pad),
            notifCard.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -pad),
            notifCard.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -pad),

            notifRowLabel.topAnchor.constraint(equalTo: notifCard.topAnchor, constant: 14),
            notifRowLabel.leadingAnchor.constraint(equalTo: notifCard.leadingAnchor, constant: 16),
            notifRowLabel.bottomAnchor.constraint(equalTo: notifCard.bottomAnchor, constant: -14),
            notifSwitch.centerYAnchor.constraint(equalTo: notifRowLabel.centerYAnchor),
            notifSwitch.trailingAnchor.constraint(equalTo: notifCard.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeRowLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 16)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeSep() -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }

    private func makeTextButton(_ title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.tintColor = accent
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }

    // MARK: - Extract Shared Text

    private func extractSharedText() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = item.attachments else { return }

        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] obj, _ in
                    DispatchQueue.main.async { self?.applyText((obj as? String) ?? "") }
                }
                return
            }
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] obj, _ in
                    DispatchQueue.main.async { self?.applyText((obj as? URL)?.absoluteString ?? "") }
                }
                return
            }
        }
    }

    private func applyText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        contentTV.text = trimmed
        placeholder.isHidden = !trimmed.isEmpty
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
    }

    // MARK: - D-Day Switch

    @objc private func ddaySwitchChanged() {
        let show = ddaySwitch.isOn
        UIView.animate(withDuration: 0.25) {
            self.datePickerHeightConstraint.constant = show ? 50 : 0
            self.datePicker.alpha = show ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        extensionContext?.cancelRequest(withError: NSError(domain: "PrayAnswerShareExtension", code: 0))
    }

    @objc private func saveTapped() {
        let content = contentTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else {
            let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
            anim.values = [-8, 8, -6, 6, -3, 3, 0]
            anim.duration = 0.3
            contentTV.layer.add(anim, forKey: "shake")
            return
        }

        let prayer = PendingSharedPrayer(
            content: content,
            target: targetField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            targetDate: ddaySwitch.isOn ? datePicker.date.timeIntervalSince1970 : nil,
            notificationEnabled: notifSwitch.isOn
        )

        if let data = try? JSONEncoder().encode(prayer) {
            let defaults = UserDefaults(suiteName: appGroupID)
            defaults?.set(data, forKey: pendingKey)
            defaults?.synchronize()
        }

        guard let url = URL(string: "prayanswer://prayers") else {
            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }
        extensionContext?.open(url) { [weak self] _ in
            self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}
