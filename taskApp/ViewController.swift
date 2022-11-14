//
//  ViewController.swift
//  taskApp
//
//  Created by 上田大河 on 2022/11/06.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // fillerRowHeightは棒線の行を表示させるときに、一応おいておくためのやつ!
        // automaticDimentionとは、レイアウト(サイズ)を自動でやってくれる万能マン!
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    // 画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            //　謎です
            let task = Task()
            let allTasks = realm.objects(Task.self)
            // countは個数
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    // タスク入力画面から戻ってきた時に更新するやつ！
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    //　行の数を設定する場所！　リターンは具体的に何個入れるかを指定することができる
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count
    }
    // セルの中身を定義するためのもの！　多分遷移先の情報のことだと思う。。。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 謎です
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        return cell
    }
    // didSelectRowAtとprepareとの違いは何なのか知りたい？？？？？？？？？？？？
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    // 削除とか並び替えとかが編集できるかどうかのメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle{
        return .delete
    }
    // editingStyleForRowAtで編集した時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = self.taskArray[indexPath.row]
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                //　セルを消す際のアニメーション設定
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if searchBar.text != "" {
            let predicate = NSPredicate(format: "category = %@", searchBar.text!)
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "date", ascending: true)
        } else {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        }
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        }
        tableView.reloadData()
    }
}

