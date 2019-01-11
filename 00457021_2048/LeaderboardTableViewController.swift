//
//  LeaderboardTableViewController.swift
//  00457021_2048
//
//  Created by User16 on 2019/1/11.
//  Copyright © 2019 00457021_2048. All rights reserved.
//

import UIKit

class LeaderboardTableViewController: UITableViewController {
    
    var players = [Player]()
    var numTileGame: NumberTileGameViewController? = nil
    
    
    @IBAction func goBackToLoverTable(segue: UIStoryboardSegue) {
        let controller = segue.source as? RankTableViewController
        
        if  let player = controller?.player {
            if let row = tableView.indexPathForSelectedRow?.row {
                players[row] = player
            } else {
                players.insert(player, at: 0)
            }
            
            Player.saveToFile(players: players)
            
            
            tableView.reloadData()
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        sort()
        tableView.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.backgroundColor = UIColor.init(red: 255/255, green: 158/255, blue: 203/255, alpha: 1)
        
        if let players = Player.readPlayersFromFile() {
            self.players = players
        }
        
        sort()
        tableView.reloadData()
    }
    
    func sort()
    {
        
        players.sort{ (lhs: Player, rhs: Player) -> Bool in
            // you can have additional code here
            var double1 = (lhs.score as NSString).doubleValue
            var double2 = (rhs.score as NSString).doubleValue
            return double1 > double2
        }
        print(players)
    }
    
    
    
    
    // MARK: - Table view data source
    
    /////////////////////////////////////
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row % 2 == 1)
        {
            cell.backgroundColor = UIColor.init(red: 255/255, green: 248/255, blue: 220/255, alpha: 1)
        }
        else{
            cell.backgroundColor = UIColor.init(red: 252/255, green: 230/255, blue: 201/255, alpha: 1)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        players.remove(at: indexPath.row)
        Player.saveToFile(players: players)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return players.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as! LeaderboardTableViewCell
        
        let player = players[indexPath.row]
        cell.nameLabel.text = player.name
        cell.scoreLabel.text = String(player.score)
        cell.numberLabel.text = String(indexPath.row+1)
        
        if indexPath.row == 0
        {
            cell.gifImage.loadGif(name: "Trophies-83129")
            cell.fireImage.loadGif(name: "fire")
        }
        
        return cell
    }
    //////////////////////
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let row = tableView.indexPathForSelectedRow?.row {
            let player = players[row]
            let controller = segue.destination as? RankTableViewController
            controller?.player =  player
        }
        
    }
    
    
}
