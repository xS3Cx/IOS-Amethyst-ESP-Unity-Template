
//пожалуйста, если используете это в коммерческих целях, указывайте мой ник(andr \ andrdev) в кредитах вашего проекта
//please, if this is used for commercial purposes, indicate my nickname (andr \ andrdev) in the credits of your project

//пожалуйста, если используете это в коммерческих целях, указывайте мой ник(andr \ andrdev) в кредитах вашего проекта
//please, if this is used for commercial purposes, indicate my nickname (andr \ andrdev) in the credits of your project
//пожалуйста, если используете это в коммерческих целях, указывайте мой ник(andr \ andrdev) в кредитах вашего проекта
//please, if this is used for commercial purposes, indicate my nickname (andr \ andrdev) in the credits of your project


#import "CGView.h"
#import <Foundation/Foundation.h>

@implementation CGView

unsigned int (*enemyboxes)[4];
unsigned int enemyboxesCount;
unsigned int (*enemylines)[2];
unsigned int enemylinesCount;
unsigned int (*enemyhbars)[5];
unsigned int enemyhbarsCount;
unsigned int (*enemydistances)[3];
unsigned int enemydistancesCount;

- (id)initWithFrame:(UIWindow *)drawWindow
{

    self = [super initWithFrame:drawWindow.frame];
    self.userInteractionEnabled = false;
    self.backgroundColor = [UIColor clearColor];
    
    if (self) {
    enemyboxes = (unsigned int (*)[4])malloc(0);
    enemyboxesCount = 0;
    enemylines = (unsigned int (*)[2])malloc(0);
    enemylinesCount = 0;
    enemyhbars = (unsigned int (*)[5])malloc(0);
    enemyhbarsCount = 0;
    enemydistances = (unsigned int (*)[3])malloc(0);
    enemydistancesCount = 0;
    }

    [drawWindow addSubview: self];
    self.layer.zPosition = 0; // Set z-position to 0
    return self;
}

-(void)drawRect:(CGRect)rect
{

CGContextRef context = UIGraphicsGetCurrentContext();
CGContextSetAlpha(context, 255);

for (int i = 0; i < enemyboxesCount; i++) {

    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(enemyboxes[i][0], enemyboxes[i][1], enemyboxes[i][2], enemyboxes[i][3])];
    path.lineWidth = ([[UIScreen mainScreen] bounds].size.width * 1/1200);
    [[UIColor redColor] setStroke];
    [path stroke];
}

for (int i = 0; i < enemylinesCount; i++)
{

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake([[UIScreen mainScreen] bounds].size.width / 2, [[UIScreen mainScreen] bounds].size.height * 0)];
    [path addLineToPoint:CGPointMake(enemylines[i][0], enemylines[i][1])];
    path.lineWidth = [[UIScreen mainScreen] bounds].size.width * 1/1200;
    [[UIColor redColor] setStroke];
    [path stroke];
}

for (int i = 0; i < enemyhbarsCount; i++) {

    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(enemyhbars[i][0], enemyhbars[i][1], enemyhbars[i][2], enemyhbars[i][3] * enemyhbars[i][4] / 100.f)];
    path.lineWidth = [[UIScreen mainScreen] bounds].size.width * 1/1200;
    [[UIColor greenColor] setFill];
    [path fill];
}

for (int i = 0; i < enemydistancesCount; i++) {
    NSString *distanceText = [NSString stringWithFormat:@"%.0fm", (float)enemydistances[i][2]];
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:12],
        NSForegroundColorAttributeName: [UIColor whiteColor]
    };
    CGSize textSize = [distanceText sizeWithAttributes:attributes];
    CGPoint textPoint = CGPointMake(enemydistances[i][0] - textSize.width / 2, enemydistances[i][1]);
    [distanceText drawAtPoint:textPoint withAttributes:attributes];
}

[self clearDraw];
}

-(void) addEnemyBox:(float)x y:(float)y w:(float)w h:(float)h {
enemyboxesCount++;
enemyboxes = (unsigned int (*)[4])realloc(enemyboxes, enemyboxesCount*sizeof(unsigned int[4]));
enemyboxes[enemyboxesCount-1][0] = x;
enemyboxes[enemyboxesCount-1][1] = y;
enemyboxes[enemyboxesCount-1][2] = w;
enemyboxes[enemyboxesCount-1][3] = h;
}

-(void) addEnemyLine:(float)x y:(float)y {
enemylinesCount++;
enemylines = (unsigned int (*)[2])realloc(enemylines, enemylinesCount*sizeof(unsigned int[2]));
enemylines[enemylinesCount-1][0] = x;
enemylines[enemylinesCount-1][1] = y;
}

-(void) addEnemyHealthbar:(float)x y:(float)y w:(float)w h:(float)h health:(float)health {
enemyhbarsCount++;
enemyhbars = (unsigned int (*)[5])realloc(enemyhbars, enemyhbarsCount*sizeof(unsigned int[5]));
enemyhbars[enemyhbarsCount-1][0] = x;
enemyhbars[enemyhbarsCount-1][1] = y;
enemyhbars[enemyhbarsCount-1][2] = w;
enemyhbars[enemyhbarsCount-1][3] = h;
enemyhbars[enemyhbarsCount-1][4] = health;
}

-(void) addEnemyDistance:(float)x y:(float)y distance:(float)distance {
enemydistancesCount++;
enemydistances = (unsigned int (*)[3])realloc(enemydistances, enemydistancesCount*sizeof(unsigned int[3]));
enemydistances[enemydistancesCount-1][0] = x;
enemydistances[enemydistancesCount-1][1] = y;
enemydistances[enemydistancesCount-1][2] = distance;
}

-(void)clearDraw {
enemyboxesCount = 0;
enemyboxes = (unsigned int (*)[4])realloc(enemyboxes, enemyboxesCount*sizeof(unsigned int[4]));
enemylinesCount = 0;
enemylines = (unsigned int (*)[2])realloc(enemylines, enemylinesCount*sizeof(unsigned int[2]));
enemyhbarsCount = 0;
enemyhbars = (unsigned int (*)[5])realloc(enemyhbars, enemyhbarsCount*sizeof(unsigned int[5]));
enemydistancesCount = 0;
enemydistances = (unsigned int (*)[3])realloc(enemydistances, enemydistancesCount*sizeof(unsigned int[3]));
}

@end
