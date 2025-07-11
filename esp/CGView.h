//пожалуйста, если используете это в коммерческих целях, указывайте мой ник(andr \ andrdev) в кредитах вашего проекта
//please, if this is used for commercial purposes, indicate my nickname (andr \ andrdev) in the credits of your project

//пожалуйста, если используете это в коммерческих целях, указывайте мой ник(andr \ andrdev) в кредитах вашего проекта
//please, if this is used for commercial purposes, indicate my nickname (andr \ andrdev) in the credits of your project
//пожалуйста, если используете это в коммерческих целях, указывайте мой ник(andr \ andrdev) в кредитах вашего проекта
//please, if this is used for commercial purposes, indicate my nickname (andr \ andrdev) in the credits of your project


#import <UIKit/UIKit.h>

@interface CGView : UIView

-(id)initWithFrame:(UIWindow *)drawWindow;
-(void)drawRect:(CGRect)rect;
-(void) addEnemyBox:(float)x y:(float)y w:(float)w h:(float)h;
-(void) addEnemyLine:(float)x y:(float)y;
-(void) addEnemyHealthbar:(float)x y:(float)y w:(float)w h:(float)h health:(float)health;
-(void) addEnemyDistance:(float)x y:(float)y distance:(float)distance;

-(void) clearDraw;

@end 
