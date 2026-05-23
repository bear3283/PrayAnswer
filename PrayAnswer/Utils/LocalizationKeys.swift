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
        static let statistics = NSLocalizedString("tab.statistics", value: "통계", comment: "Statistics tab title")
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

        // Setup Guide
        static let setupGuideTitle = NSLocalizedString("ai.setup_guide_title", comment: "AI setup guide title")
        static let setupGuideDescription = NSLocalizedString("ai.setup_guide_description", comment: "AI setup guide description")
        static let setupStep1Title = NSLocalizedString("ai.setup_step1_title", comment: "Setup step 1 title")
        static let setupStep1Description = NSLocalizedString("ai.setup_step1_description", comment: "Setup step 1 description")
        static let setupStep2Title = NSLocalizedString("ai.setup_step2_title", comment: "Setup step 2 title")
        static let setupStep2Description = NSLocalizedString("ai.setup_step2_description", comment: "Setup step 2 description")
        static let setupStep3Title = NSLocalizedString("ai.setup_step3_title", comment: "Setup step 3 title")
        static let setupStep3Description = NSLocalizedString("ai.setup_step3_description", comment: "Setup step 3 description")
        static let setupStep4Title = NSLocalizedString("ai.setup_step4_title", comment: "Setup step 4 title")
        static let setupStep4Description = NSLocalizedString("ai.setup_step4_description", comment: "Setup step 4 description")
        static let setupNote = NSLocalizedString("ai.setup_note", comment: "AI setup note")
        static let openSettings = NSLocalizedString("ai.open_settings", comment: "Open settings button")
        static let learnMore = NSLocalizedString("ai.learn_more", comment: "Learn more link")
    }

    // MARK: - Image Attachment & OCR
    enum Image {
        // Section
        static let attachImage = NSLocalizedString("image.attach_image", comment: "Attach image")
        static let attachedImage = NSLocalizedString("image.attached_image", comment: "Attached image")

        // Buttons
        static let selectImage = NSLocalizedString("image.select_image", comment: "Select image button")
        static let changeImage = NSLocalizedString("image.change_image", comment: "Change image button")
        static let removeImage = NSLocalizedString("image.remove_image", comment: "Remove image button")
        static let extractText = NSLocalizedString("image.extract_text", comment: "Extract text button")

        // OCR
        static let extractingText = NSLocalizedString("image.extracting_text", comment: "Extracting text status")
        static let extractedText = NSLocalizedString("image.extracted_text", comment: "Extracted text title")
        static let ocrResult = NSLocalizedString("image.ocr_result", comment: "OCR result title")
        static let ocrResultDescription = NSLocalizedString("image.ocr_result_description", comment: "OCR result description")
        static let applyToContent = NSLocalizedString("image.apply_to_content", comment: "Apply to content button")
        static let editExtractedText = NSLocalizedString("image.edit_extracted_text", comment: "Edit extracted text")

        // AI Summary
        static let aiOrganize = NSLocalizedString("image.ai_organize", comment: "AI organize button")
        static let aiOrganizing = NSLocalizedString("image.ai_organizing", comment: "AI organizing status")

        // Errors
        static let errorDirectoryCreation = NSLocalizedString("image.error_directory_creation", comment: "Directory creation error")
        static let errorSaveFailed = NSLocalizedString("image.error_save_failed", comment: "Image save failed error")
        static let errorLoadFailed = NSLocalizedString("image.error_load_failed", comment: "Image load failed error")
        static let errorDeleteFailed = NSLocalizedString("image.error_delete_failed", comment: "Image delete failed error")
        static let errorInvalidImage = NSLocalizedString("image.error_invalid_image", comment: "Invalid image error")
        static let errorOCRFailed = NSLocalizedString("image.error_ocr_failed", comment: "OCR failed error")
        static let errorNoTextFound = NSLocalizedString("image.error_no_text_found", comment: "No text found error")

        // Accessibility
        static let accessibilityAttachedImage = NSLocalizedString("image.accessibility_attached_image", comment: "Attached image accessibility")
        static let accessibilitySelectImage = NSLocalizedString("image.accessibility_select_image", comment: "Select image accessibility")
        static let accessibilityExtractText = NSLocalizedString("image.accessibility_extract_text", comment: "Extract text accessibility")
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

    // MARK: - Statistics
    enum Stats {
        static let title = NSLocalizedString("stats.title", value: "통계", comment: "Statistics screen title")
        static let totalPrayers = NSLocalizedString("stats.total_prayers", value: "전체 기도", comment: "Total prayers label")
        static let answerRate = NSLocalizedString("stats.answer_rate", value: "응답률", comment: "Answer rate label")
        static let favorites = NSLocalizedString("stats.favorites", value: "즐겨찾기", comment: "Favorites label")
        static let storageDistribution = NSLocalizedString("stats.storage_distribution", value: "보관소 분포", comment: "Storage distribution section title")
        static let monthlyActivity = NSLocalizedString("stats.monthly_activity", value: "월별 기도 추이", comment: "Monthly activity section title")
        static let categoryDistribution = NSLocalizedString("stats.category_distribution", value: "카테고리 분포", comment: "Category distribution section title")
        static let topTargets = NSLocalizedString("stats.top_targets", value: "기도 대상자 TOP 5", comment: "Top prayer targets section title")
        static let total = NSLocalizedString("stats.total", value: "전체", comment: "Total label (center of donut chart)")
        static let emptyTitle = NSLocalizedString("stats.empty_title", value: "아직 기록이 없어요", comment: "Empty statistics title")
        static let emptyDescription = NSLocalizedString("stats.empty_description", value: "기도를 기록하면\n통계를 볼 수 있어요", comment: "Empty statistics description")

        static func last6MonthsTotal(_ count: Int) -> String {
            String(format: NSLocalizedString("stats.last6months_total", value: "최근 6개월 총 %d개", comment: "Last 6 months total format"), count)
        }
    }

    // MARK: - Share
    enum Share {
        static let title = NSLocalizedString("share.title", comment: "Share title")
        static let selectPrayers = NSLocalizedString("share.select_prayers", comment: "Select prayers to share")
        static let cancel = NSLocalizedString("share.cancel", comment: "Cancel share")
        static let share = NSLocalizedString("share.share", comment: "Share button")
        static let selectAll = NSLocalizedString("share.select_all", comment: "Select all")
        static let deselectAll = NSLocalizedString("share.deselect_all", comment: "Deselect all")
        static let selectedCount = NSLocalizedString("share.selected_count", comment: "Selected count")

        static func selectedFormat(_ count: Int) -> String {
            String(format: NSLocalizedString("share.selected_format", comment: "Selected prayers format"), count)
        }
    }

    // MARK: - Attachments (복수 이미지 + PDF)
    enum Attachment {
        // Section
        static let sectionTitle = NSLocalizedString("attachment.section_title", comment: "Attachments section title")
        static let addAttachment = NSLocalizedString("attachment.add_attachment", comment: "Add attachment placeholder")

        // Buttons
        static let addImage = NSLocalizedString("attachment.add_image", comment: "Add image button")
        static let addFile = NSLocalizedString("attachment.add_file", comment: "Add file button")
        static let removeAttachment = NSLocalizedString("attachment.remove", comment: "Remove attachment button")
        static let extractAllText = NSLocalizedString("attachment.extract_all_text", comment: "Extract all text button")

        // Types
        static let typeImage = NSLocalizedString("attachment.type_image", comment: "Image type")
        static let typePDF = NSLocalizedString("attachment.type_pdf", comment: "PDF type")

        // Limits
        static let maxReached = NSLocalizedString("attachment.max_reached", comment: "Max attachments reached title")
        static let fileTooLarge = NSLocalizedString("attachment.file_too_large", comment: "File too large error")

        // Errors
        static let errorInvalidDocument = NSLocalizedString("attachment.error_invalid_document", comment: "Invalid document error")
        static let errorUnsupportedFormat = NSLocalizedString("attachment.error_unsupported_format", comment: "Unsupported format error")

        // Format strings
        static func maxReachedMessage(_ max: Int) -> String {
            String(format: NSLocalizedString("attachment.max_reached_message", comment: "Max attachments message"), max)
        }

        static func countFormat(_ count: Int) -> String {
            String(format: NSLocalizedString("attachment.count_format", comment: "Attachment count format"), count)
        }
    }

    // MARK: - Collection (폴더)
    enum Collection {
        static let navTitle = NSLocalizedString("collection.nav_title", value: "컬렉션", comment: "Collection nav title")
        static let newCollection = NSLocalizedString("collection.new", value: "새 컬렉션", comment: "New collection button")
        static let editCollection = NSLocalizedString("collection.edit", value: "컬렉션 편집", comment: "Edit collection")
        static let namePlaceholder = NSLocalizedString("collection.name_placeholder", value: "컬렉션 이름", comment: "Collection name placeholder")
        static let iconLabel = NSLocalizedString("collection.icon_label", value: "아이콘", comment: "Icon label")
        static let colorLabel = NSLocalizedString("collection.color_label", value: "색상", comment: "Color label")
        static let none = NSLocalizedString("collection.none", value: "컬렉션 없음", comment: "No collection")
        static let selectCollection = NSLocalizedString("collection.select", value: "컬렉션 선택", comment: "Select collection")
        static let deleteConfirm = NSLocalizedString("collection.delete_confirm", value: "컬렉션을 삭제하시겠습니까? 기도제목은 삭제되지 않습니다.", comment: "Delete collection confirmation")
        static let emptyTitle = NSLocalizedString("collection.empty_title", value: "컬렉션이 없어요", comment: "Empty collections title")
        static let emptyDescription = NSLocalizedString("collection.empty_description", value: "기도제목을 폴더처럼 묶어\n관리할 수 있어요", comment: "Empty collections description")

        static func prayerCount(_ count: Int) -> String {
            String(format: NSLocalizedString("collection.prayer_count", value: "%d개의 기도", comment: "Prayer count in collection"), count)
        }
    }

    // MARK: - Habit (기도 습관)
    enum Habit {
        static let navTitle = NSLocalizedString("habit.nav_title", value: "기도 습관", comment: "Habit nav title")
        static let newHabit = NSLocalizedString("habit.new", value: "새 습관", comment: "New habit button")
        static let editHabit = NSLocalizedString("habit.edit", value: "습관 편집", comment: "Edit habit")
        static let labelPlaceholder = NSLocalizedString("habit.label_placeholder", value: "예: 아침 기도, 저녁 기도", comment: "Habit label placeholder")
        static let timeSectionTitle = NSLocalizedString("habit.time_section", value: "기도 시간", comment: "Time section title")
        static let daysSectionTitle = NSLocalizedString("habit.days_section", value: "반복 요일", comment: "Days section title")
        static let notificationLabel = NSLocalizedString("habit.notification", value: "알림", comment: "Notification toggle label")
        static let checkInButton = NSLocalizedString("habit.check_in", value: "기도 완료", comment: "Check-in button title")
        static let checkedIn = NSLocalizedString("habit.checked_in", value: "완료됨", comment: "Checked in status")
        static let streakLabel = NSLocalizedString("habit.streak", value: "연속", comment: "Streak label")
        static let streakDays = NSLocalizedString("habit.streak_days", value: "일", comment: "Streak days suffix")
        static let totalCount = NSLocalizedString("habit.total_count", value: "총 완료", comment: "Total count label")
        static let thisWeek = NSLocalizedString("habit.this_week", value: "이번 주", comment: "This week label")
        static let todaySection = NSLocalizedString("habit.today_section", value: "오늘의 기도 시간", comment: "Today section title")
        static let allHabits = NSLocalizedString("habit.all_habits", value: "전체 습관", comment: "All habits section title")
        static let emptyTitle = NSLocalizedString("habit.empty_title", value: "기도 습관을 만들어보세요", comment: "Empty habits title")
        static let emptyDescription = NSLocalizedString("habit.empty_description", value: "규칙적인 기도 시간을 정하고\n알림을 받을 수 있어요", comment: "Empty habits description")
        static let deleteConfirm = NSLocalizedString("habit.delete_confirm", value: "습관을 삭제하시겠습니까? 기록도 함께 삭제됩니다.", comment: "Delete habit confirmation")
        static let notScheduledToday = NSLocalizedString("habit.not_scheduled_today", value: "오늘은 없어요", comment: "Not scheduled today")
        static let notificationTitle = NSLocalizedString("habit.notification_title", value: "🙏 기도 시간이에요", comment: "Habit notification title")
        static let notificationBody = NSLocalizedString("habit.notification_body", value: "기도할 시간입니다", comment: "Habit notification body")

        static func tabTitle() -> String { "습관" }
    }

    // MARK: - Answer Note (응답/거절 메모)
    enum AnswerNote {
        static let sectionTitle = NSLocalizedString("answer_note.section_title", value: "응답 기록", comment: "Answer note section title")
        static let placeholder = NSLocalizedString("answer_note.placeholder", value: "어떻게 응답받으셨나요? (선택 입력)", comment: "Answer note placeholder")
        static let noNote = NSLocalizedString("answer_note.no_note", value: "기록된 내용이 없습니다", comment: "No answer note")
        static let addNote = NSLocalizedString("answer_note.add_note", value: "기록 추가", comment: "Add answer note button")
        static let editNote = NSLocalizedString("answer_note.edit_note", value: "수정", comment: "Edit answer note button")
        static let save = NSLocalizedString("answer_note.save", value: "기록하기", comment: "Save answer note button")
        static let skip = NSLocalizedString("answer_note.skip", value: "건너뛰기", comment: "Skip answer note button")
        static let sheetTitleYes = NSLocalizedString("answer_note.sheet_title_yes", value: "응답받은 기도", comment: "Sheet title when moving to yes")
        static let sheetTitleNo = NSLocalizedString("answer_note.sheet_title_no", value: "응답 거절된 기도", comment: "Sheet title when moving to no")
        static let sheetPromptYes = NSLocalizedString("answer_note.sheet_prompt_yes", value: "어떻게 응답받으셨나요?", comment: "Prompt for yes answer note")
        static let sheetPromptNo = NSLocalizedString("answer_note.sheet_prompt_no", value: "어떤 결과였나요?", comment: "Prompt for no answer note")
        static let noPlaceholder = NSLocalizedString("answer_note.no_placeholder", value: "결과를 기록해보세요 (선택 입력)", comment: "Placeholder for no storage answer note")
    }

    // MARK: - Settings Tab
    enum Settings {
        static let tabTitle = NSLocalizedString("settings.tab_title", value: "설정", comment: "Settings tab title")
        static let guideSection = NSLocalizedString("settings.guide_section", value: "사용법 가이드", comment: "How to use section title")
        static let aiSection = NSLocalizedString("settings.ai_section", value: "AI · 음성 설정", comment: "AI and voice settings section")
        static let aiToggle = NSLocalizedString("settings.ai_toggle", value: "AI 요약 사용", comment: "AI summarization toggle label")
        static let aiToggleDesc = NSLocalizedString("settings.ai_toggle_desc", value: "음성 녹음 후 Apple Intelligence로 기도문을 자동 정리합니다 (iOS 18.1+, Apple Intelligence 필요)", comment: "AI toggle description")
        static let bluetoothTip = NSLocalizedString("settings.bluetooth_tip", value: "에어팟·블루투스 마이크를 연결하면 더 선명하게 녹음됩니다", comment: "Bluetooth mic tip")
        static let voiceChunkingTip = NSLocalizedString("settings.voice_chunking_tip", value: "긴 기도 나눔도 자동으로 이어 녹음됩니다 (1분 이상 지원)", comment: "Long recording tip")
        static let statsSection = NSLocalizedString("settings.stats_section", value: "기도 통계", comment: "Statistics section")
        static let statsButton = NSLocalizedString("settings.stats_button", value: "기도 통계 보기", comment: "View statistics button")
        static let statsDesc = NSLocalizedString("settings.stats_desc", value: "응답률, 카테고리 분포, 월별 기도 추이를 확인하세요", comment: "Statistics description")
        static let appSection = NSLocalizedString("settings.app_section", value: "앱 정보", comment: "App info section title")
        static let version = NSLocalizedString("settings.version", value: "버전", comment: "Version label")
        static let contact = NSLocalizedString("settings.contact", value: "문의하기", comment: "Contact button")
        static let review = NSLocalizedString("settings.review", value: "앱 평가하기", comment: "Rate app button")
        static let privacyPolicy = NSLocalizedString("settings.privacy_policy", value: "개인정보 처리방침", comment: "Privacy policy")
    }

    // MARK: - Feature Guide Cards
    enum Guide {
        static let addPrayerTitle = NSLocalizedString("guide.add_prayer_title", value: "기도제목 추가", comment: "")
        static let addPrayerDesc = NSLocalizedString("guide.add_prayer_desc", value: "하단 '추가' 탭에서 기도제목·내용·카테고리·대상자를 입력하고 저장하세요.", comment: "")
        static let storageTitle = NSLocalizedString("guide.storage_title", value: "보관소 관리", comment: "")
        static let storageDesc = NSLocalizedString("guide.storage_desc", value: "Wait·Yes·No 세 보관소로 기도 상태를 추적하세요. 상세 화면에서 보관소를 이동할 수 있습니다.", comment: "")
        static let peopleTitle = NSLocalizedString("guide.people_title", value: "여러 사람 기도", comment: "")
        static let peopleDesc = NSLocalizedString("guide.people_desc", value: "'대상자' 탭에서 사람별 기도제목을 한눈에 관리하세요. 가족·친구·공동체별로 정리됩니다.", comment: "")
        static let favoriteTitle = NSLocalizedString("guide.favorite_title", value: "즐겨찾기", comment: "")
        static let favoriteDesc = NSLocalizedString("guide.favorite_desc", value: "자주 기도하는 제목에 ♥를 표시하면 위젯과 목록 상단에서 빠르게 접근할 수 있습니다.", comment: "")
        static let habitTitle = NSLocalizedString("guide.habit_title", value: "기도 습관", comment: "")
        static let habitDesc = NSLocalizedString("guide.habit_desc", value: "'습관' 탭에서 매일 기도 체크인을 기록하세요. 연속 기도일과 주간 달력으로 꾸준함을 확인할 수 있습니다.", comment: "")
        static let widgetTitle = NSLocalizedString("guide.widget_title", value: "홈 화면 위젯", comment: "")
        static let widgetDesc = NSLocalizedString("guide.widget_desc", value: "홈 화면 길게 누르기 → 위젯 추가 → PrayAnswer. 기도제목 확인과 빠른 추가가 잠금 화면에서도 가능합니다.", comment: "")
        static let exchangeTitle = NSLocalizedString("guide.exchange_title", value: "기도 교환", comment: "")
        static let exchangeDesc = NSLocalizedString("guide.exchange_desc", value: "기도제목을 상대방과 교환하세요. 앱이 있으면 딥링크로 바로 저장, 없으면 텍스트로 전달됩니다.", comment: "")
        static let shareExtTitle = NSLocalizedString("guide.share_ext_title", value: "다른 앱에서 가져오기", comment: "")
        static let shareExtDesc = NSLocalizedString("guide.share_ext_desc", value: "카카오톡·메모 등에서 텍스트를 선택 → 공유 → PrayAnswer를 탭하면 바로 기도제목으로 추가됩니다.", comment: "")
        static let collectionTitle = NSLocalizedString("guide.collection_title", value: "컬렉션(폴더)", comment: "")
        static let collectionDesc = NSLocalizedString("guide.collection_desc", value: "기도제목을 주제별 폴더로 묶어 정리하세요. 기도제목 추가·편집 화면에서 폴더를 지정할 수 있습니다.", comment: "")
        static let answerNoteTitle = NSLocalizedString("guide.answer_note_title", value: "응답 기록", comment: "")
        static let answerNoteDesc = NSLocalizedString("guide.answer_note_desc", value: "기도가 응답받으면 Yes로 이동할 때 어떻게 응답받았는지 메모를 남겨 하나님의 역사를 기록하세요.", comment: "")
        static let voiceAITitle = NSLocalizedString("guide.voice_ai_title", value: "음성 AI 기록", comment: "")
        static let voiceAIDesc = NSLocalizedString("guide.voice_ai_desc", value: "기도제목 추가·편집 화면의 🎤 버튼으로 말하면 Apple Intelligence가 기도문으로 자동 정리해 줍니다.", comment: "")
    }

    // MARK: - Voice Recording (enhanced)
    enum VoiceEnhanced {
        static let pause = NSLocalizedString("voice.pause", value: "일시정지", comment: "Pause recording")
        static let resume = NSLocalizedString("voice.resume", value: "재개", comment: "Resume recording")
        static let paused = NSLocalizedString("voice.paused", value: "일시정지됨", comment: "Recording paused state")
        static let continuing = NSLocalizedString("voice.continuing", value: "계속 녹음 중...", comment: "Auto-chunking in progress")
        static let timerFormat = NSLocalizedString("voice.timer_format", value: "%02d:%02d", comment: "MM:SS timer format")
    }

    // MARK: - Siri / App Intents
    enum Siri {
        static let addPrayerTitle = NSLocalizedString("siri.add_prayer_title", value: "기도제목 추가", comment: "Siri add prayer intent title")
        static let addPrayerDescription = NSLocalizedString("siri.add_prayer_description", value: "새 기도제목을 추가합니다", comment: "Siri add prayer description")
        static let checkInHabitTitle = NSLocalizedString("siri.checkin_title", value: "기도 완료 체크", comment: "Siri check-in intent title")
        static let contentParam = NSLocalizedString("siri.content_param", value: "기도 내용", comment: "Content parameter")
        static let targetParam = NSLocalizedString("siri.target_param", value: "기도 대상", comment: "Target parameter")
        static let addedConfirmation = NSLocalizedString("siri.added_confirmation", value: "기도제목이 추가되었습니다", comment: "Added confirmation")
        static let checkInConfirmation = NSLocalizedString("siri.checkin_confirmation", value: "기도를 완료했습니다", comment: "Check-in confirmation")
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