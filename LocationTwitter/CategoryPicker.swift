//
//  CategoryPicker.swift
//  BeenThere
//
//  Created by 한석희 on 12/5/20.
//

import UIKit


class CategoryPicker: UITableViewController {
    
    // MARK:- ins vars
    var selectedCategoryName = ""
    let categories = [
      "맛집",
      "음식점",
        "술집",
      "클럽",
      "마트",
      "역사 유적",
      "집",
      "숙소",
      "카페",
      "공원",
      "관광지",
      "테마파크",
    "기타"
    ]
    var selectedIndexPath = IndexPath()

    
    //MARK:- Set up
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
          }
        }
        //
    }

    
    // MARK: - Table view data source
        // 1).
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
        // 2).
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let categoryName = categories[indexPath.row]
        cell.textLabel?.text = categoryName
        if  categoryName == selectedCategoryName{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "PickedCategory" {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
          selectedCategoryName = categories[ indexPath.row ]
        }
      }
    }

}

