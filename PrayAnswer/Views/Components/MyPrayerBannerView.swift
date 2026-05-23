import SwiftUI

/// 기도목록 상단에 표시되는 "나의 기도제목" 배너
struct MyPrayerBannerView: View {
    let prayers: [Prayer]

    @State private var isExpanded = true

    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                // 헤더
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(DesignSystem.Colors.primary)
                        .font(.system(size: 14, weight: .semibold))
                    Text("나의 기도제목")
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    if !prayers.isEmpty {
                        Text("\(prayers.count)")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(DesignSystem.Colors.primary)
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        if prayers.isEmpty {
                            // 비어있을 때
                            Text("다른 사람이 나를 위해 기도해줄 내용을 추가해보세요.")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                        } else {
                            // 기도제목 목록 (최대 3개 미리보기)
                            ForEach(prayers.prefix(3)) { prayer in
                                HStack(spacing: DesignSystem.Spacing.sm) {
                                    Circle()
                                        .fill(prayer.category.color.opacity(0.3))
                                        .frame(width: 6, height: 6)
                                    Text(prayer.content.isEmpty ? prayer.title : prayer.content)
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.primaryText)
                                }
                            }
                            if prayers.count > 3 {
                                Text("외 \(prayers.count - 3)개")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // 펼침: 위에서 아래로 내려오고, 접힘: 위로 올라가 사라짐
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(DesignSystem.Spacing.md)
            // 펼쳐지는 콘텐츠가 카드 밖으로 넘치지 않도록 클리핑
            .clipped()
        }
    }
}
