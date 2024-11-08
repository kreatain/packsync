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
        let travel = travelPlanList[indexPath.row]
        cell.configure(with: travel)
        return cell
    }
}

