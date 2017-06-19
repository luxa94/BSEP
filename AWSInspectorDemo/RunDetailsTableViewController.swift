//
//  RunDetailsTableViewController.swift
//  AWSInspectorDemo
//
//  Created by Nikola Lukic on 6/19/17.
//  Copyright © 2017 Nikola Lukic. All rights reserved.
//

import UIKit
import Alamofire

class RunDetailsTableViewController: IndicatorTableViewController {

    private static let ARNS_PROPERTY = "assessmentRunArns"

    private static let DETAILS_SECTION = 0
    private static let FINDINGS_SECTION = 1
    private static let NOTIFICATIONS_SECTION = 2
    private static let RULE_ARNS_SECTION = 3
    private static let USER_ATTRIBUTES_SECTION = 4

    @IBOutlet weak var arnCell: UITableViewCell!
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var templateArnCell: UITableViewCell!
    @IBOutlet weak var completedAtCell: UITableViewCell!
    @IBOutlet weak var createdAtCell: UITableViewCell!
    @IBOutlet weak var dataCollectedCell: UITableViewCell!
    @IBOutlet weak var durationCell: UITableViewCell!
    @IBOutlet weak var startedAtCell: UITableViewCell!
    @IBOutlet weak var stateCell: UITableViewCell!
    @IBOutlet weak var stateChangedAtCell: UITableViewCell!

    let requestProcessor = RequestProcessor()

    var runArn: String?
    var run: AssessmentRun?

    var findingCounts: [StringInt] = []
    var notifications: [AssessmentRunNotification] = []
    var rulePackageArns: [String] = []
    var userAttributesForFindings: [UserAttributeForFindings] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "BasicCell", bundle: nil), forCellReuseIdentifier: "BasicCell")
        tableView.register(UINib(nibName: "SubtitleCell", bundle: nil), forCellReuseIdentifier: "SubtitleCell")
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")

        tableView.estimatedRowHeight = 60
    }

    override func viewWillAppear(_ animated: Bool) {
        if let arn = runArn {
            showIndicator()
            fetchRunDetails(arn: arn)
        }
    }

    func fetchRunDetails(arn: String) {
        let parameters = Arns(jsonName: RunDetailsTableViewController.ARNS_PROPERTY, arns: [arn])
        requestProcessor.sendRequest(request: .describeAssessmentRuns, parameters: parameters.toJSONDictionary())
            .responseJSON(completionHandler: runDetailsFetched)
    }

    func runDetailsFetched(response: DataResponse<Any>) {
        hideIndicator()
        guard let json = response.result.value as? [String: AnyObject],
            let templatesJSON = json["assessmentRuns"] as? [[String: AnyObject]]
            else {
                print("fuck")
                return
        }

        let runs = AssessmentRun.parseJSONToArray(templatesJSON)
        guard !runs.isEmpty else {
            print("empty fuck")
            return
        }

        let run = runs[0]
        self.run = run

        findingCounts = run.findingCounts
        notifications = run.notifications
        rulePackageArns = run.rulesPackageArns
        userAttributesForFindings = run.userAttributesForFindings

        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case RunDetailsTableViewController.DETAILS_SECTION:
            return run != nil ? 10 : 0
        case RunDetailsTableViewController.FINDINGS_SECTION:
            return findingCounts.count
        case RunDetailsTableViewController.NOTIFICATIONS_SECTION:
            return notifications.count
        case RunDetailsTableViewController.RULE_ARNS_SECTION:
            return rulePackageArns.count
        case RunDetailsTableViewController.USER_ATTRIBUTES_SECTION:
            return userAttributesForFindings.count
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == RunDetailsTableViewController.FINDINGS_SECTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath)

            let findingCount = findingCounts[indexPath.row]
            cell.textLabel?.text = "\(findingCount.int)"
            cell.detailTextLabel?.text = findingCount.string

            return cell
        }
        else if indexPath.section == RunDetailsTableViewController.NOTIFICATIONS_SECTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell

            let notification = notifications[indexPath.row]
            cell.notification = notification

            return cell
        }
        else if indexPath.section == RunDetailsTableViewController.RULE_ARNS_SECTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)

            let ruleArn = rulePackageArns[indexPath.row]
            cell.textLabel?.text = ruleArn

            return cell
        }
        else if indexPath.section == RunDetailsTableViewController.USER_ATTRIBUTES_SECTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath)

            let userAttribute = userAttributesForFindings[indexPath.row]
            cell.textLabel?.text = userAttribute.key
            cell.detailTextLabel?.text = userAttribute.value

            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath)

            let row = indexPath.row
            cell.textLabel?.text = title(for: row)
            cell.detailTextLabel?.text = subtitle(for: row)

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case RunDetailsTableViewController.DETAILS_SECTION:
            return "Details"
        case RunDetailsTableViewController.FINDINGS_SECTION:
            return "Finding counts"
        case RunDetailsTableViewController.NOTIFICATIONS_SECTION:
            return "Notifications"
        case RunDetailsTableViewController.RULE_ARNS_SECTION:
            return "Rule package arns"
        case RunDetailsTableViewController.USER_ATTRIBUTES_SECTION:
            return "User attributes for findings"
        default:
            return nil
        }
    }

    func subtitle(for row: Int) -> String? {
        switch row {
        case 0:
            return "Run arn"
        case 1:
            return "Run name"
        case 2:
            return "Template arn"
        case 3:
            return "Completed at"
        case 4:
            return "Created at"
        case 5:
            return "Data collected"
        case 6:
            return "Duration in seconds"
        case 7:
            return "Started at"
        case 8:
            return "State"
        case 9:
            return "State changed at"
        default:
            return nil
        }
    }

    func title(for row: Int) -> String? {
        guard let run = run else {
            return nil
        }

        switch row {
        case 0:
            return run.arn
        case 1:
            return run.name
        case 2:
            return run.assessmentTemplateArn
        case 3:
            return run.completedAt != nil ? MediumDateFormatter.format(run.completedAt!) : "Not completed"
        case 4:
            return MediumDateFormatter.format(run.createdAt)
        case 5:
            return "\(run.dataCollected)"
        case 6:
            return "\(run.durationInSeconds)"
        case 7:
            return run.startedAt != nil ? MediumDateFormatter.format(run.startedAt!) : "Not started"
        case 8:
            return run.state
        case 9:
            return MediumDateFormatter.format(run.stateChangedAt)
        default:
            return nil
        }
    }

}
