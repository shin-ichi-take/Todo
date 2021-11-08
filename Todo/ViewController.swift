//
//  ViewController.swift
//  Todo
//
//  Created by 竹村信一 on 2020/11/17.
//  Copyright © 2020 S.Takemura. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    var tableView = UITableView()
    var dataList:TodoDataList = .data
    var addButton = UIButton(type: .contactAdd)
    
    // SceneDelegate.swiftでステータスバーの高さを取得して設定
    var statusBarHeight = CGFloat()
    
    // お馴染みのviewDidLoad()
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //非推奨
        //let statusBarFrameHeight = UIApplication.shared.statusBarFrame.height
        
        let screenW = view.bounds.width
        let screenH = view.bounds.height
        
        
        //ボタンの設定
        addButton.center = CGPoint(x: screenW-addButton.bounds.width, y: statusBarHeight+addButton.bounds.height/2)
        addButton.addTarget(self, action: #selector(addButtonAction(_:)), for: .touchUpInside)
        view.addSubview(addButton)
        
        
        //テーブルビューの設定
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "todoCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = CGRect(x: 0, y: addButton.bounds.height+statusBarHeight, width: screenW, height: screenH-addButton.bounds.height-statusBarHeight)
        view.addSubview(tableView)
        
        
        
        
    }
    //プロトコルのメソッドを実行する必要がある
    
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.list.count
    }
    
    //セルにどんなデータを表示するか
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        //セルに表示するタスク名
        let todoItem = dataList.list[indexPath.row]
        cell.textLabel?.text = todoItem.text
        //完了マーク
        cell.accessoryType = todoItem.done ? .checkmark : .none

        return cell
    }
    
    //セルの編集が可能かどうか
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //追加
    
    //タップ処理 UITableViewDelegateのメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoItem = dataList.list[indexPath.row]
        //状態を反転させる
        todoItem.done = !todoItem.done
        //セルの状態を変更する
        // withはアニメーション
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        dataList.save()//状態をセーブする
    }
    
    
    //削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //削除処理かどうか判定する
        if editingStyle == .delete{
            //データリストから削除する
            dataList.list.remove(at: indexPath.row)
            dataList.save()//セーブする
            //セルを削除する
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //addButtonのアクション
    @objc func addButtonAction(_ sender:UIButton){
        let alertController = UIAlertController(title: "Add item", message: "内容を入力してください", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil) // テキストエリア
        
        //OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            
            if let text = alertController.textFields?.first?.text{
                let todo = TodoData(text)
                self.dataList.list.insert(todo, at: 0) //先頭に追加
                self.dataList.save() //セーブする
                
                //追加されたことを通知する
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
            }
        })
        
        // OKボタンタップ時の動作
        alertController.addAction(okAction)
        
        // キャンセルがたっぷされたとき
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        // ダイアログを表示する
        present(alertController,animated:true,completion:nil)
    }

}

// Todoデータのリスト
class TodoDataList: Codable{
    class var data:TodoDataList{
        get{
            return TodoDataList()
        }
    }
    
    var list:[TodoData] = []
    init(){
        // JSONDecoderで得たData型をTodoDataListクラスにデコードする
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase // 書式
        if let data = UserDefaults.standard.data(forKey: "data"),
            let datalist = try? jsonDecoder.decode(TodoDataList.self, from: data){
            self.list = datalist.list
        }
        
    }
    // 現在のtodoだデータをセーブする関数
    func save(){
        // JSONEncoderで自身(self)をData型へエンコードしてUserDefaultsにセットする
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase // 書式
        guard let data = try? jsonEncoder.encode(self) else {
            return
        }
        UserDefaults.standard.set(data, forKey: "data")
    }
    
}

class TodoData:Codable{
    var text:String
    var done:Bool
    init(_ text:String){
        self.text = text
        self.done = false
    }
}
