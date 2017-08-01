#import "ViewController.h"

@interface ViewController () <ARSCNViewDelegate,ARSessionDelegate,SCNSceneRendererDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

@end

@implementation ViewController
{
    SCNNode *_cameraNode;
    matrix_float4x4 _transform;
    BOOL _didFindNewPlane;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _didFindNewPlane = 0;
    
    // *********************************************************
    // AR
    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    // Create a new scene
    SCNScene *ARscene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // Set the scene to the view
    self.sceneView.scene = ARscene;
    
    self.sceneView.session.delegate = self;
    
    // *********************************************************
    // VR
    // create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/CubeScene.scn"];
    
    // Main Camera. 决定摄像头组方向
    _cameraNode = [SCNNode node];
    _cameraNode.camera = [SCNCamera camera];
    [_cameraNode setPosition:SCNVector3Make(0, 0, 0)];
    [scene.rootNode addChildNode:_cameraNode];
    
    //// retrieve the ship node
    //SCNNode *ship = [scene.rootNode childNodeWithName:@"box" recursively:YES];
    //// animate the 3d object
    //[ship runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:1 z:0 duration:10]]];
    
    // Camera left
    SCNNode *cameraNodeLeft = [SCNNode node];
    cameraNodeLeft.camera = [SCNCamera camera];
    [cameraNodeLeft.camera setZNear:0.001f];
    [cameraNodeLeft setPosition:SCNVector3Make(-0.05, 0, 0)];
    [_cameraNode addChildNode:cameraNodeLeft];
    
    // Camera right
    SCNNode *cameraNodeRight = [SCNNode node];
    cameraNodeRight.camera = [SCNCamera camera];
    [cameraNodeRight.camera setZNear:0.001f];
    [cameraNodeRight setPosition:SCNVector3Make(0.05, 0, 0)];
    [_cameraNode addChildNode:cameraNodeRight];
    
    // retrieve the SCNView
    SCNView *scnViewLeft = [[SCNView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*0.5, self.view.frame.size.height)];
    scnViewLeft.pointOfView = cameraNodeLeft;
    scnViewLeft.scene = scene;
    scnViewLeft.backgroundColor = [UIColor blackColor];
    [self.sceneView addSubview:scnViewLeft];
    
    SCNView *scnViewRight = [[SCNView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.5, 0, 0.5*self.view.frame.size.width, self.view.frame.size.height)];
    scnViewRight.pointOfView = cameraNodeRight;
    scnViewRight.scene = scene;
    scnViewRight.backgroundColor = [UIColor blackColor];
    [self.sceneView addSubview:scnViewRight];
    
    scnViewLeft.delegate = self;
    scnViewRight.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingSessionConfiguration *configuration = [ARWorldTrackingSessionConfiguration new];
    
    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSessionDelegate

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
{
    NSLog(@"display===");
    
    // Retrive the matrix from ARKit - ARFrame - camera.
    _transform = frame.camera.transform;
    [_cameraNode setTransform:SCNMatrix4FromMat4(_transform)];
}

@end

