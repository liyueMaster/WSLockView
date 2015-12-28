# WSLockView

swift实现的图形解锁

高度可自定义，使用简单

只需要在IB中拖入一个UIView，并且将类修改为自定义WSLockView类；当然也可以使用代码创建，用法与UIView类似

通过设置代理，来获取用户操作结果

func lockView(lockView: WSLockView, didFinishPath path: String)

可自定义的属性有：

    //按钮大小
    public var btnSize: CGFloat = 74.0
    
    //按钮数量，仅限可以开平方且大于等于4的数字
    public var btnCount: Int = 9
    
    //连线颜色
    public lazy var lineColor: UIColor = UIColor.blueColor()
    
    //连线宽度
    public var lineWidth: CGFloat = 8.0
    
    //使用圆形区域按钮
    public var useCircleArea: Bool = true
    
使用圆形区域来判断，可以增加用户操作的准确性
