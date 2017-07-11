//
//  ViewController.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 16/11/30.
//  Copyright © 2016年 陈建立. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var texts: [String] = [
        "楚乔/星儿/荆小六 - [演员 赵丽颖] - 奴籍少女，秀外慧中，坚韧果敢，侠骨柔肠。因奴隶身份曾被当作箭靶命悬一线，目睹身边亲人惨遭蹂躏致死；她痛恨这视生命如草芥的年代，奋起抗争踏上改革之路；披荆斩棘推翻奴隶政权，谋求天下大同，开创青海昌盛太平。苍生血泪千帆尽，同舟共济与君还。乱世风谲云诡，她心随光亮灿若星子，砺炼成胸怀天下威震四海的秀丽王。",
        "宇文玥 - [演员 林更新] - 宇文府四少爷，智勇双全，武功高强。受到楚乔的影响，于偏执中睁开锐利的双眸，历经人事沉浮，从阴险市侩的门阀贵族，转变为悲天悯人的青海王。自尸山血海中涅槃而生，是一座真正巍峨不动的高山。他琴心剑胆军事才能杰出，跟随楚乔一同缔造了新的王国。",
        "燕洵 - [演员 窦骁] - 西凉世子，冷静腹黑多疑，幼年眼见家族被魏皇灭门，身负血海深仇。与楚乔少年相识两小无猜，相互扶协忍辱负重，如履薄冰筹谋八年，一朝血洗真煌城称霸为帝，野心膨胀与楚乔分道扬镳，赢得江山失去了挚爱。"
    ]

    var images:[String] = [
        "https://ss0.bdstatic.com/-0U0bnSm1A5BphGlnYG/tam-ogel/1ccada6003d756bb070d385be2c11a85_660_200.jpg",
        "https://ss0.bdstatic.com/-0U0bnSm1A5BphGlnYG/tam-ogel/a9c1792d409ec5717f6606e1fe918f67_660_200.jpg",
        "https://ss0.bdstatic.com/-0U0bnSm1A5BphGlnYG/tam-ogel/f84ae83eeb4dc9fc50a96292ef83ad67_660_200.jpg",
        "https://ss0.bdstatic.com/-0U0bnSm1A5BphGlnYG/tam-ogel/d1ddf6e51d65615386a324ffd433ab19_660_200.jpg",
        "https://ss0.bdstatic.com/-0U0bnSm1A5BphGlnYG/tam-ogel/c77f274fdc55b87c9548a1cfe94e69fe_660_200.jpg",

        "https://gss0.baidu.com/7LsWdDW5_xN3otqbppnN2DJv/space/pic/item/14ce36d3d539b60010e41dd8e350352ac65cb7b2.jpg",
        "https://gss0.baidu.com/7LsWdDW5_xN3otqbppnN2DJv/space/pic/item/a2cc7cd98d1001e973160660b20e7bec54e797b2.jpg",
        "https://gss0.baidu.com/7LsWdDW5_xN3otqbppnN2DJv/space/pic/item/a50f4bfbfbedab64c0585faffd36afc379311eb2.jpg",
        "https://gss0.baidu.com/7LsWdDW5_xN3otqbppnN2DJv/space/pic/item/aec379310a55b3192005911a49a98226cefc17e4.jpg"
    ]

    let cellCount = 18
    var cellImageURLs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "TableView Cell"

        let key = RandomUtilities.shared.append(images)
        for _ in 0 ..< cellCount {
            if let value = RandomUtilities.shared.randomValue(with: key) {
                cellImageURLs.append(value)
            }
        }

        view.backgroundColor = UIColor.white

        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = .top

        tableView.estimatedRowHeight = 242.0
        tableView.rowHeight = -1

        tableView.delegate = self
        tableView.dataSource = self

        // 隐藏导航栏时，由全屏状态返回到非全屏状态时位置是对的，%>_<%
        // 可以打开下面的注释来查看效果，(观察了一下，高度差应该是状态栏的高度24.0左右，所以应该是状态栏影响的，有待解决)
        // navigationController?.setNavigationBarHidden(true, animated: true)
    }

    deinit {
        print("DemoViewController deinit >> 😄")
    }

    /// 屏幕方向仅支持竖屏
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}

extension DemoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellImageURLs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? PresentRotateViewDemoTableViewCell {
            cell.targetController = self
            cell.resetStateIfNeeded()
            cell.setLabelText(texts[indexPath.row % 3])
            cell.setImages(cellImageURLs[indexPath.row])
        }
        return cell
    }

}

extension DemoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 242.0
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PresentRotateViewDemoTableViewCell {
            cell.register()
            cell.resetStateIfNeeded()
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PresentRotateViewDemoTableViewCell {
            cell.unregister()
            cell.resetStateIfNeeded()
        }
    }

}
