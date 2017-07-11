# ELPresentRotateView
<p align="center">
<img src="https://github.com/emmet7life/ELPresentRotateView/blob/master/appIcon.png" alt="ELPresentRotateView" title="ELPresentRotateView" width="120" />
</p>
<p>
<img src="https://img.shields.io/badge/build-passing-brightgreen.svg" />
<img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" />
</p>

(ELPresentRotateView act a part of container view that any view can in it help them to auto rotate to a new viewController by present.)

## 简介
ELPresentRotateView作为一个可以容纳任何视图组件的容器视图角色，可以帮助任何视图控件来自动(在一定条件下)或者手动 😆 以present的形式来旋转它们到新的试图控制器中。(利用自定义转场动画)类似 今日头条、优酷、爱奇艺等视频类APP的视频旋转效果。但是其实不止可以用来做视频的旋转，还可以用于其他用途，看具体需求可以灵活变通。

## 使用步骤
1. 添加库组件到目标组件

举一个例子，比如你有一个布局，布局内有一个视频播放器组件 `C` ,组件 `C` 的父控件是控件 `A`，想让 `C` 组件实现类似今日头条的视频旋转功能，那么需要在 `A` 和 `C` 中间添加一个中间件，就是本库提供的组件 ELPresentRotateView，假设称作组件 `B`，之前 `C` 是如何布局在 `A` 中，此时你就只要把布局关系设置给 `B` 即可，然后让 `C` 与 `B` 的上下左右对齐布局即可。（通过代码或者在Storyboard或者Xib中添加这样的布局关系皆可）

2. 注册

其实就是绑定必要的数据给组件，如Controller，delegate代理等。如演示代码中的 `Demo2ViewController` 所示：
```swift
presentRotateView.register(self, delegate: self)
```
第一个参数是UIViewControlelr类型的参数，一般为当前视图所在的视图控制器，用来调用present方法。第二个参数是实现了ELPresentRotateViewDelegate协议的对象，一般也为当前视图控制器，用来回调一些事件或者获取一些参数。

3. 手动旋转至全屏

调用库组件视图的 `onPresentRotateViewRotateControlBtnTapped()` 方法即可。返回至非全屏状态也是调用此方法，内部会自动判断当前状态并作出相应的响应。

4. 自动旋转至全屏

一般情况下，视频播放器都会有一个播放状态，比如初始状态，播放中，暂停，停止等，在 今日头条 视频类APP中可以看到，如果用户手机当前处于竖屏状态，此时点击某视频的播放按钮开始观看视频，此时旋转手机至横屏时，视频会自动旋转至横屏模式，再次将手机旋转至竖屏时，视频旋转归位回竖屏模式。
这其中便涉及到了一个视频当前的播放状态的问题，因此库组件也简单的提供了一个状态枚举和对应的方法 `onPresentRotateViewPlayControlBtnTapped()` 供使用，在视频的播放状态满足可自动旋转时，会触发自动旋转功能。

3. 注销

在当前视图控制器销毁时最好调用一次 `unregister()` 方法，注销监听、代理等。(为了确保引发不必要的问题，库组件在 `deinit {}` 也调用了一遍)

4. 自定义present出来的视图控制器

一般情况下，使用库自带的 `BasicELPresentRotateViewController` 即可，但是用户也可以通过继承 `BasicELPresentRotateViewController` 或者 使用自己的UIViewController然后实现ELPresentRotateViewControllerProtocol协议来自定义present出来时的UI界面。具体使用请看Demo，比较简单。


## 注意事项
1. 如果在UITableView或者UICollectionView等这种涉及到视图重用的视图中使用要格外注意，在其对应代理的 `didEndDisplaying` 系列方法中，调用 `unregister()` 方法。


## TodoList
* 可选的触摸手势监听及其对应的事件回调(之所以可选是因为一般情况下，视频播放器视图应该都具备了这些功能)

## Contact
Follow and contact me on [Sina Weibo](http://weibo.com/chenjianli1988). 

## License
ELPresentRotateView is released under the MIT license. See LICENSE for details.

## 演示gif
![Demo1](https://github.com/emmet7life/ELPresentRotateView/blob/master/Demo1.gif "Demo1")
![Demo2](https://github.com/emmet7life/ELPresentRotateView/blob/master/Demo2.gif "Demo2")
![Demo3](https://github.com/emmet7life/ELPresentRotateView/blob/master/Demo3.gif "Demo3")

