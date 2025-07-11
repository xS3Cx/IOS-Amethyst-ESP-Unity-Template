# Amethyst ESP Template

[![Platform](https://img.shields.io/badge/Platform-iOS/iPad-blue.svg)](https://www.apple.com/ios/)
[![Unity](https://img.shields.io/badge/Unity-Games-purple.svg)](https://unity.com/)
[![Jailbreak](https://img.shields.io/badge/Jailbreak-Not%20Required-green.svg)](https://github.com/yourusername/amethyst-esp-template)
[![Status](https://img.shields.io/badge/Status-Outdated-orange.svg)](https://github.com/yourusername/amethyst-esp-template)

> Simple ESP (Extra Sensory Perception) template for Unity mobile games  
> **⚠️ Note: This template is outdated as it uses Update/LateUpdate for ESP rendering**

![photo_2025-07-11_13-00-13](https://github.com/user-attachments/assets/e29095a0-6862-4275-8bab-a01a5cf831be)

## ✨ Features

- 🎯 **Enemy Line**: Draws lines from screen center to enemies
- 📦 **Enemy Box**: Shows red boxes around enemies  
- 📏 **Distance Display**: Shows distance to enemies in meters
- ⚡ **Real-time Toggles**: Enable/disable features during gameplay

## 🚀 Installation

### Jailbroken Devices
1. Install on jailbroken iOS device
2. Launch Unity game
3. Tap "Load" when Amethyst alert appears

### Non-Jailbroken Devices
- **Requires JIT (Just-In-Time compilation) enabled**
- Use tools like AltStore, Sideloadly, or similar
- Enable JIT in your sideloading tool
- Install and launch the game

## 🔨 Compilation

### Build Commands
```bash
make package        # Generates .deb file in packages/ folder
make package install # Installs directly to device
```

### Device Configuration
**Important**: Before using `make package install`, update your device IP in the Makefile:
```makefile
# In Makefile - Update this line with your device IP
THEOS_DEVICE_IP = 192.168.1.100  # Change to your device IP
```

## ⚙️ Offsets Configuration

**Important**: You need to update these offsets for your specific game:

```objc
// In Amethyst.xm - Update these offsets for your game
DobbyHook((void *)getRealOffset(0x4D4F624), ...);  // Player Update function
*(void **)&get_transform = (void *)getRealOffset(0x48618E4); 
*(void **)&get_position = (void *)getRealOffset(0x4881F10); 
*(void **)&get_main = (void *)getRealOffset(0x47C9EA4); 
*(void **)&WorldToViewportPoint = (void *)getRealOffset(0x47C8D40); 
*(void **)&get_fieldOfView = (void *)getRealOffset(0x47C0568); 
```

**How to find offsets:**
- 🎯 **Easy method**: Check `dump.cs` file from your game
- 🔍 **Advanced**: Use tools like Ghidra or Hopper
- 📝 **Search for**: Unity function signatures
- 🔧 **Update**: Hex values in `getRealOffset()` calls

### How to Find Each Function:

#### 🎯 Finding get_position (Transform)
```csharp
// Search for: "public class Transform"
public class Transform : Component, IEnumerable {
    // Look for this function:
    // RVA: 0x4881F10 Offset: 0x4881F10 VA: 0x4881F10
    public Vector3 get_position() { }
}
```
**Copy the Offset value**: `0x4881F10`

#### 📷 Finding get_main (Camera)
```csharp
// Search for: "public sealed class Camera"
public sealed class Camera : Behaviour {
    // Look for this function:
    // RVA: 0x47C9EA4 Offset: 0x47C9EA4 VA: 0x47C9EA4
    public static Camera get_main() { }
}
```
**Copy the Offset value**: `0x47C9EA4`

#### 🌍 Finding WorldToViewportPoint (Camera)
```csharp
// Search for: "public sealed class Camera"
public sealed class Camera : Behaviour {
    // Look for this function:
    // RVA: 0x47C8D40 Offset: 0x47C8D40 VA: 0x47C8D40
    public Vector3 WorldToViewportPoint(Vector3 position) { }
}
```
**Copy the Offset value**: `0x47C8D40`

#### 📐 Finding get_fieldOfView (Camera)
```csharp
// Search for: "public sealed class Camera"
public sealed class Camera : Behaviour {
    // Look for this function:
    // RVA: 0x47C0568 Offset: 0x47C0568 VA: 0x47C0568
    public float get_fieldOfView() { }
}
```
**Copy the Offset value**: `0x47C0568`

#### 🎮 Finding Update/LateUpdate/FixedUpdate (Player)
```csharp
// Search for: "public class Player" or "public class Character"
public class Player : MonoBehaviour {
    // Look for these functions:
    // RVA: 0x4D4F624 Offset: 0x4D4F624 VA: 0x4D4F624
    void Update() { }
    // OR
    void LateUpdate() { }
    // OR
    void FixedUpdate() { }
}
```
**Copy the Offset value**: `0x4D4F624`

**Common class names for Player (examples only - may be different):**
- `Player`, `Character`, `PlayerController`, `GameManager`
- `PlayerMovement`, `PlayerController`, `PlayerScript`
- `GameController`, `PlayerManager`, `PlayerBehaviour`
- `MainPlayer`, `LocalPlayer`, `PlayerObject`
- `Hero`, `Avatar`, `Pawn`, `Actor`

**Note**: These are just examples. Your game might use completely different class names!

## 🎮 Usage

- **Enemy Line**: Toggle in menu to draw targeting lines
- **Enemy Box**: Toggle to show enemy bounding boxes
- **Enemy Distance**: Toggle to display distance numbers

## 🔧 Technical Info

- Uses DobbyHook for function interception
- Unity Framework integration
- Core Graphics rendering
- Memory optimized with proper cleanup

## 📁 File Structure

```
amethyst-esp-template/
├── Amethyst.xm                 # Main ESP logic and hooks
├── esp/
│   ├── CGView.h            # ESP rendering header
│   └── CGView.m            # ESP drawing implementation
├── Macros.h                # Utility macros and definitions
├── Makefile                # Build configuration
├── control                 # Package metadata
└── README.md               # This documentation
```

### Key Files:
- **Amethyst.xm**: Main ESP functionality, player updates, and menu setup
- **CGView.m**: ESP rendering system (boxes, lines, distance display)
- **Macros.h**: Screen dimensions, color definitions, and utility functions
- **Makefile**: Theos build configuration and device settings

## 👨‍💻 Credits

**Code Modifications**: AlexZero - Modified ESP logic and added improvements
**Menu UI Design**: AlexZero - Modern interface and visual styling

### Original Templates & Libraries:
**andr (andrdev)** - ESP system and core logic (modified by AlexZero, added improvements)  
**AlexZero** - [Original Creator](https://github.com/xS3Cx/)  
**joeyjurjens** - [iOS Mod Menu Template for Theos](https://github.com/joeyjurjens/iOS-Mod-Menu-Template-for-Theos)  
**MJx0** - [KittyMemory](https://github.com/MJx0/KittyMemory) - Memory manipulation  
**dogo** - [SCLAlertView](https://github.com/dogo/SCLAlertView) - Alert components  
**jmpews** - [Dobby](https://github.com/jmpews/Dobby) - Hooking framework

## ⚠️ Disclaimer

For educational purposes only. Users responsible for compliance with local laws and game terms of service. 
