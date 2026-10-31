# Complete Flavors Configuration Guide (Android & iOS)

This guide documents the complete end-to-end configuration for build flavors in **Aqua Go** across Flutter/Dart, Android, and iOS. It includes step-by-step instructions, visual layout navigation, and solutions to common Xcode/Gradle gotchas.

---

## 1. Overview & Flavor Matrix

The project is structured into three environments: **`dev`**, **`qa`**, and **`prod`**.

| Flavor | Target Dart Entry | App Display Name | Base API URL | Default Package / Bundle ID |
|---|---|---|---|---|
| **dev** | `lib/main/main_dev.dart` | `Aqua Go (Dev)` | `Endpoints.baseUrlDev` | `sa.aquago.customerapp` |
| **qa** | `lib/main/main_qa.dart` | `Aqua Go (QA)` | `Endpoints.baseUrlQa` | `sa.aquago.customerapp` |
| **prod** | `lib/main/main_prod.dart` | `Aqua Go` | `Endpoints.baseUrl` | `sa.aquago.customerapp` |

---

## 2. Dart Architecture Setup

### 2.1. Environment Enum & Configs
Defined in [`lib/main/app_configs.dart`](file:///Users/ahmed/projects/aqua_go/lib/main/app_configs.dart):

```dart
enum AppEnvironment {
  dev,
  qa,
  prod;

  bool get isDev => this == AppEnvironment.dev;
  bool get isQa => this == AppEnvironment.qa;
  bool get isProd => this == AppEnvironment.prod;
}

class AppConfigs {
  final String baseUrl;
  final AppEnvironment environment;

  AppConfigs({required this.baseUrl, required this.environment});

  static AppConfigs forEnvironment(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.dev:
        return AppConfigs(
          baseUrl: Endpoints.baseUrlDev,
          environment: AppEnvironment.dev,
        );
      case AppEnvironment.qa:
        return AppConfigs(
          baseUrl: Endpoints.baseUrlQa,
          environment: AppEnvironment.qa,
        );
      case AppEnvironment.prod:
        return AppConfigs(
          baseUrl: Endpoints.baseUrl,
          environment: AppEnvironment.prod,
        );
    }
  }
}
```

### 2.2. Common Launch Routine
In [`lib/main/launch_app.dart`](file:///Users/ahmed/projects/aqua_go/lib/main/launch_app.dart):
* Accepts `AppEnvironment`.
* Initializes `AppConfigs.forEnvironment(environment)`.
* Injects configs into `initServiceLocator(configs)`.
* Initializes Firebase, notifications, localization, orientations, and runs `runApp(const MyApp())`.

### 2.3. Separate Entry Points
Each flavor has its own entry file:
* **`lib/main/main_dev.dart`**:
  ```dart
  import 'package:aqua_go/main/app_configs.dart';
  import 'package:aqua_go/main/launch_app.dart';

  void main() => launchApp(AppEnvironment.dev);
  ```
* **`lib/main/main_qa.dart`**:
  ```dart
  import 'package:aqua_go/main/app_configs.dart';
  import 'package:aqua_go/main/launch_app.dart';

  void main() => launchApp(AppEnvironment.qa);
  ```
* **`lib/main/main_prod.dart`**:
  ```dart
  import 'package:aqua_go/main/app_configs.dart';
  import 'package:aqua_go/main/launch_app.dart';

  void main() => launchApp(AppEnvironment.prod);
  ```

---

## 3. Android Configuration

### 3.1. Gradle Setup (`android/app/build.gradle.kts`)
Flavors are defined inside the `android { ... }` block:

```kotlin
android {
    namespace = "sa.aquago.customerapp"
    compileSdk = 37

    defaultConfig {
        applicationId = "sa.aquago.customerapp"
        minSdk = 24
        targetSdk = 37
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            // applicationIdSuffix = ".dev" // Uncomment to install side-by-side
            resValue("string", "app_name", "Aqua Go (Dev)")
            buildConfigField("String", "FLAVOR", "\"dev\"")
        }
        create("qa") {
            dimension = "environment"
            // applicationIdSuffix = ".qa" // Uncomment to install side-by-side
            resValue("string", "app_name", "Aqua Go (QA)")
            buildConfigField("String", "FLAVOR", "\"qa\"")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Aqua Go")
            buildConfigField("String", "FLAVOR", "\"prod\"")
        }
    }

    buildFeatures {
        buildConfig = true
    }
}
```

### 3.2. Android Manifest (`android/app/src/main/AndroidManifest.xml`)
Link the app label to `@string/app_name` generated dynamically per flavor:

```xml
<application
    android:label="@string/app_name"
    android:name="${applicationName}"
    android:icon="@mipmap/launcher_icon"
    ...>
```

---

## 4. iOS Configuration

To mirror Android flavors, iOS uses:
1. **`.xcconfig` files** for flavor variables.
2. **Build Configurations** following Flutter's `<BuildMode>-<Flavor>` convention.
3. **Xcode Schemes** matching each flavor name (`dev`, `qa`, `prod`).

---

### Step 1: Create Flavor `.xcconfig` Files

Create configuration files for each flavor.

> [!IMPORTANT]
> Always use resilient `#include?` statements. If a file is in `ios/Runner/` or `ios/Flutter/`, the search paths differ. Using `#include?` prevents hard compile errors when `Generated.xcconfig` is being regenerated during `flutter clean` or fresh builds.

Create `Dev.xcconfig`, `Qa.xcconfig`, and `Prod.xcconfig` with the following contents:

#### **`Dev.xcconfig`**:
```xcconfig
#include? "Flutter/Generated.xcconfig"
#include? "../Flutter/Generated.xcconfig"
#include? "Generated.xcconfig"

APP_DISPLAY_NAME=Aqua Go (Dev)
FLAVOR=dev
```

#### **`Qa.xcconfig`**:
```xcconfig
#include? "Flutter/Generated.xcconfig"
#include? "../Flutter/Generated.xcconfig"
#include? "Generated.xcconfig"

APP_DISPLAY_NAME=Aqua Go (QA)
FLAVOR=qa
```

#### **`Prod.xcconfig`**:
```xcconfig
#include? "Flutter/Generated.xcconfig"
#include? "../Flutter/Generated.xcconfig"
#include? "Generated.xcconfig"

APP_DISPLAY_NAME=Aqua Go
FLAVOR=prod
```

---

### Step 2: Add `.xcconfig` Files to the Xcode Project

> [!WARNING]
> Creating `.xcconfig` files on disk (or in VS Code) **does not** automatically register them in Xcode. If you skip this step, Xcode will not show `Dev`, `Qa`, and `Prod` in the configurations dropdown.

1. Open `ios/Runner.xcworkspace` in Xcode.
2. In the left **Project Navigator** sidebar (folder icon), locate the **`Runner`** or **`Flutter`** group folder.
3. **Right-click** on the folder $\rightarrow$ select **`Add Files to "Runner"...`**.
4. Select `Dev.xcconfig`, `Qa.xcconfig`, and `Prod.xcconfig`.
5. Under **Options** at the bottom:
   * **Uncheck** *"Copy items if needed"* (if files are already inside the folder).
   * Ensure *"Create groups"* is selected.
6. Click **Add**.

---

### Step 3: Locate the "Configurations" Tab in Xcode

> [!IMPORTANT]
> **Common Gotcha: PROJECT vs TARGETS**
> * If you select **TARGETS > Runner**, you will see 7 tabs (`General`, `Signing & Capabilities`, `Info`, `Build Settings`, etc.). The `Info` tab here only displays target property lists (*Info.plist*), **not Configurations**.
> * You must select **PROJECT > Runner** to see the Configurations table.

```text
Project Navigator (Left Pane)
└── Runner (Blue Icon) ──────────┐
                                 │
     Center Editor Area          ▼
     ┌─────────────────────────────────────────────────────────┐
     │ ┌───────────────┐                                       │
     │ │ PROJECT       │  Select this:                         │
     │ │   Runner  ────┼─► [ Info ]   [ Build Settings ]       │
     │ └───────────────┘       │                               │
     │ ┌───────────────┐       ▼                               │
     │ │ TARGETS       │   1. Deployment Target                │
     │ │   Runner      │   2. Configurations  ◄── (YOU NEED)   │
     │ │   RunnerTests │   3. Localizations                    │
     │ └───────────────┘                                       │
     └─────────────────────────────────────────────────────────┘
```

1. Click on the root **Runner** item (blue project icon) at the top of the Project Navigator.
2. If the PROJECT / TARGETS panel is collapsed, click the sidebar toggle icon in the top-left corner of the editor area (just below the back/forward arrows) to expand it.
3. Select **Runner** under the **PROJECT** heading.
4. Click on the **Info** tab at the top.
5. You will see the **Configurations** section with the **`+`** (plus) button at the bottom.

---

### Step 4: Create Build Configurations in Xcode

Flutter automatically detects configurations formatted as **`<BuildMode>-<Flavor>`** (case-sensitive).

1. In the **Configurations** table under **PROJECT > Runner > Info**:
2. Expand `Debug`, `Profile`, and `Release`.
3. Click the **`+`** button at the bottom of the Configurations list:
   * **From Debug**:
     * Duplicate "Debug" Configuration $\rightarrow$ rename to: **`Debug-dev`**
     * Duplicate "Debug" Configuration $\rightarrow$ rename to: **`Debug-qa`**
     * Duplicate "Debug" Configuration $\rightarrow$ rename to: **`Debug-prod`**
   * **From Profile**:
     * Duplicate "Profile" Configuration $\rightarrow$ rename to: **`Profile-dev`**
     * Duplicate "Profile" Configuration $\rightarrow$ rename to: **`Profile-qa`**
     * Duplicate "Profile" Configuration $\rightarrow$ rename to: **`Profile-prod`**
   * **From Release**:
     * Duplicate "Release" Configuration $\rightarrow$ rename to: **`Release-dev`**
     * Duplicate "Release" Configuration $\rightarrow$ rename to: **`Release-qa`**
     * Duplicate "Release" Configuration $\rightarrow$ rename to: **`Release-prod`**

---

### Step 5: Link Configurations to the `.xcconfig` Files

In the same **Configurations** table, expand each configuration row and set the base configuration file for the **Runner** target (leave `RunnerTests` as `None`):

| Configuration | Runner Target Dropdown | RunnerTests Target |
|---|---|---|
| **`Debug-dev`** | **`Dev`** | `None` |
| **`Profile-dev`** | **`Dev`** | `None` |
| **`Release-dev`** | **`Dev`** | `None` |
| **`Debug-qa`** | **`Qa`** | `None` |
| **`Profile-qa`** | **`Qa`** | `None` |
| **`Release-qa`** | **`Qa`** | `None` |
| **`Debug-prod`** | **`Prod`** | `None` |
| **`Profile-prod`** | **`Prod`** | `None` |
| **`Release-prod`** | **`Prod`** | `None` |

---

### Step 6: Update `ios/Runner/Info.plist`

Open `ios/Runner/Info.plist` and change `CFBundleDisplayName` so it reads the dynamic variable from the active configuration:

```xml
<key>CFBundleDisplayName</key>
<string>$(APP_DISPLAY_NAME)</string>
```

---

### Step 7: Create and Configure Xcode Schemes

Flutter maps the `--flavor <name>` flag to the **Xcode Scheme** of the exact same name.

> [!WARNING]
> **Do NOT click the `+` (Add Scheme) button!**
> If you click `+`, Xcode creates a scheme from scratch and asks for a target, which defaults to third-party packages (e.g. `connectivity_plus`), and it will **omit** Flutter's required pre-action build scripts (`xcode_backend.sh prepare`).
> 
> **Always DUPLICATE the existing `Runner` scheme.**

#### How to Duplicate and Configure:

1. In Xcode top menu: **Product** $\rightarrow$ **Scheme** $\rightarrow$ **Manage Schemes...**
2. **Double-click** on **`Runner`** (or select `Runner` and click the **Duplicate** button).
3. At the top of the popup sheet, change the name to **`dev`**.
4. In the left sidebar of that sheet, map each action to its corresponding configuration:
   * **Run**:
     * Select **Info** tab $\rightarrow$ Build Configuration: **`Debug-dev`**
   * **Test**:
     * Build Configuration: **`Debug-dev`**
   * **Profile**:
     * Build Configuration: **`Profile-dev`**
   * **Analyze**:
     * Build Configuration: **`Debug-dev`**
   * **Archive**:
     * Build Configuration: **`Release-dev`**
5. Click **Close**.

#### Repeat for `qa` and `prod`:
* **Scheme `qa`** (Duplicate `Runner` $\rightarrow$ rename to `qa`):
  * Run / Test / Analyze $\rightarrow$ **`Debug-qa`**
  * Profile $\rightarrow$ **`Profile-qa`**
  * Archive $\rightarrow$ **`Release-qa`**

* **Scheme `prod`** (Duplicate `Runner` $\rightarrow$ rename to `prod`):
  * Run / Test / Analyze $\rightarrow$ **`Debug-prod`**
  * Profile $\rightarrow$ **`Profile-prod`**
  * Archive $\rightarrow$ **`Release-prod`**

#### Make Schemes "Shared" (Mandatory for Git & CI/CD):
In the **Manage Schemes** window:
* Look at the right-most column named **Shared**.
* Check the checkbox $\checkmark$ for **`dev`**, **`qa`**, and **`prod`**.
* *Why?* This writes the scheme definitions to `ios/Runner.xcodeproj/xcshareddata/xcschemes/` so git tracks them and CI/CD pipelines can build them.

---

## 5. Running and Building

### 5.1. CLI Commands

#### Run Debug Builds
```bash
# Development
flutter run --flavor dev -t lib/main/main_dev.dart

# QA
flutter run --flavor qa -t lib/main/main_qa.dart

# Production
flutter run --flavor prod -t lib/main/main_prod.dart
```

#### Build Release Android (APK / AAB)
```bash
# APK
flutter build apk --flavor dev -t lib/main/main_dev.dart
flutter build apk --flavor qa -t lib/main/main_qa.dart
flutter build apk --flavor prod -t lib/main/main_prod.dart

# App Bundle (for Google Play)
flutter build appbundle --flavor prod -t lib/main/main_prod.dart
```

#### Build Release iOS (IPA / Archive)
```bash
flutter build ipa --flavor dev -t lib/main/main_dev.dart
flutter build ipa --flavor qa -t lib/main/main_qa.dart
flutter build ipa --flavor prod -t lib/main/main_prod.dart
```

---

### 5.2. VS Code Configuration (`.vscode/launch.json`)

To debug flavors directly in VS Code, define them in [`.vscode/launch.json`](file:///Users/ahmed/projects/aqua_go/.vscode/launch.json):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "aqua_go (dev)",
      "program": "lib/main/main_dev.dart",
      "request": "launch",
      "type": "dart",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "aqua_go (qa)",
      "program": "lib/main/main_qa.dart",
      "request": "launch",
      "type": "dart",
      "args": ["--flavor", "qa"]
    },
    {
      "name": "aqua_go (prod)",
      "program": "lib/main/main_prod.dart",
      "request": "launch",
      "type": "dart",
      "args": ["--flavor", "prod"]
    }
  ]
}
```

---

## 6. Common Issues & Troubleshooting

### Q1: `Error (Xcode): could not find included file 'Generated.xcconfig' in search paths`
* **Cause**: Your flavor `.xcconfig` file is located in `ios/Runner/`, but it tried to `#include "Generated.xcconfig"` without specifying the relative path to `ios/Flutter/`.
* **Fix**: Use resilient include paths in `Dev.xcconfig`, `Qa.xcconfig`, and `Prod.xcconfig`:
  ```xcconfig
  #include? "Flutter/Generated.xcconfig"
  #include? "../Flutter/Generated.xcconfig"
  #include? "Generated.xcconfig"
  ```

### Q2: Cannot find the "Configurations" section or `+` button in Xcode
* **Cause**: You have a **Target** selected (e.g. `TARGETS > Runner`) instead of the **Project**.
* **Fix**: Expand the project/target list in the center editor and click **Runner** under the **PROJECT** header. Select the **Info** tab.

### Q3: `Dev`, `Qa`, and `Prod` do not show up in the base configuration dropdown
* **Cause**: The `.xcconfig` files were created on disk but have not been added to Xcode's file tree.
* **Fix**: Right-click the `Runner` or `Flutter` folder in Xcode Navigator $\rightarrow$ **Add Files to "Runner"...** $\rightarrow$ select the `.xcconfig` files (uncheck *"Copy items if needed"*).

### Q4: When adding a scheme, the target says `connectivity_plus` (or another package)
* **Cause**: You clicked the `+` button in Manage Schemes to create a new scheme from scratch.
* **Fix**: Delete that scheme. Instead, select `Runner` $\rightarrow$ click **Duplicate** (or double-click `Runner` and click **Duplicate Scheme**).

### Q5: CI/CD or other developers can't build the flavor schemes
* **Cause**: Schemes were not marked as **Shared**, meaning Xcode stored them only locally in your personal user data (`xcuserdata/`).
* **Fix**: Open **Product > Scheme > Manage Schemes...**, check the **Shared** box for `dev`, `qa`, and `prod`, and commit the generated `ios/Runner.xcodeproj/xcshareddata/xcschemes/` files to Git.

### Q6: How to install Dev and Prod side-by-side on the same physical phone
1. **Android**: In `android/app/build.gradle.kts`, uncomment `applicationIdSuffix`:
   ```kotlin
   create("dev") {
       dimension = "environment"
       applicationIdSuffix = ".dev"
       ...
   }
   ```
2. **iOS**:
   * In `Dev.xcconfig`, add:
     ```xcconfig
     BUNDLE_ID_SUFFIX=.dev
     ```
   * In Xcode $\rightarrow$ **TARGETS > Runner** $\rightarrow$ **Build Settings** $\rightarrow$ search for **Product Bundle Identifier** $\rightarrow$ change value to:
     ```text
     sa.aquago.customerapp$(BUNDLE_ID_SUFFIX)
     ```
