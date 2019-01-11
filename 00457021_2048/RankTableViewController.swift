//
//  RankTableViewController.swift
//  00457021_2048
//
//  Created by User16 on 2019/1/11.
//  Copyright © 2019 00457021_2048. All rights reserved.
//

import UIKit

class RankTableViewController: UITableViewController{
    
    var scoreView: ScoreViewProtocol?
    var player: Player?
    var score : Int = 0
    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let player = player {
            nameTextField.text = player.name
            scoreLabel.text = player.score
        }
    }
    
    
    func scoreChanged(to score: Int) {}
    func getScore() -> Int{
        return score
    }
    
    
    // MARK: - Table view data source
    
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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
    /////////////////////////
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if nameTextField.text?.count == 0 {
            let alertController = UIAlertController(title: "請輸入名字：", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        performSegue(withIdentifier: "goBackToLoverTableWithSegue", sender: nil)
        
    }
    
    //////////////////
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if player == nil {
            player = Player(name: nameTextField.text!, score:scoreLabel.text! )
        } else {
            player?.name = nameTextField.text!
            player?.score = scoreLabel.text!
        }
    }
}

// 上個畫面傳分數要抓的function
extension RankTableViewController: FetchScoreDelegate {
    func fetchScore(_ score: Int) {
        scoreLabel.text = String(score)
    }
}
