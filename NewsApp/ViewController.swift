//
//  ViewController.swift
//  NewsApp
//
//  Created by 海法修平 on 2019/08/08.
//  Copyright © 2019 shu26. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        searchBar.placeholder = "知りたいニュースを検索"
        tableView.dataSource = self
        tableView.delegate = self
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // お菓子のリスト（タプル配列）
    var newsList: [(title: String, description: String, link: URL, image:URL)] = []
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if let searchWord = searchBar.text {
            print(searchWord)
            // 入力されていたら，ニュースを検索
            searchNews(keyword: searchWord)
        }
    }
    
    // JSONのitem内のデータ構造
    struct ItemJson: Codable {
        // ニュースのタイトル
        let title: String?
        // 詳細
        let description: String?
        // 掲載URL
        let url: URL?
        // 画像URL
        let urlToImage: URL?
    }
    
    // JSONのデータ構造
    struct ResultJson: Codable {
        // 複数要素
        let status: String?
        let totalResults: Int?
        let articles: [ItemJson]?
        
    }
    
    // searchNews
    func searchNews(keyword: String) {
        // 検索キーワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        // リクエストURLの組み立て
        guard let req_url = URL(string: "https://newsapi.org/v2/everything?q=\(keyword_encode)&apiKey=ed760abfb6064234babe7dab90b35842")
            else {
            return
        }
        
        print(req_url)
        
        // リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        // データ転送を管理するためのセッションを生成
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        // リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            // セッションを終了
            session.finishTasksAndInvalidate()
            // do try catch エラーハンドリング
            do {
                //JSONDecoderのインスタンスを取得
                let decoder = JSONDecoder()
                // 受け取ったJSONデータをパース（解析）して格納
                let json  = try decoder.decode(ResultJson.self, from: data!)
                
                // ニュースの情報が取得できているか確認
                if let articles = json.articles{
                    // ニュースのリストを初期化
                    self.newsList.removeAll()
                    // 取得しているお菓子の数だけ処理
                    for article in articles {
                        // ニュースのタイトル，詳細，掲載URL，画像URLをアンラップ
                        if let title = article.title, let description = article.description, let url = article.url, let urlToImage = article.urlToImage {
                            // 一つのニュースをタプルでまとめて管理
                            let news = (title, description, url, urlToImage)
                            // お菓子の配列への追加
                            self.newsList.append(news)
                        }
                    }
                    // TableViewを更新する
                    self.tableView.reloadData()
                    
                    if let newsdbg = self.newsList.first {
                        print("---------------------")
                        print("newsList[0] = \(newsdbg)")
                    }
                }
            } catch {
                // エラー処理
                print("エラーが出ました")
            }
        })
        // ダウンロード開始
        task.resume()
    }
    
    // Cellの総数を返すdatasourceメソッド，必須
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    // Cellに値を設定するdatasourceメソッド，必須
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 今回表示を行う，Cellオブジェクト（１行）を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        // ニュースのタイトル設定
        cell.textLabel?.text = newsList[indexPath.row].title
        // テキストの折り返し
        cell.textLabel?.numberOfLines = 0
        // ニュースの画像を取得
        if let imageData = try? Data(contentsOf: newsList[indexPath.row].image) {
            // 正常に取得できた場合は，UIImageで画像オブジェクトを生成して，Cellにお菓子画像を設定
            cell.imageView?.image = UIImage(data: imageData)
        }
        // 設定ずみのCellオブジェクトを画面に反映
        return cell
    }
    
    // Cellが選択された時に呼び出されるdelegateメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        // SFSafariViewを開く
        let safariViewController = SFSafariViewController(url: newsList[indexPath.row].link)
        
        // delegateの通知先を自分自身
        safariViewController.delegate = self
        
        // SafariViewが開かれる
        present(safariViewController, animated: true, completion: nil)
    }
    
    // セルの高さ上限
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // SafariViewが閉じられた時に呼ばれるdelegateメソッド
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // SafariViewを閉じる
        dismiss(animated: true, completion: nil)
    }
}


