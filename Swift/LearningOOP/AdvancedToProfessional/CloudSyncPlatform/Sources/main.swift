import Foundation
import Rainbow
import RxSwift
import Logging
import RealmSwift

// MARK: - CloudSyncPlatform Application

/// Main application class
class CloudSyncApp {
    // MARK: - Properties
    
    /// Disposable bag
    private let disposeBag = DisposeBag()
    
    /// Flag to indicate if the app is running
    private var isRunning = true
    
    /// Logger
    private let logger = Logger(label: "com.cloudsync.main")
    
    /// Console UI manager
    private let ui = ConsoleUI.shared
    
    /// Storage manager
    private let storageManager = StorageManager.shared
    
    /// Network manager
    private let networkManager = NetworkManager.shared
    
    /// Security manager
    private let securityManager = SecurityManager.shared
    
    // MARK: - Dependencies
    
    /// Configuration manager
    private let configManager = ConfigurationManager.shared
    
    /// File repository
    private let fileRepository: any FileRepository
    
    /// Cloud repository
    private let cloudRepository: CloudRepository
    
    /// Sync service
    private let syncService: SyncServiceProtocol
    
    /// Current user
    private var currentUser: User?
    
    // MARK: - Initialization
    
    init() {
        do {
            // Initialize repositories
            let fileRepo = try FileRepositoryImpl()
            self.fileRepository = fileRepo
            
            // Initialize cloud repository
            self.cloudRepository = CloudRepositoryImpl()
            
            // Initialize sync strategy factory
            let strategyFactory = SyncStrategyFactory()
            
            // Initialize sync service
            self.syncService = SyncService(
                fileRepository: fileRepo,
                cloudRepository: cloudRepository,
                strategyFactory: strategyFactory,
                initialStrategyType: SyncStrategyType.delta,
                maxConcurrentSyncs: configManager.getValue(for: "maxConcurrentUploads", defaultValue: 3)
            )
            
            // Create a demo user
            self.currentUser = User(
                id: "user123",
                username: "demo_user",
                email: "demo@example.com",
                displayName: "Demo User",
                profilePictureURL: nil,
                createdAt: Date(),
                lastLoginAt: Date(),
                storageQuota: 1024 * 1024 * 1024 * 5, // 5 GB
                usedStorage: 1024 * 1024 * 256, // 256 MB
                roles: [.user],
                preferences: UserPreferences(),
                authProvider: .email,
                status: .active
            )
            
            // Set up sync service observers
            setupSyncObservers()
            
            logger.info("CloudSyncPlatform initialized successfully")
        } catch {
            logger.error("Failed to initialize CloudSyncPlatform: \(error.localizedDescription)")
            fatalError("Failed to initialize application: \(error.localizedDescription)")
        }
    }
    
    /// Set up sync service observers
    private func setupSyncObservers() {
        // Create a sync observer
        let observer = SyncEventObserver { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .syncStarted(let file):
                self.ui.printInfo("Started syncing: \(file.name)")
                
            case .syncProgress(let file, let progress):
                // Only print progress updates occasionally to avoid console spam
                if Int(progress * 100) % 25 == 0 {
                    self.ui.printProgressBar(progress: progress, title: "Syncing \(file.name)")
                }
                
            case .syncCompleted(let file, let result):
                if result.success {
                    self.ui.printSuccess("Successfully synced: \(file.name) (\(result.bytesTransferred) bytes in \(String(format: "%.2f", result.timeTaken))s)")
                } else if let error = result.errorMessage {
                    self.ui.printError("Failed to sync \(file.name): \(error)")
                }
                
            case .syncFailed(let file, let error):
                self.ui.printError("Sync failed for \(file.name): \(error.localizedDescription)")
                
            case .conflictDetected(let localFile, let remoteFile):
                self.ui.printWarning("Conflict detected for \(localFile.name) (local version: \(localFile.version), remote version: \(remoteFile.version))")
                
            case .batchSyncStarted(let fileCount):
                self.ui.printInfo("Started syncing \(fileCount) files")
                
            case .batchSyncCompleted(let results):
                let successCount = results.filter { $0.success }.count
                self.ui.printInfo("Completed syncing \(successCount)/\(results.count) files")
                
            case .syncQueueUpdated(let pendingCount):
                if pendingCount > 0 {
                    self.ui.printInfo("\(pendingCount) files pending sync")
                }
            }
        }
        
        // Add observer to sync service
        syncService.addObserver(observer)
    }
    
    // MARK: - Application Methods
    
    /// Run the application
    func run() {
        ui.printHeader("CloudSyncPlatform")
        
        // Show welcome message
        if let user = currentUser {
            ui.printSuccess("Welcome back, \(user.displayName)!")
        } else {
            ui.printInfo("Welcome to CloudSyncPlatform!")
        }
        
        // Main application loop
        while isRunning {
            showMainMenu()
        }
        
        ui.printInfo("Thank you for using CloudSyncPlatform!")
    }
    
    // MARK: - Menu Methods
    
    /// Show the main menu
    private func showMainMenu() {
        ui.printMenu([
            "View Files",
            "Upload File",
            "Download File",
            "Sync Settings",
            "User Settings",
            "System Information",
            "Exit"
        ], title: "Main Menu")
        
        guard let choice = readLine(), let option = Int(choice) else {
            ui.printError("Invalid choice. Please enter a number.")
            return
        }
        
        switch option {
        case 1:
            showFilesMenu()
        case 2:
            uploadFile()
        case 3:
            downloadFile()
        case 4:
            showSyncSettingsMenu()
        case 5:
            showUserSettingsMenu()
        case 6:
            showSystemInfo()
        case 7:
            isRunning = false
        default:
            ui.printError("Invalid choice. Please enter a number between 1 and 7.")
        }
    }
    
    /// Show files menu
    private func showFilesMenu() {
        ui.printSubheader("Files")
        
        ui.printMenu([
            "All Files",
            "Recent Files",
            "Starred Files",
            "Files with Sync Errors",
            "Back to Main Menu"
        ], title: "Files Menu")
        
        guard let choice = readLine(), let option = Int(choice) else {
            ui.printError("Invalid choice. Please enter a number.")
            return
        }
        
        switch option {
        case 1:
            showAllFiles()
        case 2:
            showRecentFiles()
        case 3:
            showStarredFiles()
        case 4:
            showFilesWithErrors()
        case 5:
            return
        default:
            ui.printError("Invalid choice. Please enter a number between 1 and 5.")
        }
    }
    
    /// Show all files
    private func showAllFiles() {
        ui.printSubheader("All Files")
        
        fileRepository.getAll()
            .subscribe(
                onNext: { files in
                    if files.isEmpty {
                        self.ui.printInfo("No files found.")
                        return
                    }
                    
                    self.ui.printFileList(files)
                },
                onError: { error in
                    self.ui.printError("Failed to fetch files: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Show recent files
    private func showRecentFiles() {
        ui.printSubheader("Recent Files")
        
        fileRepository.getRecentlyModified(limit: 10)
            .subscribe(
                onNext: { files in
                    if files.isEmpty {
                        self.ui.printInfo("No recent files found.")
                        return
                    }
                    
                    self.ui.printFileList(files)
                },
                onError: { error in
                    self.ui.printError("Failed to fetch recent files: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Show starred files
    private func showStarredFiles() {
        ui.printSubheader("Starred Files")
        
        fileRepository.getStarredFiles()
            .subscribe(
                onNext: { files in
                    if files.isEmpty {
                        self.ui.printInfo("No starred files found.")
                        return
                    }
                    
                    self.ui.printFileList(files)
                },
                onError: { error in
                    self.ui.printError("Failed to fetch starred files: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Show files with sync errors
    private func showFilesWithErrors() {
        ui.printSubheader("Files with Sync Errors")
        
        fileRepository.getFilesWithErrors()
            .subscribe(
                onNext: { files in
                    if files.isEmpty {
                        self.ui.printInfo("No files with errors found.")
                        return
                    }
                    
                    self.ui.printFileList(files)
                },
                onError: { error in
                    self.ui.printError("Failed to fetch files with errors: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Upload a file
    private func uploadFile() {
        ui.printSubheader("Upload File")
        
        // Get file path from user
        guard let filePath = ui.readLine(prompt: "Enter the full path to the file: ") else {
            ui.printError("Invalid file path.")
            return
        }
        
        // Check if file exists
        let fileURL = URL(fileURLWithPath: filePath)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            ui.printError("File does not exist: \(filePath)")
            return
        }
        
        // Get file attributes
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let fileSize = attributes[.size] as? NSNumber else {
            ui.printError("Failed to get file attributes.")
            return
        }
        
        // Check file size
        let maxFileSize = configManager.getValue(for: "maxFileSize", defaultValue: 104857600) // 100 MB
        if fileSize.int64Value > maxFileSize {
            ui.printError("File is too large. Maximum file size is \(ByteCountFormatter.string(fromByteCount: Int64(maxFileSize), countStyle: .file)).")
            return
        }
        
        // Get file data
        guard let fileData = try? Data(contentsOf: fileURL) else {
            ui.printError("Failed to read file data.")
            return
        }
        
        // Calculate content hash
        let contentHash = fileData.sha256Hash
        
        // Create sync file
        let syncFile = SyncFile(
            name: fileURL.lastPathComponent,
            path: "/", // Root path
            size: fileSize.int64Value,
            mimeType: mimeType(for: fileURL),
            contentHash: contentHash,
            ownerId: currentUser?.id ?? "unknown",
            syncStatus: .pending
        )
        
        // Save file content
        storageManager.saveFile(data: fileData, to: "/\(fileURL.lastPathComponent)")
            .flatMap { _ -> Observable<SyncFile> in
                // Create file in repository
                return self.fileRepository.create(syncFile)
            }
            .flatMap { file -> Observable<SyncResult> in
                // Sync file
                return self.syncService.synchronize(file: file)
            }
            .subscribe(
                onNext: { result in
                    if result.success {
                        self.ui.printSuccess("File uploaded and synced successfully: \(syncFile.name)")
                    } else if let error = result.errorMessage {
                        self.ui.printError("Failed to sync file: \(error)")
                    }
                },
                onError: { error in
                    self.ui.printError("Failed to upload file: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Get MIME type for a file URL
    private func mimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "txt":
            return "text/plain"
        case "html", "htm":
            return "text/html"
        case "css":
            return "text/css"
        case "js":
            return "application/javascript"
        case "json":
            return "application/json"
        case "xml":
            return "application/xml"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "pdf":
            return "application/pdf"
        case "doc", "docx":
            return "application/msword"
        case "xls", "xlsx":
            return "application/vnd.ms-excel"
        case "ppt", "pptx":
            return "application/vnd.ms-powerpoint"
        case "zip":
            return "application/zip"
        case "mp3":
            return "audio/mpeg"
        case "mp4":
            return "video/mp4"
        default:
            return "application/octet-stream"
        }
    }
    
    /// Download a file
    private func downloadFile() {
        ui.printSubheader("Download File")
        
        // Fetch all files
        fileRepository.getAll()
            .subscribe(
                onNext: { files in
                    if files.isEmpty {
                        self.ui.printInfo("No files found.")
                        return
                    }
                    
                    // Display files
                    self.ui.printFileList(files)
                    
                    // Ask user to select a file
                    guard let choice = self.ui.readLine(prompt: "Enter the number of the file to download: "),
                          let fileIndex = Int(choice),
                          fileIndex > 0 && fileIndex <= files.count else {
                        self.ui.printError("Invalid file selection.")
                        return
                    }
                    
                    let selectedFile = files[fileIndex - 1]
                    
                    // Ask for download location
                    guard let downloadPath = self.ui.readLine(prompt: "Enter the download path (leave empty for Downloads folder): ") else {
                        self.ui.printError("Invalid download path.")
                        return
                    }
                    
                    // Determine download location
                    let downloadURL: URL
                    if downloadPath.isEmpty {
                        // Use Downloads folder
                        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                            self.ui.printError("Could not access Downloads folder.")
                            return
                        }
                        downloadURL = downloadsURL.appendingPathComponent(selectedFile.name)
                    } else {
                        // Use specified path
                        downloadURL = URL(fileURLWithPath: downloadPath).appendingPathComponent(selectedFile.name)
                    }
                    
                    // Ensure directory exists
                    let directory = downloadURL.deletingLastPathComponent()
                    do {
                        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                    } catch {
                        self.ui.printError("Failed to create directory: \(error.localizedDescription)")
                        return
                    }
                    
                    // Download file
                    self.ui.printInfo("Downloading \(selectedFile.name) to \(downloadURL.path)...")
                    
                    self.fileRepository.getFileContent(id: selectedFile.id.uuidString)
                        .subscribe(
                            onNext: { data in
                                do {
                                    try data.write(to: downloadURL)
                                    self.ui.printSuccess("File downloaded successfully to \(downloadURL.path)")
                                } catch {
                                    self.ui.printError("Failed to save file: \(error.localizedDescription)")
                                }
                            },
                            onError: { error in
                                self.ui.printError("Failed to download file: \(error.localizedDescription)")
                            }
                        )
                        .disposed(by: self.disposeBag)
                },
                onError: { error in
                    self.ui.printError("Failed to fetch files: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Show sync settings menu
    private func showSyncSettingsMenu() {
        ui.printSubheader("Sync Settings")
        
        ui.printMenu([
            "Change Sync Strategy",
            "Configure Auto-Sync",
            "View Sync Queue",
            "Sync All Pending",
            "Back to Main Menu"
        ])
        
        guard let choice = readLine(), let option = Int(choice) else {
            ui.printError("Invalid choice. Please enter a number.")
            return
        }
        
        switch option {
        case 1:
            changeSyncStrategy()
        case 2:
            configureAutoSync()
        case 3:
            viewSyncQueue()
        case 4:
            syncAllPending()
        case 5:
            return
        default:
            ui.printError("Invalid choice. Please enter a number between 1 and 5.")
        }
    }
    
    /// Change sync strategy
    private func changeSyncStrategy() {
        ui.printSubheader("Change Sync Strategy")
        
        // Get current strategy
        let currentStrategy = syncService.getCurrentStrategy()
        ui.printInfo("Current sync strategy: \(currentStrategy.name)")
        ui.printInfo("Description: \(currentStrategy.description)")
        
        ui.printMenu([
            "Full Sync",
            "Delta Sync",
            "Scheduled Sync",
            "Selective Sync",
            "Back"
        ])
        
        guard let choice = readLine(), let option = Int(choice) else {
            ui.printError("Invalid choice. Please enter a number.")
            return
        }
        
        // Set new strategy
        switch option {
        case 1:
            syncService.setStrategy(strategyType: SyncStrategyType.full)
            ui.printSuccess("Changed sync strategy to Full Sync")
        case 2:
            syncService.setStrategy(strategyType: SyncStrategyType.delta)
            ui.printSuccess("Changed sync strategy to Delta Sync")
        case 3:
            syncService.setStrategy(strategyType: SyncStrategyType.scheduled)
            ui.printSuccess("Changed sync strategy to Scheduled Sync")
        case 4:
            syncService.setStrategy(strategyType: SyncStrategyType.selective)
            ui.printSuccess("Changed sync strategy to Selective Sync")
        case 5:
            return
        default:
            ui.printError("Invalid choice. Please enter a number between 1 and 5.")
        }
    }
    
    /// Configure auto-sync
    private func configureAutoSync() {
        ui.printSubheader("Configure Auto-Sync")
        
        // Get current auto-sync setting
        let autoSyncEnabled = configManager.getValue(for: "autoSyncEnabled", defaultValue: true)
        let syncInterval = configManager.getValue(for: "syncInterval", defaultValue: 300) // 5 minutes
        
        ui.printInfo("Auto-sync is currently \(autoSyncEnabled ? "enabled" : "disabled")")
        if autoSyncEnabled {
            ui.printInfo("Sync interval: \(syncInterval) seconds")
        }
        
        // Ask if user wants to change auto-sync setting
        let enableAutoSync = ui.readYesNo(prompt: "Do you want to enable auto-sync?")
        
        // Update auto-sync setting
        configManager.setValue(enableAutoSync, for: "autoSyncEnabled")
        
        if enableAutoSync {
            // Ask for sync interval
            ui.printInfo("Enter sync interval in seconds (minimum 60):")
            if let intervalInput = readLine(), let interval = Int(intervalInput), interval >= 60 {
                configManager.setValue(interval, for: "syncInterval")
                ui.printSuccess("Auto-sync enabled with interval of \(interval) seconds")
            } else {
                configManager.setValue(300, for: "syncInterval") // Default to 5 minutes
                ui.printWarning("Invalid interval. Using default of 300 seconds (5 minutes)")
            }
        } else {
            ui.printSuccess("Auto-sync disabled")
        }
    }
    
    /// View sync queue
    private func viewSyncQueue() {
        ui.printSubheader("Sync Queue")
        
        // Get pending files
        fileRepository.getPendingSyncFiles()
            .subscribe(
                onNext: { files in
                    if files.isEmpty {
                        self.ui.printInfo("No files pending synchronization.")
                        return
                    }
                    
                    self.ui.printInfo("\(files.count) files pending synchronization:")
                    self.ui.printFileList(files)
                },
                onError: { error in
                    self.ui.printError("Failed to fetch pending files: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Sync all pending files
    private func syncAllPending() {
        ui.printSubheader("Sync All Pending")
        
        // Get pending files
        fileRepository.getPendingSyncFiles()
            .flatMap { files -> Observable<[SyncResult]> in
                if files.isEmpty {
                    self.ui.printInfo("No files pending synchronization.")
                    return Observable.just([])
                }
                
                self.ui.printInfo("Syncing \(files.count) files...")
                return self.syncService.synchronizeBatch(files: files)
            }
            .subscribe(
                onNext: { results in
                    if results.isEmpty {
                        return
                    }
                    
                    let successCount = results.filter { $0.success }.count
                    let failureCount = results.count - successCount
                    
                    self.ui.printSuccess("Sync completed: \(successCount) succeeded, \(failureCount) failed")
                    
                    // Show failed files if any
                    if failureCount > 0 {
                        self.ui.printWarning("Failed files:")
                        for result in results where !result.success {
                            if let error = result.errorMessage {
                                self.ui.printError("\(result.file.name): \(error)")
                            }
                        }
                    }
                },
                onError: { error in
                    self.ui.printError("Failed to sync files: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    /// Show user settings menu
    private func showUserSettingsMenu() {
        ui.printSubheader("User Settings")
        
        ui.printMenu([
            "View Profile",
            "Change Display Name",
            "Notification Settings",
            "Theme Settings",
            "Back to Main Menu"
        ])
        
        guard let choice = readLine(), let option = Int(choice) else {
            ui.printError("Invalid choice. Please enter a number.")
            return
        }
        
        switch option {
        case 1:
            viewProfile()
        case 2:
            changeDisplayName()
        case 3:
            notificationSettings()
        case 4:
            themeSettings()
        case 5:
            return
        default:
            ui.printError("Invalid choice. Please enter a number between 1 and 5.")
        }
    }
    
    /// View user profile
    private func viewProfile() {
        ui.printSubheader("User Profile")
        
        guard let user = currentUser else {
            ui.printError("No user is currently logged in.")
            return
        }
        
        print("Username: ".lightBlue + user.username)
        print("Display Name: ".lightBlue + user.displayName)
        print("Email: ".lightBlue + user.email)
        print("Account Type: ".lightBlue + user.roles.map { $0.rawValue.capitalized }.joined(separator: ", "))
        print("Account Status: ".lightBlue + user.status.rawValue.capitalized)
        print("Created: ".lightBlue + user.createdAt.formatted(date: .abbreviated, time: .shortened))
        
        if let lastLogin = user.lastLoginAt {
            print("Last Login: ".lightBlue + lastLogin.formatted(date: .abbreviated, time: .shortened))
        }
        
        print("\nStorage Usage:".lightBlue)
        ui.printProgressBar(progress: user.storageUsagePercentage / 100.0, width: 50, title: "Storage")
        print("\(user.formattedUsedStorage) used of \(user.formattedStorageQuota) (\(String(format: "%.1f", user.storageUsagePercentage))%)")
    }
    
    /// Change display name
    private func changeDisplayName() {
        ui.printSubheader("Change Display Name")
        
        guard var user = currentUser else {
            ui.printError("No user is currently logged in.")
            return
        }
        
        ui.printInfo("Current display name: \(user.displayName)")
        
        guard let newName = ui.readLine(prompt: "Enter new display name: ") else {
            ui.printError("Invalid input.")
            return
        }
        
        if newName.isEmpty {
            ui.printError("Display name cannot be empty.")
            return
        }
        
        // Update display name
        user.displayName = newName
        currentUser = user
        
        ui.printSuccess("Display name updated to: \(newName)")
    }
    
    /// Notification settings
    private func notificationSettings() {
        ui.printSubheader("Notification Settings")
        
        guard var user = currentUser else {
            ui.printError("No user is currently logged in.")
            return
        }
        
        // Display current settings
        ui.printInfo("Current notification settings:")
        print("Sync Completed: ".lightBlue + (user.preferences.notifications.syncCompleted ? "Enabled" : "Disabled"))
        print("Sync Errors: ".lightBlue + (user.preferences.notifications.syncErrors ? "Enabled" : "Disabled"))
        print("Sharing: ".lightBlue + (user.preferences.notifications.sharing ? "Enabled" : "Disabled"))
        print("Storage Quota: ".lightBlue + (user.preferences.notifications.storageQuota ? "Enabled" : "Disabled"))
        
        // Update settings
        ui.printSubheader("Update Settings")
        
        // Sync completed
        let syncCompleted = ui.readYesNo(prompt: "Enable sync completed notifications?")
        user.preferences.notifications.syncCompleted = syncCompleted
        
        // Sync errors
        let syncErrors = ui.readYesNo(prompt: "Enable sync error notifications?")
        user.preferences.notifications.syncErrors = syncErrors
        
        // Sharing
        let sharing = ui.readYesNo(prompt: "Enable sharing notifications?")
        user.preferences.notifications.sharing = sharing
        
        // Storage quota
        let storageQuota = ui.readYesNo(prompt: "Enable storage quota notifications?")
        user.preferences.notifications.storageQuota = storageQuota
        
        // Update user
        currentUser = user
        
        ui.printSuccess("Notification settings updated successfully.")
    }
    
    /// Theme settings
    private func themeSettings() {
        ui.printSubheader("Theme Settings")
        
        guard var user = currentUser else {
            ui.printError("No user is currently logged in.")
            return
        }
        
        // Display current theme
        ui.printInfo("Current theme: \(user.preferences.theme.rawValue.capitalized)")
        
        // Show theme options
        ui.printMenu([
            "Light",
            "Dark",
            "System",
            "Back"
        ], title: "Select Theme")
        
        guard let choice = readLine(), let option = Int(choice) else {
            ui.printError("Invalid choice. Please enter a number.")
            return
        }
        
        // Update theme
        switch option {
        case 1:
            user.preferences.theme = .light
            ui.printSuccess("Theme set to Light")
        case 2:
            user.preferences.theme = .dark
            ui.printSuccess("Theme set to Dark")
        case 3:
            user.preferences.theme = .system
            ui.printSuccess("Theme set to System")
        case 4:
            return
        default:
            ui.printError("Invalid choice. Please enter a number between 1 and 4.")
            return
        }
        
        // Update user
        currentUser = user
    }
    
    /// Show system information
    private func showSystemInfo() {
        ui.printSubheader("System Information")
        
        print("Application: CloudSyncPlatform".lightBlue)
        print("Version: 1.0.0".lightBlue)
        print("Swift Version: \(swiftVersion)".lightBlue)
        print("Operating System: \(operatingSystem)".lightBlue)
        
        // Show current strategy
        let currentStrategy = syncService.getCurrentStrategy()
        print("Sync Strategy: \(currentStrategy.name)".lightBlue)
        
        print("\nConfiguration:".lightBlue)
        print("  - Sync Interval: \(configManager.getValue(for: "syncInterval", defaultValue: 300)) seconds".lightBlue)
        print("  - Max File Size: \(formatBytes(configManager.getValue(for: "maxFileSize", defaultValue: 104857600)))".lightBlue)
        print("  - Max Concurrent Uploads: \(configManager.getValue(for: "maxConcurrentUploads", defaultValue: 3))".lightBlue)
        print("  - Max Concurrent Downloads: \(configManager.getValue(for: "maxConcurrentDownloads", defaultValue: 5))".lightBlue)
        print("  - Encryption: \(configManager.getValue(for: "encryptionEnabled", defaultValue: true) ? "Enabled" : "Disabled")".lightBlue)
        print("  - Compression: \(configManager.getValue(for: "compressionEnabled", defaultValue: true) ? "Enabled" : "Disabled")".lightBlue)
        print("  - Auto-Sync: \(configManager.getValue(for: "autoSyncEnabled", defaultValue: true) ? "Enabled" : "Disabled")".lightBlue)
        print("  - Retry Attempts: \(configManager.getValue(for: "retryAttempts", defaultValue: 3))".lightBlue)
        
        // Show storage information
        print("\nStorage Directories:".lightBlue)
        print("  - Base: \(storageManager.getFileURL(for: "").deletingLastPathComponent().path)".lightBlue)
    }
    
    // MARK: - Helper Methods
    
    /// Format bytes to human-readable format
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    /// Get Swift version
    private var swiftVersion: String {
        #if swift(>=5.5)
        return "5.5+"
        #elseif swift(>=5.4)
        return "5.4"
        #elseif swift(>=5.3)
        return "5.3"
        #elseif swift(>=5.2)
        return "5.2"
        #elseif swift(>=5.1)
        return "5.1"
        #elseif swift(>=5.0)
        return "5.0"
        #else
        return "Unknown"
        #endif
    }
    
    /// Get operating system
    private var operatingSystem: String {
        #if os(macOS)
        return "macOS"
        #elseif os(iOS)
        return "iOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(Linux)
        return "Linux"
        #else
        return "Unknown"
        #endif
    }
}

// MARK: - Main

// Create and run the application
let app = CloudSyncApp()
app.run()
