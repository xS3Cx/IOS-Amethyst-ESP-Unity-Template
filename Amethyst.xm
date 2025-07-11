
#import "DobbyHook/dobby.h"



#import "Macros.h"



typedef struct Vector3
{
    float x, y, z;

    inline Vector3() {}

    inline Vector3(const float X, const float Y, const float Z) { x = X; y = Y; z = Z; }

    inline Vector3 operator - (const Vector3& A) const { return Vector3(x - A.x, y - A.y, z - A.z); }
} Vector3;

using vec3 = Vector3;

// Function pointers
void *(*get_transform)(void *);
vec3 (*get_position)(void *);
void *(*get_main)();
vec3 (*WorldToViewportPoint)(void *, vec3, int);
float (*get_fieldOfView)(void *);

// Cached values for performance
static vec3 myPos;
static float myFov;
static void *myObject;
static bool lineOn, boxOn, distanceOn;

// Ultra-optimized inline functions
inline vec3 GetPos(void *obj) { return get_position(get_transform(obj)); }

inline vec3 WorldToScreen(vec3 pos) {
    vec3 viewport = WorldToViewportPoint(get_main(), pos, 2);
    vec3 screen = {static_cast<float>(ScreenWidth * viewport.x), static_cast<float>(ScreenHeight - viewport.y * ScreenHeight), viewport.z};
    return (screen.x > 0 && screen.y > 0 && screen.z > 0) ? screen : vec3(0,0,0);
}

inline float FastDistance(vec3 a, vec3 b) {
    vec3 diff = a - b;
    return sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z);
}

void (*old_player_update)(void *player);
void new_player_update(void *player) {
    if (!player) return;
    old_player_update(player);
    
    // Check switches every frame for real-time updates
    lineOn = [switches isSwitchOn:NSSENCRYPT("Enemy Line")];
    boxOn = [switches isSwitchOn:NSSENCRYPT("Enemy Box")];
    distanceOn = [switches isSwitchOn:NSSENCRYPT("Enemy Distance")];
    
    // Initialize self once
    if (!myObject) {
        myObject = player;
        myPos = GetPos(player);
        myFov = get_fieldOfView(get_main());
        return;
    }
    
    // Update self data
    if (player == myObject) {
        myPos = GetPos(player);
        myFov = get_fieldOfView(get_main());
        return;
    }
    
    // Process enemy
    vec3 enemyPos = GetPos(player);
    vec3 screenPos = WorldToScreen(enemyPos);
    
    if (screenPos.z == 0) return; // Off-screen
    
    // Optimized ESP calculations
    float zFactor = screenPos.z / 4;
    float fovFactor = myFov / 2;
    float height = 4200 / zFactor / fovFactor;
    float width = 840 / zFactor / (fovFactor / 2);
    float x = screenPos.x - width / 2;
    float y = screenPos.y - height;
    
    // Draw ESP features
    if (lineOn) [esp addEnemyLine:(x + width / 2) y:y];
    if (boxOn) [esp addEnemyBox:x y:y w:width h:height];
    if (distanceOn) {
        float dist = FastDistance(enemyPos, myPos);
        [esp addEnemyDistance:(x + width / 2) y:(y + height + 15) distance:dist];
    }
    
    [esp setNeedsDisplay];
}



void setup() {

    DobbyHook((void *)getRealOffset(0x4D4F624), (dobby_dummy_func_t)new_player_update, (dobby_dummy_func_t *)&old_player_update);
    *(void **)&get_transform = (void *)getRealOffset(0x48618E4); 
    *(void **)&get_position = (void *)getRealOffset(0x4881F10); 
    *(void **)&get_main = (void *)getRealOffset(0x47C9EA4); 
    *(void **)&WorldToViewportPoint = (void *)getRealOffset(0x47C8D40); 
    *(void **)&get_fieldOfView = (void *)getRealOffset(0x47C0568); 

    [switches addSwitch:NSSENCRYPT("Enemy Line") description:@"Draws a line from the center of the screen to each visible enemy, helping you easily locate opponents."];
    [switches addSwitch:NSSENCRYPT("Enemy Box") description:@"Draws a box around each visible enemy, making it easier to identify and track opponents on the screen."];
    [switches addSwitch:NSSENCRYPT("Enemy Distance") description:@"Displays the distance from you to each enemy player below their ESP box."];





    
}



void setupMenu() {

  [menu setFrameworkName:"UnityFramework"];
    
    

    
  menu = [[Menu alloc]  
            initWithTitle:NSSENCRYPT("Amethyst")
            titleColor:[UIColor whiteColor]
            titleFont:NSSENCRYPT("Copperplate-Bold")
            credits:NSSENCRYPT("This Mod Menu has been made by andr, do not share this without proper credits and my permission. \n\nEnjoy!")
            headerColor:UIColorFromHex(0xC3B5E8)
            switchOffColor:[UIColor darkGrayColor]
            switchOnColor:UIColorFromHex(0xCDBADF)
            switchTitleFont:NSSENCRYPT("Copperplate-Bold")
            switchTitleColor:[UIColor whiteColor]
            infoButtonColor:UIColorFromHex(0xC3B5E8)
            maxVisibleSwitches:4 // Less than max -> blank space, more than max -> you can scroll!
            menuWidth:460
               menuIcon:@""
        menuButton:@""];

  
    mainWindoww = [UIApplication sharedApplication].keyWindow;
    TextFieldView *textFieldView = [[TextFieldView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    textFieldView.userInteractionEnabled = NO;
    textFieldView.backgroundColor = [UIColor clearColor];
    esp = [[CGView alloc] initWithFrame:mainWindoww];
    if([switches isSwitchOn:@"offscreen"]) [textFieldView addSubview:esp];
    [mainWindoww addSubview:textFieldView];
    setup();
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
  timer(5) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSSENCRYPT("Amethyst")
                                                                   message:NSSENCRYPT("Simple Unity ESP Template\n\nMade By AlexZero")
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *loadAction = [UIAlertAction actionWithTitle:NSSENCRYPT("Load")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
      timer(2) {
        setupMenu();
      });
    }];

    UIAlertAction *githubAction = [UIAlertAction actionWithTitle:NSSENCRYPT("GitHub xSECx")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
      [[UIApplication sharedApplication] openURL: [NSURL URLWithString: NSSENCRYPT("https://github.com/xS3Cx")]];
    }];

    [alert addAction:loadAction];
    [alert addAction:githubAction];

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:alert animated:YES completion:nil];
  });
}


%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
