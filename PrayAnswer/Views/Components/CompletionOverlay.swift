//
//  CompletionOverlay.swift
//  PrayAnswer
//
//  저장·보관소 이동이 끝났음을 알리는 오버레이.
//  시스템 알림창 대신, 목적지 보관소의 색과 아이콘을 그대로 입어
//  "어디로 갔는지"를 글보다 먼저 색으로 말한다.
//

import SwiftUI

struct CompletionOverlay: View {
    /// 결과가 놓인 보관소 — 색·아이콘·글로우가 모두 여기서 나온다
    let storage: PrayerStorage
    let title: String
    let message: String
    let buttonTitle: String
    let onDismiss: () -> Void

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // 배경 어둡게 — 탭하면 닫힌다
            Color.black.opacity(appeared ? 0.35 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            card
                .scaleEffect(cardScale)
                .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(entranceAnimation) { appeared = true }
        }
        .accessibilityAddTraits(.isModal)
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            storageMark

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: dismiss) {
                Text(buttonTitle)
                    .font(DesignSystem.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(storage.color)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: 320)
        .background(DesignSystem.Colors.background)
        .cornerRadius(DesignSystem.CornerRadius.extraLarge)
        .shadow(
            color: DesignSystem.Shadow.large.color,
            radius: DesignSystem.Shadow.large.radius,
            x: DesignSystem.Shadow.large.x,
            y: DesignSystem.Shadow.large.y
        )
        .padding(.horizontal, DesignSystem.Spacing.xxxl)
    }

    /// 보관소 원 + 글로우 — 빈 보관소 화면에 쓰는 것과 같은 표식이라,
    /// 이동이 끝나고 목록에 도착했을 때 같은 형태가 이어진다.
    private var storageMark: some View {
        Image(systemName: storage.iconName)
            .font(.system(size: 40, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 72, height: 72)
            .background(storage.color)
            .clipShape(Circle())
            .shadow(color: storage.color.opacity(0.35), radius: 14, x: 0, y: 5)
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(storage.color, DesignSystem.Colors.background)
                    .offset(x: 4, y: 4)
            }
            .scaleEffect(markScale)
    }

    // MARK: - Motion

    private var entranceAnimation: Animation? {
        reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.38, dampingFraction: 0.8)
    }

    private var cardScale: CGFloat {
        guard !reduceMotion else { return 1 }
        return appeared ? 1 : 0.88
    }

    private var markScale: CGFloat {
        guard !reduceMotion else { return 1 }
        return appeared ? 1 : 0.6
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) { appeared = false }
        // 사라지는 애니메이션이 끝난 뒤 상태를 정리한다
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

// MARK: - 편의 생성자

extension CompletionOverlay {

    /// 보관소 이동 완료
    static func moved(to storage: PrayerStorage, onDismiss: @escaping () -> Void) -> CompletionOverlay {
        CompletionOverlay(
            storage: storage,
            title: L.Completion.movedTitle(storage),
            message: L.Completion.movedMessage(storage),
            buttonTitle: L.Completion.confirm,
            onDismiss: onDismiss
        )
    }

    /// 기도 저장 완료 (항상 대기중 보관소로 들어간다)
    static func saved(count: Int, onDismiss: @escaping () -> Void) -> CompletionOverlay {
        CompletionOverlay(
            storage: .wait,
            title: count > 1 ? L.Completion.savedTitleMultiple(count) : L.Completion.savedTitle,
            message: L.Completion.savedMessage(PrayerStorage.wait.displayName),
            buttonTitle: L.Completion.openList,
            onDismiss: onDismiss
        )
    }
}
