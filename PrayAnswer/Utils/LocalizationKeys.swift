//
//  LocalizationKeys.swift
//  PrayAnswer
//
//  Created for multi-language support
//

import Foundation

/// Type-safe localization keys for PrayAnswer app
/// Usage: Text(L.Tab.prayerList)
enum L {

    // MARK: - Tab Bar
    enum Tab {
        static let prayerList = NSLocalizedString("tab.prayer_list", comment: "Prayer List tab title")
        static let addPrayer = NSLocalizedString("tab.add_prayer", comment: "Add Prayer tab title")
        static let people = NSLocalizedString("tab.people", comment: "People tab title")
    }

    // MARK: - Navigation Titles
    enum Nav {
        static let prayerList = NSLocalizedString("nav.prayer_list", comment: "Prayer List navigation title")
        static let newPrayer = NSLocalizedString("nav.new_prayer", comment: "New Prayer navigation title")
        static let prayerDetail = NSLocalizedString("nav.prayer_detail", comment: "Prayer Detail navigation title")
        static let prayerEdit = NSLocalizedString("nav.prayer_edit", comment: "Edit Prayer navigation title")
        static let peopleList = NSLocalizedString("nav.people_list", comment: "People List navigation title")
        static let storageMove = NSLocalizedString("nav.storage_move", comment: "Move Storage navigation title")
    }

    // MARK: - Common Buttons
    enum Button {
        static let save = NSLocalizedString("button.save", comment: "Save button")
        static let edit = NSLocalizedString("button.edit", comment: "Edit button")
        static let delete = NSLocalizedString("button.delete", comment: "Delete button")
        static let done = NSLocalizedString("button.done", comment: "Done button")
        static let cancel = NSLocalizedString("button.cancel", comment: "Cancel button")
        static let confirm = NSLocalizedString("button.confirm", comment: "Confirm button")
        static let savePrayer = NSLocalizedString("button.save_prayer", comment: "Save Prayer button")
        static let moveStorage = NSLocalizedString("button.move_storage", comment: "Move Storage button")
    }

    // MARK: - Form Labels
    enum Label {
        static let title = NSLocalizedString("label.title", comment: "Title label")
        static let prayerContent = NSLocalizedString("label.prayer_content", comment: "Prayer Content label")
        static let category = NSLocalizedString("label.category", comment: "Category label")
        static let prayerTarget = NSLocalizedString("label.prayer_target", comment: "Prayer Target label")
        static let classification = NSLocalizedString("label.classification", comment: "Classification label")
    }

    // MARK: - Placeholders
    enum Placeholder {
        static let title = NSLocalizedString("placeholder.title", comment: "Title placeholder")
        static let content = NSLocalizedString("placeholder.content", comment: "Content placeholder")
        static let target = NSLocalizedString("placeholder.target", comment: "Target placeholder")
        static let searchPeople = NSLocalizedString("placeholder.search_people", comment: "Search people placeholder")
    }

    // MARK: - Prayer Storage
    enum Storage {
        static let wait = NSLocalizedString("storage.wait", comment: "Wait storage name")
        static let yes = NSLocalizedString("storage.yes", comment: "Yes storage name")
        static let no = NSLocalizedString("storage.no", comment: "No storage name")

        enum Description {
            static let wait = NSLocalizedString("storage.wait.description", comment: "Wait storage description")
            static let yes = NSLocalizedString("storage.yes.description", comment: "Yes storage description")
            static let no = NSLocalizedString("storage.no.description", comment: "No storage description")
        }
    }

    // MARK: - Prayer Categories
    enum Category {
        static let personal = NSLocalizedString("category.personal", comment: "Personal category")
        static let family = NSLocalizedString("category.family", comment: "Family category")
        static let health = NSLocalizedString("category.health", comment: "Health category")
        static let work = NSLocalizedString("category.work", comment: "Work category")
        static let relationship = NSLocalizedString("category.relationship", comment: "Relationship category")
        static let thanksgiving = NSLocalizedString("category.thanksgiving", comment: "Thanksgiving category")
        static let vision = NSLocalizedString("category.vision", comment: "Vision category")
        static let other = NSLocalizedString("category.other", comment: "Other category")
    }

    // MARK: - Info Labels
    enum Info {
        static let prayerInfo = NSLocalizedString("info.prayer_info", comment: "Prayer Info label")
        static let createdDate = NSLocalizedString("info.created_date", comment: "Created Date label")
        static let modifiedDate = NSLocalizedString("info.modified_date", comment: "Modified Date label")
        static let movedDate = NSLocalizedString("info.moved_date", comment: "Moved Date label")
        static let recentPrayer = NSLocalizedString("info.recent_prayer", comment: "Recent Prayer label")
        static let saveNotice = NSLocalizedString("info.save_notice", comment: "Save Notice label")
        static let saveDescription = NSLocalizedString("info.save_description", comment: "Save Description text")
    }

    // MARK: - Empty States
    enum Empty {
        static let storageTitle = NSLocalizedString("empty.storage_title", comment: "Empty storage title")
        static let peopleTitle = NSLocalizedString("empty.people_title", comment: "Empty people title")
        static let peopleDescription = NSLocalizedString("empty.people_description", comment: "Empty people description")
    }

    // MARK: - Alert Messages
    enum Alert {
        static let error = NSLocalizedString("alert.error", comment: "Error alert title")
        static let notification = NSLocalizedString("alert.notification", comment: "Notification alert title")
        static let saveComplete = NSLocalizedString("alert.save_complete", comment: "Save complete alert title")
        static let deletePrayer = NSLocalizedString("alert.delete_prayer", comment: "Delete prayer alert title")
    }

    // MARK: - Success Messages
    enum Success {
        static let saveMessage = NSLocalizedString("success.save_message", comment: "Save success message")
    }

    // MARK: - Error Messages
    enum Error {
        static let emptyFields = NSLocalizedString("error.empty_fields", comment: "Empty fields error")
        static let titleTooLong = NSLocalizedString("error.title_too_long", comment: "Title too long error")
        static let contentTooLong = NSLocalizedString("error.content_too_long", comment: "Content too long error")
        static let saveFailed = NSLocalizedString("error.save_failed", comment: "Save failed error")
        static let deleteFailed = NSLocalizedString("error.delete_failed", comment: "Delete failed error")
        static let deletePrayerFailed = NSLocalizedString("error.delete_prayer_failed", comment: "Delete prayer failed error")
        static let updateFailed = NSLocalizedString("error.update_failed", comment: "Update failed error")
        static let updatePrayerFailed = NSLocalizedString("error.update_prayer_failed", comment: "Update prayer failed error")
        static let moveFailed = NSLocalizedString("error.move_failed", comment: "Move failed error")
        static let movePrayerFailed = NSLocalizedString("error.move_prayer_failed", comment: "Move prayer failed error")
        static let favoriteFailed = NSLocalizedString("error.favorite_failed", comment: "Favorite failed error")
        static let favoriteToggleFailed = NSLocalizedString("error.favorite_toggle_failed", comment: "Favorite toggle failed error")
        static let generic = NSLocalizedString("error.generic", comment: "Generic error message")
    }

    // MARK: - Confirmation Messages
    enum Confirm {
        static let deletePrayer = NSLocalizedString("confirm.delete_prayer", comment: "Delete prayer confirmation")
    }

    // MARK: - Accessibility
    enum Accessibility {
        static let favorite = NSLocalizedString("accessibility.favorite", comment: "Favorite accessibility label")
        static let favoriteAdd = NSLocalizedString("accessibility.favorite_add", comment: "Add to favorites label")
        static let favoriteRemove = NSLocalizedString("accessibility.favorite_remove", comment: "Remove from favorites label")
        static let favoriteAddHint = NSLocalizedString("accessibility.favorite_add_hint", comment: "Add to favorites hint")
        static let favoriteRemoveHint = NSLocalizedString("accessibility.favorite_remove_hint", comment: "Remove from favorites hint")
        static let tapDetail = NSLocalizedString("accessibility.tap_detail", comment: "Tap to view details hint")

        static func storageFormat(_ storage: String, _ count: Int) -> String {
            String(format: NSLocalizedString("accessibility.storage_format", comment: "Storage format"), storage, count)
        }

        static func selectStorage(_ storage: String) -> String {
            String(format: NSLocalizedString("accessibility.select_storage", comment: "Select storage hint"), storage)
        }

        static func prayerFormat(_ title: String, _ category: String, _ storage: String, _ favorite: String) -> String {
            String(format: NSLocalizedString("accessibility.prayer_format", comment: "Prayer format"), title, category, storage, favorite)
        }
    }

    // MARK: - Date Formats
    enum Date {
        static func recentPrayerFormat(_ date: String) -> String {
            String(format: NSLocalizedString("date.recent_prayer_format", comment: "Recent prayer date format"), date)
        }
    }

    // MARK: - Counter Formats
    enum Counter {
        static let count = NSLocalizedString("counter.count", comment: "Count suffix")

        static func totalFormat(_ count: Int) -> String {
            String(format: NSLocalizedString("counter.total_format", comment: "Total count format"), count)
        }
    }

    // MARK: - Storage Picker
    enum StoragePicker {
        static let title = NSLocalizedString("storage_picker.title", comment: "Storage picker title")
        static let description = NSLocalizedString("storage_picker.description", comment: "Storage picker description")
    }

    // MARK: - Validation
    enum Validation {
        static let titleRequired = NSLocalizedString("validation.title_required", comment: "Title required validation")
        static let contentRequired = NSLocalizedString("validation.content_required", comment: "Content required validation")
    }

    // MARK: - Target (기도대상자)
    enum Target {
        static let myself = NSLocalizedString("target.myself", comment: "Myself (self) as prayer target")
        static let selectTarget = NSLocalizedString("target.select_target", comment: "Select prayer target")
        static let addNewTarget = NSLocalizedString("target.add_new", comment: "Add new target")
        static let newTargetPlaceholder = NSLocalizedString("target.new_placeholder", comment: "New target name placeholder")
        static let searchOrAddPlaceholder = NSLocalizedString("target.search_or_add_placeholder", comment: "Search or add new target placeholder")
        static let addAsNewTarget = NSLocalizedString("target.add_as_new", comment: "Add as new target")

        static func titleFormat(_ target: String, _ category: String) -> String {
            String(format: NSLocalizedString("target.title_format", comment: "Auto-generated title format"), target, category)
        }

        static func prayerForFormat(_ target: String) -> String {
            String(format: NSLocalizedString("target.prayer_for_format", comment: "Prayer for someone format"), target)
        }
    }

    // MARK: - D-Day
    enum DDay {
        static let title = NSLocalizedString("dday.title", comment: "D-Day section title")
        static let setTargetDate = NSLocalizedString("dday.set_target_date", comment: "Set target date")
        static let targetDate = NSLocalizedString("dday.target_date", comment: "Target date label")
        static let enableNotification = NSLocalizedString("dday.enable_notification", comment: "Enable notification toggle")
        static let notificationDescription = NSLocalizedString("dday.notification_description", comment: "Notification setting description")
        static let clearDate = NSLocalizedString("dday.clear_date", comment: "Clear date button")

        // D-Day 표시
        static let today = NSLocalizedString("dday.today", comment: "D-Day (today)")
        static let approaching = NSLocalizedString("dday.approaching", comment: "D-Day approaching")
        static let passed = NSLocalizedString("dday.passed", comment: "D-Day passed")

        // 알림 메시지
        static let notificationTitle = NSLocalizedString("dday.notification_title", comment: "D-Day notification title")
        static let notificationDDayTitle = NSLocalizedString("dday.notification_dday_title", comment: "D-Day notification title for D-Day")

        static func notificationWeekBefore(_ target: String) -> String {
            String(format: NSLocalizedString("dday.notification_week_before", comment: "Notification 7 days before"), target)
        }

        static func notification3DaysBefore(_ target: String) -> String {
            String(format: NSLocalizedString("dday.notification_3days_before", comment: "Notification 3 days before"), target)
        }

        static func notification1DayBefore(_ target: String) -> String {
            String(format: NSLocalizedString("dday.notification_1day_before", comment: "Notification 1 day before"), target)
        }

        static func notificationDDay(_ target: String) -> String {
            String(format: NSLocalizedString("dday.notification_dday", comment: "Notification on D-Day"), target)
        }

        static func notificationGeneric(_ target: String, _ days: Int) -> String {
            String(format: NSLocalizedString("dday.notification_generic", comment: "Generic notification"), target, days)
        }
    }

    // MARK: - Notification Settings
    enum Notification {
        // Section titles
        static let settings = NSLocalizedString("notification.settings", comment: "Notification settings title")
        static let timeSettings = NSLocalizedString("notification.time_settings", comment: "Time settings section")
        static let scheduleSettings = NSLocalizedString("notification.schedule_settings", comment: "Schedule settings section")
        static let repeatSettings = NSLocalizedString("notification.repeat_settings", comment: "Repeat settings section")

        // Time
        static let notificationTime = NSLocalizedString("notification.notification_time", comment: "Notification time label")
        static let selectTime = NSLocalizedString("notification.select_time", comment: "Select notification time")

        // Reminder days
        static let reminderDays = NSLocalizedString("notification.reminder_days", comment: "Reminder days label")
        static let selectDays = NSLocalizedString("notification.select_days", comment: "Select reminder days")
        static let noDaysSelected = NSLocalizedString("notification.no_days_selected", comment: "No days selected")
        static let noSelectedDays = NSLocalizedString("notification.no_selected_days", comment: "No selected days text")

        // Repeat types
        static let repeatType = NSLocalizedString("notification.repeat_type", comment: "Repeat type label")
        static let repeatNone = NSLocalizedString("notification.repeat_none", comment: "No repeat")
        static let repeatDaily = NSLocalizedString("notification.repeat_daily", comment: "Daily repeat")
        static let repeatWeekdays = NSLocalizedString("notification.repeat_weekdays", comment: "Weekdays repeat")
        static let repeatWeekly = NSLocalizedString("notification.repeat_weekly", comment: "Weekly repeat")
        static let repeatCustom = NSLocalizedString("notification.repeat_custom", comment: "Custom repeat")

        // Repeat descriptions
        static let repeatNoneDesc = NSLocalizedString("notification.repeat_none_desc", comment: "No repeat description")
        static let repeatDailyDesc = NSLocalizedString("notification.repeat_daily_desc", comment: "Daily repeat description")
        static let repeatWeekdaysDesc = NSLocalizedString("notification.repeat_weekdays_desc", comment: "Weekdays repeat description")
        static let repeatWeeklyDesc = NSLocalizedString("notification.repeat_weekly_desc", comment: "Weekly repeat description")
        static let repeatCustomDesc = NSLocalizedString("notification.repeat_custom_desc", comment: "Custom repeat description")

        // Weekday selection
        static let selectWeekdays = NSLocalizedString("notification.select_weekdays", comment: "Select weekdays")
        static let repeatEndDate = NSLocalizedString("notification.repeat_end_date", comment: "Repeat end date")
        static let noEndDate = NSLocalizedString("notification.no_end_date", comment: "No end date")
        static let maxRepeatCount = NSLocalizedString("notification.max_repeat_count", comment: "Max repeat count")
        static let unlimited = NSLocalizedString("notification.unlimited", comment: "Unlimited")

        // Buttons
        static let advancedSettings = NSLocalizedString("notification.advanced_settings", comment: "Advanced settings button")
        static let resetToDefault = NSLocalizedString("notification.reset_to_default", comment: "Reset to default button")

        // Preview
        static let preview = NSLocalizedString("notification.preview", comment: "Notification preview")
        static let nextNotification = NSLocalizedString("notification.next_notification", comment: "Next notification")
    }

    // MARK: - Calendar Integration
    enum Calendar {
        // Buttons
        static let addToCalendar = NSLocalizedString("calendar.add_to_calendar", comment: "Add to calendar button")
        static let removeFromCalendar = NSLocalizedString("calendar.remove_from_calendar", comment: "Remove from calendar button")
        static let openCalendar = NSLocalizedString("calendar.open_calendar", comment: "Open calendar app button")

        // Status
        static let addedToCalendar = NSLocalizedString("calendar.added_to_calendar", comment: "Added to calendar status")
        static let notInCalendar = NSLocalizedString("calendar.not_in_calendar", comment: "Not in calendar status")

        // Alerts
        static let permissionRequired = NSLocalizedString("calendar.permission_required", comment: "Calendar permission required")
        static let permissionMessage = NSLocalizedString("calendar.permission_message", comment: "Calendar permission message")
        static let openSettings = NSLocalizedString("calendar.open_settings", comment: "Open settings button")

        // Success/Error
        static let addSuccess = NSLocalizedString("calendar.add_success", comment: "Calendar add success message")
        static let removeSuccess = NSLocalizedString("calendar.remove_success", comment: "Calendar remove success message")
        static let addFailed = NSLocalizedString("calendar.add_failed", comment: "Calendar add failed message")
        static let removeFailed = NSLocalizedString("calendar.remove_failed", comment: "Calendar remove failed message")

        // Event content
        static func eventTitle(_ target: String) -> String {
            String(format: NSLocalizedString("calendar.event_title", comment: "Calendar event title"), target)
        }

        static func eventNotes(_ title: String, _ content: String) -> String {
            String(format: NSLocalizedString("calendar.event_notes", comment: "Calendar event notes"), title, content)
        }

        // Error messages
        static let errorPermissionDenied = NSLocalizedString("calendar.error_permission_denied", comment: "Calendar permission denied error")
        static let errorEventNotFound = NSLocalizedString("calendar.error_event_not_found", comment: "Calendar event not found error")
        static let errorUnknown = NSLocalizedString("calendar.error_unknown", comment: "Calendar unknown error")

        static func errorSaveFailed(_ description: String) -> String {
            String(format: NSLocalizedString("calendar.error_save_failed", comment: "Calendar save failed error"), description)
        }

        static func errorDeleteFailed(_ description: String) -> String {
            String(format: NSLocalizedString("calendar.error_delete_failed", comment: "Calendar delete failed error"), description)
        }
    }

    // MARK: - Weekday Names
    enum Weekday {
        static let sunday = NSLocalizedString("weekday.sunday", comment: "Sunday")
        static let monday = NSLocalizedString("weekday.monday", comment: "Monday")
        static let tuesday = NSLocalizedString("weekday.tuesday", comment: "Tuesday")
        static let wednesday = NSLocalizedString("weekday.wednesday", comment: "Wednesday")
        static let thursday = NSLocalizedString("weekday.thursday", comment: "Thursday")
        static let friday = NSLocalizedString("weekday.friday", comment: "Friday")
        static let saturday = NSLocalizedString("weekday.saturday", comment: "Saturday")

        static let sundayShort = NSLocalizedString("weekday.sunday_short", comment: "Sun")
        static let mondayShort = NSLocalizedString("weekday.monday_short", comment: "Mon")
        static let tuesdayShort = NSLocalizedString("weekday.tuesday_short", comment: "Tue")
        static let wednesdayShort = NSLocalizedString("weekday.wednesday_short", comment: "Wed")
        static let thursdayShort = NSLocalizedString("weekday.thursday_short", comment: "Thu")
        static let fridayShort = NSLocalizedString("weekday.friday_short", comment: "Fri")
        static let saturdayShort = NSLocalizedString("weekday.saturday_short", comment: "Sat")
    }

    // MARK: - AI Summarization
    enum AI {
        // Status
        static let processing = NSLocalizedString("ai.processing", comment: "AI processing status")
        static let summarizing = NSLocalizedString("ai.summarizing", comment: "AI summarizing text")

        // Buttons
        static let summarize = NSLocalizedString("ai.summarize", comment: "AI summarize button")
        static let retry = NSLocalizedString("ai.retry", comment: "AI retry button")
        static let apply = NSLocalizedString("ai.apply", comment: "Apply AI result button")
        static let useOriginal = NSLocalizedString("ai.use_original", comment: "Use original text button")

        // Preview
        static let summaryResult = NSLocalizedString("ai.summary_result", comment: "AI summary result title")
        static let summaryResultDescription = NSLocalizedString("ai.summary_result_description", comment: "AI summary result description")
        static let originalText = NSLocalizedString("ai.original_text", comment: "Original text tab")
        static let summarizedText = NSLocalizedString("ai.summarized_text", comment: "Summarized text tab")
        static let originalRecording = NSLocalizedString("ai.original_recording", comment: "Original recording label")
        static let aiSummarized = NSLocalizedString("ai.ai_summarized", comment: "AI summarized label")
        static let characters = NSLocalizedString("ai.characters", comment: "Characters count suffix")
        static let reduction = NSLocalizedString("ai.reduction", comment: "Reduction percentage label")
        static let originalLength = NSLocalizedString("ai.original_length", comment: "Original length label")
        static let summarizedLength = NSLocalizedString("ai.summarized_length", comment: "Summarized length label")

        // Availability
        static let notAvailable = NSLocalizedString("ai.not_available", comment: "AI not available message")
        static let requiresAppleIntelligence = NSLocalizedString("ai.requires_apple_intelligence", comment: "Requires Apple Intelligence")

        // Errors
        static let errorEmptyInput = NSLocalizedString("ai.error_empty_input", comment: "Empty input error")
        static let errorNotAvailable = NSLocalizedString("ai.error_not_available", comment: "AI not available error")
        static let errorDeviceNotSupported = NSLocalizedString("ai.error_device_not_supported", comment: "Device not supported error")
        static let errorAppleIntelligenceDisabled = NSLocalizedString("ai.error_apple_intelligence_disabled", comment: "Apple Intelligence disabled error")
        static let errorModelNotReady = NSLocalizedString("ai.error_model_not_ready", comment: "Model not ready error")
        static let errorSummarizationFailed = NSLocalizedString("ai.error_summarization_failed", comment: "Summarization failed error")
        static let errorUnknown = NSLocalizedString("ai.error_unknown", comment: "Unknown AI error")
        static let errorRequiresiOS26 = NSLocalizedString("ai.error_requires_ios26", comment: "Requires iOS 26 error")
        static let errorUserDisabled = NSLocalizedString("ai.error_user_disabled", comment: "AI disabled by user")

        // Settings
        static let settingsTitle = NSLocalizedString("ai.settings_title", comment: "AI settings title")
        static let enableFeature = NSLocalizedString("ai.enable_feature", comment: "Enable AI feature toggle")
        static let enableFeatureDescription = NSLocalizedString("ai.enable_feature_description", comment: "AI feature description")
    }

    // MARK: - Voice Recording
    enum Voice {
        // Status
        static let recording = NSLocalizedString("voice.recording", comment: "Recording status")
        static let listening = NSLocalizedString("voice.listening", comment: "Listening status")
        static let tapToStart = NSLocalizedString("voice.tap_to_start", comment: "Tap to start recording hint")
        static let tapToStop = NSLocalizedString("voice.tap_to_stop", comment: "Tap to stop recording hint")

        // Buttons
        static let startRecording = NSLocalizedString("voice.start_recording", comment: "Start recording button")
        static let stopRecording = NSLocalizedString("voice.stop_recording", comment: "Stop recording button")
        static let useText = NSLocalizedString("voice.use_text", comment: "Use recognized text button")
        static let cancel = NSLocalizedString("voice.cancel", comment: "Cancel recording button")
        static let retry = NSLocalizedString("voice.retry", comment: "Retry recording button")

        // Permissions
        static let permissionRequired = NSLocalizedString("voice.permission_required", comment: "Permission required title")
        static let microphonePermission = NSLocalizedString("voice.microphone_permission", comment: "Microphone permission message")
        static let speechPermission = NSLocalizedString("voice.speech_permission", comment: "Speech recognition permission message")
        static let openSettings = NSLocalizedString("voice.open_settings", comment: "Open settings button")

        // Errors
        static let errorRecordingFailed = NSLocalizedString("voice.error_recording_failed", comment: "Recording failed error")
        static let errorRecognizerUnavailable = NSLocalizedString("voice.error_recognizer_unavailable", comment: "Recognizer unavailable error")
        static let errorRequestFailed = NSLocalizedString("voice.error_request_failed", comment: "Request failed error")
        static let errorPermissionDenied = NSLocalizedString("voice.error_permission_denied", comment: "Permission denied error")
        static let errorAudioSession = NSLocalizedString("voice.error_audio_session", comment: "Audio session error")
        static let errorNoText = NSLocalizedString("voice.error_no_text", comment: "No text recognized error")

        // Accessibility
        static let microphoneButton = NSLocalizedString("voice.accessibility_microphone", comment: "Microphone button accessibility")
        static let recordingHint = NSLocalizedString("voice.accessibility_recording_hint", comment: "Recording hint accessibility")
    }
}

// MARK: - Prayer Storage Extension for Localization

extension PrayerStorage {
    var localizedDisplayName: String {
        switch self {
        case .wait:
            return L.Storage.wait
        case .yes:
            return L.Storage.yes
        case .no:
            return L.Storage.no
        }
    }

    var localizedDescription: String {
        switch self {
        case .wait:
            return L.Storage.Description.wait
        case .yes:
            return L.Storage.Description.yes
        case .no:
            return L.Storage.Description.no
        }
    }

    var storageDescription: String {
        return localizedDescription
    }
}

// MARK: - Prayer Category Extension for Localization

extension PrayerCategory {
    var localizedDisplayName: String {
        switch self {
        case .personal:
            return L.Category.personal
        case .family:
            return L.Category.family
        case .health:
            return L.Category.health
        case .work:
            return L.Category.work
        case .relationship:
            return L.Category.relationship
        case .thanksgiving:
            return L.Category.thanksgiving
        case .vision:
            return L.Category.vision
        case .other:
            return L.Category.other
        }
    }
}