//
//  TravelPlanTableViewCellManager.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

import UIKit

extension TravelViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return travelPlanList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewTravelPlansID, for: indexPath) as! TravelPlanTableViewCell
        cell.labelTravelTitle.text = travelPlanList[indexPath.row].travelTitle
//        cell.labelParticipants.text = travelPlanList[indexPath.row].email
//        cell.labelPhone.text = "\(travelPlanList[indexPath.row].phone)"
        return cell
    }
}

