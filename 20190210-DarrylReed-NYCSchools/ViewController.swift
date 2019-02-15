//
//  ViewController.swift
//  20190210-DarrylReed-NYCSchools
//
//  Created by DLR on 2/9/19.
//  Copyright © 2019 DLR. All rights reserved.
//

import UIKit

// Storing JSON keys for easy reference in a custom model object
struct Keys {
    let dbn = "dbn"
    let schoolName = "school_name"
    let numOfTestTakers = "num_of_sat_test_takers"
    let satReadingScore = "sat_critical_reading_avg_score"
    let satMathScore = "sat_math_avg_score"
    let satWritingScore = "sat_writing_avg_score"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapBtn: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet var infoLabel: ItermittentLabel!

    var alertView: UIAlertController!
    
    var isMapView = false
    var mapViewController : MapViewController?
    
    var schoolDict = [String: String]()
    var schoolDataStructArr = [SchoolSATDataStruct]()
    
    var counter = 0
    
    var firstLoadLbl: String = "25% Loaded..."
    var secondLoadLbl: String = "50% Loaded..."
    var thirdLoadLbl: String = "75% Loaded..."
    var fourthLoadLbl: String = "100% Loaded..."
    var durationLbl: String = "\(0.7.description)"
    
    var offset = UIOffset()
    let placeholderWidth = 200 // Replace with whatever value works for your placeholder text

    let search = UISearchController(searchResultsController: nil)

    let schDataURL = "https://data.cityofnewyork.us/resource/97mf-9njv.json"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadContent()
        animateTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Making sure tableView delegate and data source funcs will be called
        tableView.dataSource = self
        tableView.delegate = self
        
        self.mapViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as? MapViewController
        
        // Add an alert view programmatically
        alertView = UIAlertController(title: "Alert", message: "Could not load data from API", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
    }

    // MARK: - Functions
    
    @objc func loadContent() {
        
        self.view.addSubview(progressView)
        
        self.progressView.layer.cornerRadius = 10
        self.progressView.clipsToBounds = true
        
        flipString()
        activityIndicator.startAnimating()
        
        // get school list from web
        if schoolDataStructArr.count == 0 {
            self.loadSchoolData()
        } else {
            self.tableView.reloadData()
        }
        
        // do your request here, instead of the dispatch_after call
        let delayTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.counter = 5
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.progressView.isHidden = true
        }
    }
    
    func flipString() {
        self.view.endEditing(true)
        
        if firstLoadLbl == "" || secondLoadLbl == "" || thirdLoadLbl == "" || fourthLoadLbl == "" || durationLbl == "" {
            return
        }
        
        self.infoLabel.startFlippingLabels("\(firstLoadLbl.description)", label2Text: "\(secondLoadLbl.description)", label3Text: "\(thirdLoadLbl.description)", label4Text: "\(fourthLoadLbl.description)", duration: TimeInterval(durationLbl)!)
    }
    
    func stopFlipping() {
        self.infoLabel.stopFlippingLabels()
    }
    
    func animateTable() {
        self.tableView.reloadData()
        
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
    
    // Making API call to get school names and dbns
    func loadSchoolData() {
        // Start the animat
        activityIndicator.startAnimating()
        guard let schoolUrl = URL(string: "https://data.cityofnewyork.us/resource/97mf-9njv.json") else {
            alertView.message = "Could not convert https://data.cityofnewyork.us/resource/97mf-9njv.json to URL"
            self.present(self.alertView, animated: true, completion: nil)
            return
        }
        // Making the API call
        let schoolTask = URLSession.shared.dataTask(with: schoolUrl) { (data, resp, err) in
            guard let dataResp = data,
                err == nil else {
                    self.alertView.message = err?.localizedDescription ?? "Error receiving data"
                    self.present(self.alertView, animated: true, completion: nil)
                    return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: dataResp, options: [])
                guard let jsonDict = json as? [[String: String]] else {
                    self.alertView.message = "Could not convert json to [String: String]"
                    self.present(self.alertView, animated: true, completion: nil)
                    return
                }
                // Initial storing of [dbns: school names]
                for i in 0..<jsonDict.count {
                    self.schoolDict[jsonDict[i][Keys().dbn]!] = jsonDict[i][Keys().schoolName]!
                }
                self.loadSATData()
            } catch let parsingErr {
                self.alertView.message = parsingErr.localizedDescription
                self.present(self.alertView, animated: true, completion: nil)
            }
        }
        schoolTask.resume()
    }
    
    // Making API call to get SAT scores for the schools
    func loadSATData() {
        guard let satURL = URL(string: "https://data.cityofnewyork.us/resource/734v-jeq5.json") else {
            alertView.message = "Could not convert https://data.cityofnewyork.us/resource/734v-jeq5.json to URL"
            self.present(self.alertView, animated: true, completion: nil)
            return
        }
        // Making the API call
        let satTask = URLSession.shared.dataTask(with: satURL) { (data, resp, err) in
            guard let dataResp = data,
                err == nil else {
                    self.alertView.message = err?.localizedDescription ?? "Error receiving data"
                    self.present(self.alertView, animated: true, completion: nil)
                    return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: dataResp, options: [])
                guard let jsonDict = json as? [[String: String]] else {
                    self.alertView.message = "Could not convert json to [String: String]"
                    self.present(self.alertView, animated: true, completion: nil)
                    return
                }
                // Creating custom school struct for easy data access
                for i in 0..<jsonDict.count {
                    let schoolDBN = jsonDict[i][Keys().dbn]!
                    if self.schoolDict[schoolDBN] != nil {
                        var schoolDataStruct = SchoolSATDataStruct()
                        schoolDataStruct.dbn = schoolDBN
                        schoolDataStruct.name = self.schoolDict[schoolDBN]
                        schoolDataStruct.numOfTestTakers = jsonDict[i][Keys().numOfTestTakers]!
                        schoolDataStruct.critReadingScore = jsonDict[i][Keys().satReadingScore]!
                        schoolDataStruct.mathScore = jsonDict[i][Keys().satMathScore]!
                        schoolDataStruct.writingScore = jsonDict[i][Keys().satWritingScore]!
                        self.schoolDataStructArr.append(schoolDataStruct)
                    }
                }
                // Updates to UI are on the main thread
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            } catch let parsingErr {
                self.alertView.message = parsingErr.localizedDescription
                self.present(self.alertView, animated: true, completion: nil)
            }
        }
        satTask.resume()
    }
    
    // MARK: - Buttons

    @IBAction func mapBtnPressed(_ sender: Any) {
        let image1 = UIImage(named: "mapBarIcon.png")!
        let image2 = UIImage(named: "listIcon.png")!
        if(isMapView) {
            self.tableView.frame = self.view.bounds; //grab the view of a separate VC
            self.mapBtn.tintColor = UIColor.clear
            self.title = "NYC Schools & SAT Scores"
            self.mapBtn.setBackgroundImage(image1, for: .normal, barMetrics: .default)
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationTransition(.flipFromLeft, for: (self.view)!, cache: false)
            self.mapViewController?.view.removeFromSuperview()
            self.view.addSubview(self.tableView)
            UIView.commitAnimations()
        } else {
            self.mapViewController?.view.frame = self.view.bounds; //grab the view of a separate VC
            self.mapBtn.tintColor = UIColor.clear
            self.title = "NYC School Locations"
            self.mapBtn.setBackgroundImage(image2, for: .normal, barMetrics: .default)
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationTransition(.flipFromRight, for: (self.view)!, cache: false)
            self.mapViewController?.view.removeFromSuperview()
            self.view.addSubview((self.mapViewController?.view)!)
            UIView.commitAnimations()
//            self.mapViewController?.loadMapFor()
        }
        self.isMapView = self.isMapView ? false : true
    }
    
}

// MARK: - Datasource, Delegate functions
extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return schoolDataStructArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let headerTitles = ["\(schoolDataStructArr[section].name!)"]
        if section < headerTitles.count {
            return headerTitles[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.schoolDataStructArr[section].name.count == 0 ? CGFloat(50) : 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        
        let view = UIView(frame: CGRect(x: 10, y: 0, width: self.view.frame.width, height: 50))
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: self.view.frame.width, height: 50))
        headerLabel.text = "\(schoolDataStructArr[section].name!)"
        headerLabel.attributedText = NSAttributedString(string: "\(schoolDataStructArr[section].name!)", attributes:
            [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])

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
        view.backgroundColor = UIColor.white
        
        let satGroupLabel = UILabel(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: 25))
        satGroupLabel.text = "Testers      Avg. Math      Reading      Writing"
        satGroupLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        satGroupLabel.textColor = .blue
        satGroupLabel.backgroundColor = .white
        satGroupLabel.textAlignment = .center
        satGroupLabel.adjustsFontSizeToFitWidth = true
        satGroupLabel.allowsDefaultTighteningForTruncation = true
        headerView.addSubview(satGroupLabel)
        
        var headerViews = Dictionary<String, UIView>()
        headerViews["title"] = headerLabel
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        for _ in indexPath {
            // Configure the cell...
            let schoolCellID = "schoolSATCell"
            let schoolCell = tableView.dequeueReusableCell(withIdentifier: schoolCellID, for: indexPath) as! schoolSATCell
            schoolCell.layer.backgroundColor = UIColor.white.cgColor
            schoolCell.testTakersLabel.text = schoolDataStructArr[indexPath.section].numOfTestTakers!
            schoolCell.readingScoreLabel.text = schoolDataStructArr[indexPath.section].critReadingScore!
            schoolCell.mathScoreLabel.text = schoolDataStructArr[indexPath.section].mathScore!
            schoolCell.writingScoreLabel.text = schoolDataStructArr[indexPath.section].writingScore!
            return schoolCell
        }
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
//        vc?.title = "\(self.schoolDataStructArr[indexPath.row].name!) Info"
        self.navigationController?.pushViewController(vc!, animated: true)
//        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationController?.navigationBar.topItem?.title = "\(self.schools[indexPath.row].schoolName) Info"
//        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
    }
}

// MARK: - UITableViewCell classes

class schoolSATCell: UITableViewCell {
    @IBOutlet weak var testTakersLabel: UILabel!
    @IBOutlet weak var mathScoreLabel: UILabel!
    @IBOutlet weak var readingScoreLabel: UILabel!
    @IBOutlet weak var writingScoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // No need for selecting cells
        self.selectionStyle = .none
    }
}
