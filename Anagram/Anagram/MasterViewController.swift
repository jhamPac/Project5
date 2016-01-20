//
//  MasterViewController.swift
//  Anagram
//
//  Created by jhampac on 1/19/16.
//  Copyright © 2016 jhampac. All rights reserved.
//

import UIKit
import GameplayKit

class MasterViewController: UITableViewController {

    var objects = [String]()
    var allWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let startWordsPath = NSBundle.mainBundle().pathForResource("start", ofType: "txt")
        {
            if let startWords = try? String(contentsOfFile: startWordsPath, usedEncoding: nil)
            {
                allWords = startWords.componentsSeparatedByString("\n")
            }
        }
        
        else
        {
            allWords = ["naan"]
        }
        
        let promptButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptForAnswer")
        navigationItem.rightBarButtonItem = promptButton
        
        startGame()
        
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
        }
    }
    
    // MARK: - VC Methods
    
    func startGame()
    {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allWords) as! [String]
        title = allWords[0]
        objects.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    func promptForAnswer()
    {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) {
            [unowned self, ac] (action: UIAlertAction) -> Void in
            
            let answer = ac.textFields![0]
            self.submitAnswer(answer.text!)
        }
        
        ac.addAction(submitAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func submitAnswer(answer: String)
    {
        let lowerAnswer = answer.lowercaseString
        
        if wordIsPossible(lowerAnswer)
        {
            if wordIsOriginal(lowerAnswer)
            {
                if wordIsReal(lowerAnswer)
                {
                    objects.insert(answer, atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    func wordIsPossible(word: String) -> Bool
    {
        // algorithm to determine if user text is a real word
        var tempWord = title!.lowercaseString
        
        // compare against original word
        for letter in word.characters
        {
            if let pos = tempWord.rangeOfString(String(letter))
            {
                tempWord.removeAtIndex(pos.startIndex)
            }
            
            else
            {
                return false
            }
        }
        
        return true
    }
    
    func wordIsOriginal(word: String) -> Bool {
        return !objects.contains(word)
    }
    
    func wordIsReal(word: String) -> Bool
    {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
}

