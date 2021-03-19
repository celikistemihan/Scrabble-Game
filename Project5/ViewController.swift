//
//  ViewController.swift
//  Project5
//
//  Created by İstemihan Çelik on 16.03.2021.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        //Project 5: Challenge: 3 , Leftbarbuttonitem addded to refresh
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        
        if let startsWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startsWordsUrl) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        startGame()
    }

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    /// needs to be called from UIBarButtonItem so it has @objc prefix
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
    
        //Important bir closure
        let submitAction = UIAlertAction(title: "Submit", style: .default){
            //action in means that it accepts one parameter in, of type UIAlertAction
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
            
            ac.addAction(submitAction)
            present(ac, animated: true)
        }
    func showErrorMessage(errorTitle: String,errorMessage: String ){
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    func submit(_ answer: String){
        let lowerAnswer = answer.lowercased()
        
      
         
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer){
                    //Insert the new word into our usedWords array at index 0. This means "add it to the start of the array," and means that the newest words will appear at the top of the table view.
                    usedWords.insert(answer.lowercased(), at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    //We insert a new row into the table view.The with parameter lets you specify how the row should be animated in.
                    
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                    //Return sayesinde 3 kondisyon da doğruysa exit oluyor, alerti calistirir aksi halde
                }
                showErrorMessage(errorTitle: "Word not recognized", errorMessage: "You cant just make them up")
                
            } else {
                showErrorMessage(errorTitle: "Word is already used", errorMessage: "Be more original!")

            }
        }
        else {
            guard let title = title else { return }
            showErrorMessage(errorTitle: "Word is not possible", errorMessage: "You cant spell that word from \(title.lowercased())")
           
        }
        
      /*  let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true) */
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {
            return false
        }
        for letter in word {
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position) }
            else {
                return false
            }
        }
        return true
    }
    func isOriginal(word: String) -> Bool{
       return !usedWords.contains(word)
    }
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        //When you’re working with UIKit, SpriteKit, or any other Apple framework, use utf16.count for the character count
        let range = NSRange(location: 0, length: word.utf16.count)
       let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
       
        //Disallow words that are shorter than 3 and starting word , Project:5 Challenge:1
        if word.utf16.count < 3 || title == word{
            return false
        }
        
        if misspelledRange.location == NSNotFound {
            return true
        }
        else {
           return false
        }
    }
}


