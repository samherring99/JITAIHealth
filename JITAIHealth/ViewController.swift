//
//  ViewController.swift
//  JITAIHealth
//
//  Created by Sam Herring on 7/31/20.
//

import UIKit
import WatchConnectivity

class Cell: UITableViewCell {
    var tf = UITextField()
}

class ViewController: UIViewController, WCSessionDelegate, UITextFieldDelegate {
    
    // MARK: -  Initialization
    
    @IBOutlet var hrLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var tagButton: UIButton!
    
    var session : WCSession? // WatchConnectivity Session
    
    var custom = false
    
    let transparentView = UIView()
    let tableView = UITableView()
    
    var dataSource = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        
        dataSource = ["Home", "Work", "Gym", "Other"]
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            
            // Above code activates the WC Session, below is debug UI
            
            activityLabel.text = "active"
            hrLabel.text = "recieving"
        }
    }
    
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = self.view.frame ?? window?.frame as! CGRect
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: 2.0 * frames.width, height: 0)
        
        self.view.addSubview(tableView)
        
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut) {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: 2.0 * frames.width, height: CGFloat(self.dataSource.count * 50))
        } completion: { (nil) in }

    }
    
    @objc func removeTransparentView() {
        let frames = tagButton.frame
        disableTextField()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut) {
            self.transparentView.alpha = 0.0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: 2.0 * frames.width, height: 0)
        } completion: { (nil) in }
    }
    
    
    
    // MARK: - WCSession code
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        // WCSession is activated, watch and phone are connected.
        print("Session active")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        let recievedData : [Double] = messageData.toArray(type: Double.self)
        
        // Update handler for WCSession message passing, called when phone recieves message update from watch.
        
        // Below is main case to display watch message.
        
        DispatchQueue.main.async {
            switch recievedData[0] {
            case 0.0:
                print("sitting")
                self.activityLabel.text = "sitting"
            case 1.0:
                print("walking")
                self.activityLabel.text = "walking"
            default:
                print("unknown")
                self.activityLabel.text = "unknown"
            }
            
            print(recievedData[1])
            
            self.hrLabel.text = "HR: \(recievedData[1]) ❤️"
        }

    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Session is connected but not active in watch.
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Session is disconnected from watch.
    }

    @IBAction func displayLocMenu(_ sender: Any) {
        addTransparentView(frames: tagButton.frame)
    }
    
}

// External data utilities for message sending.

// MARK: - Extensions

extension Data {

    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }
    
    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
    
    init<T>(fromArray values: [T]) {
        self = values.withUnsafeBytes { Data($0) }
    }
    
    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.tf.text = ""

        if (!custom) { cell.tf.isEnabled = false }
        
        cell.tf.delegate = self
        cell.tf.frame = cell.frame
        
        
        cell.contentView.addSubview(cell.tf)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(dataSource)
        
        disableTextField()
        
        dataSource.insert(textField.text!, at: dataSource.count - 1)
        tableView.insertRows(at: [IndexPath(row: dataSource.count - 1, section: 0)], with: .automatic)
        dataSource.remove(at: 0)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: IndexPath(row: 0, section: 0)) as! Cell
        
        cell.tf.isEnabled = true
        
        if (indexPath.row == dataSource.count - 1) {
            
            cell.tf.isHidden = false
            cell.tf.allowsEditingTextAttributes = true
            cell.tf.frame = cell.frame
            cell.tf.text = "Type a custom location..."
            
            let indexPath = IndexPath(row: 0, section: 0)
            dataSource.insert("", at: indexPath.row)
            tableView.insertRows(at: [indexPath], with: .automatic)

            for n in 0...dataSource.count - 1 {
                let cp = tableView.cellForRow(at: IndexPath(row: n, section: 0)) as? Cell
                cp?.tf.isEnabled = true
            }
            
            custom = true
            tableView.reloadData()
        } else {
            print(dataSource[indexPath.row])
            removeTransparentView()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func disableTextField() {
        for n in 0...dataSource.count - 1 {
            let cp = tableView.cellForRow(at: IndexPath(row: n, section: 0)) as? Cell
            cp?.tf.isEnabled = false
        }
    }
}

