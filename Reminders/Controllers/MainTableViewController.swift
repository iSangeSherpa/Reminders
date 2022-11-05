import UIKit
import UserNotifications

class MainTableViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    var models = [MyReminder]()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }
    
    @IBAction func didTapAdd() {
        // show add VC
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "add") as? AddViewController else {return}
        
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .always
        vc.completion = { title, body, date in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                let new = MyReminder(title: title, date: date, identifier: "id_\(title)")
                self.models.append(new)
                self.table.reloadData()
                
                let content = UNMutableNotificationContent()
                content.title = title
                content.sound = .default
                content.body = body
                
                let targetDate = date
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
                
                let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("Something went wrong")
                    }
                })
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
        
    @IBAction func didTapTest() {
        
        // fire test notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
            if success {
                self.scheduleTest()
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        })
        
    }
    
        
    func scheduleTest() {
        let content = UNMutableNotificationContent()
        content.title = "Hello World"
        content.sound = .default
        content.body = "This is the body.... This is the body.... This is the body.... This is the body.... This is the body...."
        
        let targetDate = Date().addingTimeInterval(10)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("Something went wrong")
            }
        })
    }
    
}



extension MainTableViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        
        let date = models[indexPath.row].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM, dd, YYYY0"
        cell.detailTextLabel?.text = dateFormatter.string(from: date)
        return cell
    }
    
}

extension MainTableViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
