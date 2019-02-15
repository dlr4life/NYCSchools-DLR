//
//  DetailViewController.swift
//  20190210-DarrylReed-NYCSchools
//
//  Created by DLR on 2/9/19.
//  Copyright © 2019 DLR. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Additional Info."

    }
    
    // MARK: - Functions
    
    func animateTable() {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
}

// MARK: - Datasource, Delegate functions
extension DetailViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let headerTitles = ["School:"]
        
        if section < headerTitles.count {
            return headerTitles[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width, height: 50))
        headerLabel.text = "School: "
        headerLabel.attributedText = NSAttributedString(string: "School: ", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        headerLabel.textColor = .black
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 2
        headerLabel.baselineAdjustment = UIBaselineAdjustment(rawValue: 1)!
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.allowsDefaultTighteningForTruncation = true
        headerLabel.font = UIFont(name: "Avenir", size: 18.0)
        headerLabel.backgroundColor = UIColor.white
        headerView.addSubview(headerLabel)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "gradeCell")
            cell?.textLabel?.text = "Grades: ? - 12"
            cell?.backgroundColor = .white
            cell?.textLabel?.textAlignment = .center
            return cell!
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "websiteCell")
            cell?.textLabel?.text = "Website: https://???.com/"
            cell?.backgroundColor = .white
            cell?.textLabel?.textAlignment = .center
            return cell!
        }
        return UITableViewCell.init()
    }
}
