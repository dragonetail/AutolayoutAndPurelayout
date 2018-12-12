#  学习练习Autolayout和Purelayout

## 参考

- https://github.com/PureLayout/PureLayout/wiki/Tips-and-Tricks

- https://www.objc.io/issues/3-views/advanced-auto-layout-toolbox/

- https://www.jianshu.com/p/3a872a0bfe11

- http://www.cocoachina.com/ios/20160229/15455.html

  ​

## Layout处理流程

Auto Layout追加了两个步骤在视图显示的过程中：updating constraints（约束更新） and laying out views（视图布局）。整个过程行程了依赖处理链条，视图显示依赖视图布局、布局依赖约束更新。

**约束更新（updating constraints）**是一个自底向上（bottom-up ）从子视图到（subview）父视图（super view）尺寸计算的环节，为视图布局准备尺寸定义和计算信息，最后传给布局的尺寸（frame）实际设计布局。定制化视图的约束处理，重载实现视图的 `updateConstraints` 方法追加本视图处理阶段需要的特殊约束定制；当时图中内容发生变化时，例如部分组件移动位置，组件增加减少时，可以通过 `setNeedsUpdateConstraints`通知视图布局变化。（这个动作会由系统延后进行处理，激活调用 `updateConstraints` 。这个需要验证。）

**视图布局（view layout）**是一个自上而下（top-down），从父视图到子视图（from super view to subview）的处理过程，这个过程实际将视图约束应用到视图尺寸（frame）上（对于OS X系统）或者视图的中心和边界（center and bounds，对于iOS系统）。当视图需要更新布局，调用 `setNeedsLayout`可以出发系统重新布局处理，这个调用可以根据布局组件变化多次调用，系统会合并多次调用并稍后处理。如果希望立即更新布局，可以调用 `layoutIfNeeded`/`layoutSubtreeIfNeeded` (分别对应 iOS 和 OS X=)，如果你下一步的工作依赖于视图的布局尺寸（Frame），这会立即更新视图尺寸。定制视图的话，通过重载`layoutSubviews`/`layout` 来实现布局过程的细节。

**视图显示**，最后显示环节将根据布局信息进行自上而下（top-down）的视图渲染。可以调用`setNeedsDisplay`,来激活这个过程，这个系统也会合并多次调用并稍后处理。通过重载 `drawRect` 可以来定制视图显示处理的细节。

**视图显示->视图布局->约束更新**，是进行链式依赖的，视图显示会看是否有layout的变化需要更新（是否有过系统或者定制处理调用的 `setNeedsLayout`），同样视图布局会依赖约束更新，检查约束是否有变化过需要重新计算。

**注意**：上面这个依赖链不是一个单向通道，可能会是一个迭代的处理过程。视图布局环节可能做了一些变化需要激活重新计算约束更新，约束更新重新计算会重新触发试图布局，这种机制可以让你有能力创造复杂高级的视图布局，但也会让你在 `layoutSubviews` 和 `updateConstraints` 之间轻松陷入死循环。



## Auto Layout定制化视图

Auto Layout定制化视图处理需要处理：计算内部内容期望尺寸显示大小、理解视图尺寸和对齐矩阵、使用基线布局、同Layout处理流程交互。

### 内容期望尺寸（Intrinsic Content Size）

内容期望尺寸是对将要显示的内容，你希望预期显示的尺寸。例如对于`UILabel`会根据字体有期望显示的高度，根据字体和显示文字的内容有期望的宽度；  `UIProgressView` 根据设计有期望显示的高度，但是不会有宽度；普通的`UIVIew`通常既没有期望的显示高度和宽度。

如果你的视图需要使用内容期望尺寸，就需要在高度和宽度两个维度进行指定。通过重载[`intrinsicContentSize`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/instm/NSView/intrinsicContentSize) 计算内容期望尺寸，通过调用 [`invalidateIntrinsicContentSize`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/instm/NSView/invalidateIntrinsicContentSize) 来触发需要重新计算。如果结果只有一个维度，对于没有的维度返回常量`UIViewNoIntrinsicMetric`/`NSViewNoIntrinsicMetric`告知系统。

**注意：**内容期望尺寸计算必须独立不依赖视图尺寸。例如不可以通过视图显示区域尺寸的大小返回一个比例尺寸。

#### 抗压能力优先级和拉伸能力优先级（Compression Resistance and Content Hugging）

关于这个名词，翻译比较困难，这里采用了意译。Compression Resistance直接翻译为压缩阻力，Content Hugging直接翻译为内容抱紧（吸附），系统采用优先级（priority）设定方式使用这两个参数，控制多个控件视图在父视图尺寸布局或者变化时，控件视图倾向于更改自己的大小还是更倾向于保持自己的固有大小（内容期望尺寸Intrinsic Content Size）。这个优先级范围为1~1000，1000为最高优先级，**抗压能力优先级缺省为750，越小越容易被压缩，越大抗压缩能力越强；拉伸能力优先级缺省为250，越小越容易被拉伸，越大抗拉伸能力越强**。

这两个属性是配合内容期望尺寸（Intrinsic Content Size）生效的，通过内容期望尺寸指定抗压和拉伸的坚持目标尺寸。普通的View内容期望尺寸(UIViewNoIntrinsicMetric，UIViewNoIntrinsicMetric)，也就是(-1,-1)，这两个属性是不生效的，需要重载[`intrinsicContentSize`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/instm/NSView/intrinsicContentSize) 配合实现。

另外，内容期望尺寸、抗压能力优先级和拉伸能力优先级是两个维度，在Vertical和Horizontal分别设置生效。

在系统处理上，内容期望尺寸、抗压能力优先级和拉伸能力优先级被转换成约束，对于一个内容期望尺寸大小为`{ 100, 30 }`的视图，两个维度的抗压能力优先级缺省为750，拉伸能力优先级缺省为250，如下四个约束被生成：

```swift
H:[label(<=100@250)]
H:[label(>=100@750)]
V:[label(<=30@250)]
V:[label(>=30@750)]
```

约束可视化显示，可以参考[苹果文档](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html)。理解这些约束如何被系统隐含生成并生效会帮助解决布局问题。

说明：上面一节内容参考了[Auto Layout压缩阻力及内容吸附讲解](http://www.cocoachina.com/ios/20160229/15455.html)，并根据内容作了[Swift版本的示例]()。

一下是部分代码例子：

```swift
//设置比缺省值小，则容易被拉伸
//view2.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .vertical)
//设置比缺省值小，则容易被压缩
//label2.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
```



### 视图框架和对齐矩阵（Frame vs. Alignment Rect）

自动布局不是在视图的框架上操作，而是在视图的对齐矩形上操作。但是，对齐矩形实际上是一个强大的新概念，它将视图的布局对齐边缘与其视觉外观分离开来。

默认情况下alignmentRect与frame是一致的，除非子类重写了alignmentRectInsets方法。alignmentRect不包括视图的阴影等外部装饰部分的空间，因此对齐的时候需要处理。

另外两个相关的重载函数 [`alignmentRectForFrame:`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/instm/NSView/alignmentRectForFrame:) 和 [`frameForAlignmentRect:`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/instm/NSView/frameForAlignmentRect:)能够更多控制。

（这一部分还不太完全清晰。。。）



### 基线对齐（Baseline Alignment）

这部分不清楚，需要补充信息。



### 控制布局（Taking Control of Layout）

通过定制视图，对视图的子视图subviews追加本地化约束更新，并且在影响变化的时候更新约束，布局就可以传递给子视图。

需要说明的是，显示、布局是top-down，约束更新时bottom-up的。

#### 本地约束（Local Constraints）

UIView的[`requiresConstraintBasedLayout`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/clm/NSView/requiresConstraintBasedLayout) 控制使用约束方式进行布局，目前已经强制为true。

在UIView的 [`updateConstraints`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/instm/NSView/updateConstraints)中实现自定义的本地约束，并保证在最后调用父类的 [`updateConstraints`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/instm/NSView/updateConstraints)。

在这个步骤中，你不能无效（invalidate）任何约束，因为这一步是由layout process发起的，系统会报告程序错误。

如果一些约束需要更改（invalidate），你应该在需要的地方，例如按钮的响应事件中，尽快删除对应的约束，并且调用 [`setNeedsUpdateConstraints`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/instm/UIView/setNeedsUpdateConstraints)。

#### 控制子视图的布局（Control Layout of Subviews）

如果你不用约束进行布局控制，你可以使用iOSde [`layoutSubviews`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/instm/UIView/layoutSubviews) 或OS X的 [`layout`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/instm/NSView/layout)方法进行布局控制。

完全丢弃约束布局，你可以在重载方法中不调用父类的方法，这样根据计算，任意放置所有的子视图。

如果你还需要使用约束布局功能，你必须先调用父类的重载方法，然后细调布局内容。您可以使用它来创建无法使用约束定义的布局，例如涉及视图之间的大小和间距关系的布局。

另一个有趣的用例是创建布局依赖的视图树。自动布局完成第一次遍历并设置自定义视图子视图上的框架尺寸后，您可以检查这些子视图的定位和大小，并对视图层次结构和/或约束进行更改。WWDC教程 [228 – Best Practices for Mastering Auto Layout](https://developer.apple.com/videos/wwdc/2012/?id=228) 中有一个好的例子，当子视图被裁剪的情况发生，则直接移出子视图。

您还可以决定在第一次布局传递之后更改约束。例如，如果视图变得太窄，则从将子视图排成一行切换到两行。

```
- layoutSubviews
{
    [super layoutSubviews];
    if (self.subviews[0].frame.size.width <= MINIMUM_WIDTH) {
        [self removeSubviewConstraints];
        self.layoutRows += 1;
        [super layoutSubviews];
    }
}

- updateConstraints
{
    // add constraints depended on self.layoutRows...
    [super updateConstraints];
}
```

## 内容期望尺寸和多行文本（Intrinsic Content Size of Multi-Line Text）

 `UILabel` 和 `NSTextField` 的内容期望尺寸特别对于多行，高度依赖宽度和文本的内容数量。而宽度在约束解决之前还没有确定，为了解决这个问题，这两个控件追加了一个 [`preferredMaxLayoutWidth`](http://developer.apple.com/library/ios/documentation/uikit/reference/UILabel_Class/Reference/UILabel.html#//apple_ref/occ/instp/UILabel/preferredMaxLayoutWidth)属性用于计算最大行宽。

我们通常不知道这个值是多少，这个时候需要两步处理，第一遍根据约束计算出Label的frame大小，然后设定preferredMaxLayoutWidth，然后重新再计算一遍约束，来得到正确的高度。

```
- (void)layoutSubviews
{
    [super layoutSubviews];
    myLabel.preferredMaxLayoutWidth = myLabel.frame.size.width;
    [super layoutSubviews];
}
```

第一遍是为了计算Label的frame大小，第二遍是必须的，因为修改了preferredMaxLayoutWidth如果不及时再次计算，系统会报告`NSInternalInconsistencyException` 异常，必须立即更新约束。

如果有Label的子类实现，也可以放在子类中实现。

```
@implementation MyLabel
- (void)layoutSubviews
{
    self.preferredMaxLayoutWidth = self.frame.size.width;
    [super layoutSubviews];
}
@end
```

这时候，不需要两次调用super的layoutSubviews，因为当前layoutSubviews被调用的时候，父类的layoutSubviews已经被调用过了，我们已经知道了frame的尺寸。

在UIViewController中，需要在`viewDidLayoutSubviews`进行处理。

```
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    myLabel.preferredMaxLayoutWidth = myLabel.frame.size.width;
    [self.view layoutIfNeeded];
}
```

最后，不要有高优先级的显示Label的高度约束，否则会忽略内容计算出来的高度。

## 动画（Animation）

When it comes to animating views laid out with Auto Layout, there are two fundamentally different strategies: Animating the constraints themselves, and changing the constraints to recalculate the frames and use Core Animation to interpolate between the old and the new position.

The difference between the two approaches is that animating constraints themselves results in a layout that conforms to the constraint system at all times. Meanwhile, using Core Animation to interpolate between old and new frames violates constraints temporarily.

Directly animating constraints is really only a feasible strategy on OS X, and it is limited in what you can animate, since only a constraint’s constant can be changed after creating it. On iOS you would have to drive the animation manually, whereas on OS X you can use an animator proxy on the constraint’s constant. Furthermore, this approach is significantly slower than the Core Animation approach, which also makes it a bad fit for mobile platforms for the time being.

When using the Core Animation approach, animation conceptually works the same way as without Auto Layout. The difference is that you don’t set the views’ target frames manually, but instead you modify the constraints and trigger a layout pass to set the frames for you. On iOS, instead of:

```
[UIView animateWithDuration:1 animations:^{
    myView.frame = newFrame;
}];
```

you now write:

```
// update constraints
[UIView animateWithDuration:1 animations:^{
    [myView layoutIfNeeded];
}];
```

Note that with this approach, the changes you can make to the constraints are not limited to the constraints’ constants. You can remove constraints, add constraints, and even use temporary animation constraints. Since the new constraints only get solved once to determine the new frames, even more complex layout changes are possible.

The most important thing to remember when animating views using Core Animation in conjunction with Auto Layout is to not touch the views’ frame yourself. Once a view is laid out by Auto Layout, you’ve transferred the responsibility to set its frame to the layout system. Interfering with this will result in weird behavior.

This means also that view transforms don’t always play nice with Auto Layout if they change the view’s frame. Consider the following example:

```
[UIView animateWithDuration:1 animations:^{
    myView.transform = CGAffineTransformMakeScale(.5, .5);
}];
```

Normally we would expect this to scale the view to half its size while maintaining its center point. But the behavior with Auto Layout depends on the kind of constraints we have set up to position the view. If we have it centered within its super view, the result is as expected, because applying the transform triggers a layout pass which centers the new frame within the super view. However, if we have aligned the left edge of the view to another view, then this alignment will stick and the center point will move.

Anyway, applying transforms like this to views laid out with constraints is not a good idea, even if the result matches our expectations at first. The view’s frame gets out of sync with the constraints, which will lead to strange behavior down the road.

If you want to use transforms to animate a view or otherwise animate its frame directly, the cleanest technique to do this is to [embed the view into a container view](http://stackoverflow.com/a/14119154). Then you can override `layoutSubviews` on the container, either opting out of Auto Layout completely or only adjusting its result. For example, if we setup a subview in our container which is laid out within the container at its top and left edges using Auto Layout, we can correct its center after the layout happens to enable the scale transform from above:

```
- (void)layoutSubviews
{
    [super layoutSubviews];
    static CGPoint center = {0,0};
    if (CGPointEqualToPoint(center, CGPointZero)) {
        // grab the view's center point after initial layout
        center = self.animatedView.center;
    } else {
        // apply the previous center to the animated view
        self.animatedView.center = center;
    }
}
```

If we expose the `animatedView` property as an IBOutlet, we can even use this container within Interface Builder and position its subview with constraints, while still being able to apply the scale transform with the center staying fixed.

### 调试

使用下面语句可以打印视图堆栈。

```swift
print(self.view.value(forKey: "_autolayoutTrace"))
```

用下面这两个语句可以获取和打印当前面视图影响的约束。

```swift
print(self.view.constraintsAffectingLayout())
print(self.view.constraintsAffectingLayoutForAxis())
```



Another more visual way to spot ambiguous layouts is to use `exerciseAmbiguityInLayout`. This will randomly change the view’s frame between valid values. However, calling this method once will also just change the frame once. So chances are that you will not see this change at all when you start your app. It’s a good idea to create a helper method which traverses through the whole view hierarchy and makes all views that have an ambiguous layout “jiggle.”

```
@implementation UIView (AutoLayoutDebugging)
- (void)exerciseAmbiguityInLayoutRepeatedly:(BOOL)recursive
{
    #ifdef DEBUG
    if (self.hasAmbiguousLayout) {
        [NSTimer scheduledTimerWithTimeInterval:.5 
                                         target:self 
                                       selector:@selector(exerciseAmbiguityInLayout) 
                                       userInfo:nil 
                                        repeats:YES];
    }
    if (recursive) {
        for (UIView *subview in self.subviews) {
            [subview exerciseAmbiguityInLayoutRepeatedly:YES];
        }
    }
    #endif
}
@end
```





## 参考
- https://github.com/PureLayout/PureLayout/wiki/Tips-and-Tricks
- https://www.objc.io/issues/3-views/advanced-auto-layout-toolbox/








## 关于UIViewController的启动过程

UIViewController的启动过程，如下可以被重载定制的方法和行为的调用顺序：

```
0、loadView()    # 构建View图层，追加subviews元素，设置controller基础信息例如title，设置controller的view属性
-->
1、viewDidLoad()
-->
2、viewWillAppear()  #显示处理过程会自动调用layout的处理（4、5），但是layout处理不会自动调用约束更新，需要在Controller的视图上调用view.setNeedsUpdateConstraints()触发约束更新。通常应该在viewDidLoad()方法中加载
-->
3、updateViewConstraints()  # 需要View调用setNeedsUpdateConstraints()进行触发，当一个View有一个ViewController，这个消息被发送给Controller的updateViewConstraints()，而不是视图的updateConstraints()。重载方法应该调用父类的方法或者直接调用视图的updateViewConstraints()。
-->
4、viewWillLayoutSubviews()
-->
5、viewDidLayoutSubviews()
-->
6、viewDidAppear()
```

下面是UIViewController.updateViewConstraints()的帮助。

```
Note
It is almost always cleaner and easier to update a constraint immediately after the affecting change has occurred. For example, if you want to change a constraint in response to a button tap, make that change directly in the button’s action method.
建议在影响更新的地方直接更改约束更新，这样会更简单和清晰。如何处理之前的约束？
You should only override this method when changing constraints in place is too slow, or when a view is producing a number of redundant changes.
只有当很多约束需要更新，或更新太慢时才需要重载这个方法。
To schedule a change, call setNeedsUpdateConstraints() on the view. The system then calls your implementation of updateViewConstraints() before the layout occurs. This lets you verify that all necessary constraints for your content are in place at a time when your properties are not changing.
Your implementation must be as efficient as possible. Do not deactivate all your constraints, then reactivate the ones you need. Instead, your app must have some way of tracking your constraints, and validating them during each update pass. Only change items that need to be changed. During each update pass, you must ensure that you have the appropriate constraints for the app’s current state.
约束更新必须高效，你需要有机制跟踪变化的约束进行针对更新，不应该出现先禁用所有的约束然后再追加约束的操作手法。
Do not call setNeedsUpdateConstraints() inside your implementation. Calling setNeedsUpdateConstraints() schedules another update pass, creating a feedback loop.
不要在重载方法内部再调用setNeedsUpdateConstraints()，会死循环的。
Important
Call [super updateViewConstraints] as the final step in your implementation.
在重新方法的最后，要调用父类的updateViewConstraints()方法（实质会调用View的updateConstraints（）方法）。
```



## UIViewController使用Autolayout和Purelayout的最佳实践

```swift
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        ...
        return tableView
    }()


    override func loadView() { //固定写法
        super.loadView()
        
        setupAndComposeView()
        
        // bootstrap Auto Layout
        view.setNeedsUpdateConstraints()
    }
    
    override func setupAndComposeView() {
        super.setupAndComposeView()
        
        self.title = "Example List"

        view.addSubview(tableView)
    }

    fileprivate var didSetupConstraints = false
    override func updateViewConstraints() { //固定写法
        if (!didSetupConstraints) {
            setupConstraints()
        }
        //modifyConstraints()
        
        super.updateViewConstraints()
    }
    
    override func setupConstraints() {
        tableView.autoPinEdgesToSuperviewEdges()
    }
```



## UIView使用Autolayout和Purelayout的最佳实践

```swift
   override init(frame: CGRect) {//固定写法
        super.init(frame: frame)

        setupAndComposeView()

        // bootstrap Auto Layout
        self.setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Should overritted by subclass, setup view and compose subviews
    func setupAndComposeView() {
        // View setup
        //self.backgroundColor = UIColor(white: 0.1, alpha: 1.0)

        // Compose subviews
        //[label1, label2].forEach { (subview) in
        //    self.addSubview(subview)
        //}
    }


    fileprivate var didSetupConstraints = false
    override func updateConstraints() {//固定写法
        if (!didSetupConstraints) {
            setupConstraints()
        }
        modifyConstraints()

        super.updateConstraints()
    }

    // invoked only once
    func setupConstraints() {

    }

    // invoked every times when trigged by setNeedsUpdateConstraints()
    func modifyConstraints() {

    }
```







##### Handling View Rotations

As of iOS 8, all rotation-related methods are deprecated. Instead, rotations are treated as a change in the size of the view controller’s view and are therefore reported using the [`viewWillTransition(to:with:)`](https://developer.apple.com/documentation/uikit/uicontentcontainer/1621466-viewwilltransition) method. When the interface orientation changes, UIKit calls this method on the window’s root view controller. That view controller then notifies its child view controllers, propagating the message throughout the view controller hierarchy.

In iOS 6 and iOS 7, your app supports the interface orientations defined in your app’s `Info.plist` file. A view controller can override the [`supportedInterfaceOrientations`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621435-supportedinterfaceorientations)method to limit the list of supported orientations. Typically, the system calls this method only on the root view controller of the window or a view controller presented to fill the entire screen; child view controllers use the portion of the window provided for them by their parent view controller and no longer participate directly in decisions about what rotations are supported. The intersection of the app's orientation mask and the view controller's orientation mask is used to determine which orientations a view controller can be rotated into.

You can override the [`preferredInterfaceOrientationForPresentation`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621438-preferredinterfaceorientationfor) for a view controller that is intended to be presented full screen in a specific orientation.

When a rotation occurs for a visible view controller, the [`willRotate(to:duration:)`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621376-willrotate), [`willAnimateRotation(to:duration:)`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621458-willanimaterotation), and [`didRotate(from:)`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621492-didrotate) methods are called during the rotation. The [`viewWillLayoutSubviews()`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621437-viewwilllayoutsubviews) method is also called after the view is resized and positioned by its parent. If a view controller is not visible when an orientation change occurs, then the rotation methods are never called. However, the [`viewWillLayoutSubviews()`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621437-viewwilllayoutsubviews) method is called when the view becomes visible. Your implementation of this method can call the [`statusBarOrientation`](https://developer.apple.com/documentation/uikit/uiapplication/1623026-statusbarorientation) method to determine the device orientation.

NoteAt launch time, apps should always set up their interface in a portrait orientation. After the [`application(_:didFinishLaunchingWithOptions:)`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application) method returns, the app uses the view controller rotation mechanism described above to rotate the views to the appropriate orientation prior to showing the window.