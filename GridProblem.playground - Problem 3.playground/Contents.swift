//: Playground - noun: a place where people can play

import UIKit

class Grid {
    
    //You can run the program by pressing play at the bottom, top left to the console below.
    
    var area:Int!
    var grid:[Int] = []
    
    /* So the boolean below determines whether or not chain values should be repeated or not.
     Your rules state that "Chains that use the exact same cells as a previous chain are considered repeats and should not be counted" but they do not say anything such as
     "Chains that use the exact same values as a previous chain are considered repeats and should not be counted".
     So, I wasn't sure where to go, as some of the randomized grids provide chains that are repeated through different cells. I wrote code for both (doesn't change much), but nonetheless, the option is there for you to determine as it was not specified.
     I default set to FALSE as I would imagine you would not want repeats, but, by all means, it works both ways.
     */
    var repeatedFormulas:Bool = false
    
    
    //Incomplete Cells, Incomplete Sets, Complete Cells, Complete Sets, Complete Cells Already, Complete Sets Already
    var sets:[[[Int]]] = [[], [], [], [], [], []]
    
    init() {
        
        //I use grid[0] to indicate if it's 3x3, 4x4, 5x5
        grid.append(3)
        
        //Calculate the area
        area = grid[0]*grid[0]
        
        //Get random numbers
        for _ in 0 ..< area {
            let x = arc4random_uniform(10)
            grid.append(Int(x))
        }
        
        //Shows grid in console, so it is nice and neat
        for i in 1 ..< grid.count {
            if((i-1)%(grid[0]) == 0 && i > 1) {
                print()
            }
            print("\(grid[i]) ", terminator: "")
        }
        print("\n")
        
    }
    
    //This is where I find all of the different ways to find the area
    func getFormulas() {
        
        //This program runs through the grid, and as you get to a new grid location we run through the incomplete sets and cells and add that item to the chains until chain > area or chain == area.
        for realItemIndex in 2 ..< grid.count {
            
            let rowNumber = (realItemIndex-1)/grid[0]
            
            //Items declared to reduce space used as we search through the grid.
            var clearingRows:Bool = false
            
            //The neighbors, so we can compare each chain we already used and the currentindex we are at.
            let neighbors = findNeighbors(realItemIndex-1)
            
            //CLEARING COMMENT
            //Each time we get to a new row, as long as it is the 2nd row (starting at 0), we can remove any chains that start and end on 2 rows behind it. So, if we are on a 3x3, and we are on the bottom row, when we get to first item on the bottom row, as we search through the incompletesets, any chain that starts and ends on the first row, will never be used again, and can be removed, so we don't waste time on it.
            if((realItemIndex-1)%grid[0] == 0) {
                if(rowNumber >= 2) {
                    clearingRows = true
                }
            }
            else {
                clearingRows = false
            }
            
            //This runs through all the incomplete sets then adds the currentItem to any chain where the last index of the first index is a neighbor to the currentIndex. This makes sure we grab all chains.
            //Then add the chain to the sets (let the func addSet do that work)
            var removedCount:Int = 0
            for i in 0 ..< sets[1].count {
                //Get the incomplete sets
                var set = sets[1][i-removedCount]
                
                //Get incomplete cells
                var cell = sets[0][i-removedCount]
                
                //Set[0] is the current addition of all items in the chain
                //We make sure that if we add the currentItem it is <= area, and make sure the cell is not already used.
                if(set[0] + grid[realItemIndex] <= area && !cell.contains(realItemIndex)) {
                    
                    //Add the area, because we are making a new chain, since we are finding ALL possibilies
                    set[0] += grid[realItemIndex]
                    
                    //Add the item to the front or end depending on where the neighbor is at and then add the new chain to the list of complete sets or incomplete sets
                    var first:Bool = false
                    if(neighbors.contains(cell[0])) {
                        set.insert(grid[realItemIndex], at: 1)
                        cell.insert(realItemIndex, at: 0)
                        addToSets(set[0] == area, itemsToAdd: set, indicesToAdd: cell)
                        first = true
                    }
                    if(neighbors.contains(cell[cell.count-1])) {
                        
                        //This allows us to have both cases of where it adds the item to the front and back as it is possible we will miss a chain is we don't have all cases possible.
                        if(first) {
                            set.remove(at: 1)
                            cell.remove(at: 0)
                        }
                        set.append(grid[realItemIndex])
                        cell.append(realItemIndex)
                        addToSets(set[0] == area, itemsToAdd: set, indicesToAdd: cell)
                    }
                }
                
                //This is where we clear the incomplete chains that can't be used anymore. As described in the above comment labeled CLEARING COMMENT
                if(clearingRows) {
                    if(cell[0] <= (rowNumber-1)*grid[0] && cell[cell.count-1] <= (rowNumber-1)*grid[0]) {
                        sets[1].remove(at: i-removedCount)
                        sets[0].remove(at: i-removedCount)
                        removedCount += 1
                    }
                }
            }
            
            //If the currentItem is 0, then we can add it to completeSets as well as the above incomplete chains. Because, a chain that is already complete can still use a 0.
            if(grid[realItemIndex] == 0) {
                for index in 0 ..< sets[3].count {
                    var cell = sets[2][index]
                    var set = sets[3][index]
                    if(neighbors.contains(cell[0])) {
                        set.insert(0, at: 1)
                        cell.insert(realItemIndex, at: 0)
                        addToSets(true, itemsToAdd: set, indicesToAdd: cell)
                    }
                    else if(neighbors.contains(cell[cell.count-1])) {
                        set.append(0)
                        cell.append(realItemIndex)
                        addToSets(true, itemsToAdd: set, indicesToAdd: cell)
                    }
                }
                for index in 0 ..< sets[5].count {
                    var cell = sets[4][index]
                    var set = sets[5][index]
                    if(neighbors.contains(cell[0])) {
                        set.insert(0, at: 1)
                        cell.insert(realItemIndex, at: 0)
                        addToSets(true, itemsToAdd: set, indicesToAdd: cell)
                    }
                    else if(neighbors.contains(cell[cell.count-1])) {
                        set.append(0)
                        cell.append(realItemIndex)
                        addToSets(true, itemsToAdd: set, indicesToAdd: cell)
                    }
                }
            }
            
            //After we search through the incomplete Sets or complete sets, then we go through each of the neighbors, and add a new chain to start for each neighbor. This never exceeds 4 as the neighbor.count is never greater than 4.
            for neighbor in neighbors {
                let addition = grid[realItemIndex]+grid[neighbor]
                if(addition <= area) {
                    addToSets((addition == area), itemsToAdd: [addition, grid[neighbor], grid[realItemIndex]], indicesToAdd: [neighbor, realItemIndex])
                }
            }
            
            //Enumerated to get the index, so I could use the index inside incompleteCells and incompleteSets. Also, filterered because we only want chains that are going to connect to the current index we are at. So, we only want chains that have endpoints with neighbors on either end of the chains
            let indexNEle = sets[0].enumerated().filter({
                return $0.element[0] == realItemIndex || $0.element[$0.element.count-1] == realItemIndex
            })
            //If its less than 1, then we don't need to do all this
            if(indexNEle.count > 1) {
                
                //This little bit of code here, in a nutshell, cycles through the chains that have endpoints with neighbors. Then we compare, and see if we can combine any chains using our current index as a mediator. Let's say our current item is 0, and one chain to the left is 1, 2, and another to the right is 5, 1. Then our 0, could combine the 2 chains and become 1, 2, 0, 5, 1. (Assuming 3x3).
                for i in 0 ..< indexNEle.count {
                    let setA = Set(indexNEle[i].element)
                    var firstSet = sets[1][indexNEle[i].offset]
                    if(firstSet[0] == 0) {
                        let completeIndex = sets[2].enumerated().filter({
                            return $0.element[0] == realItemIndex || $0.element[$0.element.count-1] == realItemIndex
                        })
                        for k in 0 ..< completeIndex.count {
                            let setC = Set(completeIndex[k].element)
                            if(setA.intersection(setC).count == 1) {
                                let item = firstSet[0]
                                firstSet.remove(at: 0);
                                let firstIndexItem = sets[3][completeIndex[k].offset][0]
                                sets[3][completeIndex[k].offset].remove(at: 0)
                                let index = indexNEle[i].element.index(of: realItemIndex); firstSet.remove(at: index!)
                                addToSets(true, itemsToAdd: [9] + (firstSet + sets[3][completeIndex[k].offset]), indicesToAdd: Array(setA.union(setC)))
                                firstSet.insert(item, at: 0)
                                firstSet.insert(grid[realItemIndex], at: index!)
                                (sets[3][completeIndex[k].offset]).insert(firstIndexItem, at: 0)
                            }
                        }
                    }
                    for j in i+1 ..< indexNEle.count {
                        let setB = Set(indexNEle[j].element)
                        if((setA.intersection(setB)).count == 1) {
                            var secondSet = sets[1][indexNEle[j].offset]
                            if(firstSet[0] + secondSet[0] - grid[realItemIndex] == area) {
                                let item = firstSet[0]
                                firstSet.remove(at: 0); secondSet.remove(at: 0)
                                let index = indexNEle[i].element.index(of: realItemIndex); firstSet.remove(at: index!)
                                addToSets(true, itemsToAdd: [9] + (firstSet+secondSet), indicesToAdd: Array(setA.union(setB)))
                                firstSet.insert(grid[realItemIndex], at: index!)
                                firstSet.insert(item, at: 0)
                            }
                        }
                    }
                }
            }
        }
        
        //This just prints out the items. It prints out the items on the left, and thier indexes to the right of them. The numbers on the left array should add to area, while the cell array on the right should be the chain.
        //The cell array on the right prints out where the assumption is grid cells are [1, 2, 3, 4, 5, 6, 7, 8, 9] for a 3x3.
        if(sets[2].count > 0) {
            for items in 0 ..< sets[2].count {
                var set = sets[3][items]
                set.remove(at: 0)
                var string = ""
                for items in set {
                    string += "\(items) + "
                }
                string = string.substring(to: string.index(string.endIndex, offsetBy: -2)) + "= \(area!)"
                
                //I give ample space so if it needed to use the whole grid, it would print out nicely, no matter the number of cells in the chain. I give enough room for a chain that contains all cells -- easily changable.
                print(String(format: "%-\((area*4) + 1)s Cells used: \(sets[2][items]))", (string as NSString).utf8String!))
            }
        }
        else {
            print("No chains are equal to the area of the grid")
        }
    }
    
    //This function adds the different items and cells, to keep up with and compare, in either the complete sets, incomplete sets, complete cells or incomplete cells array
    func addToSets(_ equalToArea:Bool, itemsToAdd:[Int], indicesToAdd:[Int]) {
        
        //This determines which set to put it in, the complete sets or incomplete sets
        if(equalToArea) {
            var formulaChoice:[[Int]]
            var item:[Int]
            
            //This section determines how we want to find the formulas in our grid. Do we want to find ALL the formulas where the cells are different (could see a repeat of formulas) or do we want to see only that formula once. Use [3, 3, 3, 3, 3, 3, 3, 3, 3, 3] as an example where grid[0] = width of grid. There are MANY ways in this grid to find 3+3+3 = 9, but do we really want to see 3+3+3 = 9 repetitively? If you don't, then set 'repeatedFormulas' as false at the top, if you do want the formula to repeat, set repeatFormulas = true
            if(repeatedFormulas) {
                formulaChoice = sets[2]
                item = indicesToAdd
            }
            else {
                formulaChoice = sets[3]
                item = itemsToAdd
            }
            
            //This complicated line makes sure, depending whether we are checking complete sets or complete cells, depending on repeatedForumlas, we see if the cell or set is already inside the complete array. If it is NOT then we add it; we have to sort the array first, that is the sorting, as arrays are order dependent collections sets.
            if(!formulaChoice.contains(where: {  $0.sorted(by: { $0 < $1 }) == item.sorted(by: { $0 < $1 }) })) {
                
                //Makes sure the size of the chain added is at least width - 1
                if(itemsToAdd.count-1 >= grid[0]-1) {
                    sets[3].append(itemsToAdd)
                    sets[2].append(indicesToAdd)
                }
            }
            else {
                if(itemsToAdd.count-1 >= grid[0]-1) {
                    sets[4].append(indicesToAdd)
                    sets[5].append(itemsToAdd)
                }
            }
        }
        else {
            //Add the item to incomplete cells and sets, no need to check if it is already there, only need to make sure the final complete sets and cells are checked.
            sets[1].append(itemsToAdd)
            sets[0].append(indicesToAdd)
        }
    }
    
    //This function takes in the index of the current item in the grid, and returns it's neighbor - only the 4 to the left - it returns the actual number  in the grid, not the location itself.
    //Neighbors are only the numbers behind the current cell. More of a DP thought process instead of brute force search, so we only need to do some of the work, in hope of reducing time needed to complete the program.
    func findNeighbors(_ currentItemIndex:Int) -> [Int] {
        var array:[Int]
        if(currentItemIndex < grid[0]) {
            array = [-1]
        }
        else if(currentItemIndex%grid[0] == 0) {
            array = [-2, -3]
        }
        else if(currentItemIndex%grid[0] == grid[0]-1) {
            array = [-1, -3, -4]
        }
        else {
            array = [-1, -2, -3, -4]
        }
        array = array.map({ $0 + (currentItemIndex+1) })
        return array
    }
}

//This is where we run the program. I was checking the different amount of run time for 3x3, 4x4, and 5x5. More info inside README.txt
let start = NSDate()

let grid = Grid()
grid.getFormulas()

let end = NSDate()
let time = end.timeIntervalSince(start as Date)
print("Exec time: \(time)")

