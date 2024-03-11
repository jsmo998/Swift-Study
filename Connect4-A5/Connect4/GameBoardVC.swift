//
//  GameBoardVC.swift
//  Connect4
//
//  Created by Judith Smolenski on 11/12/2023.
//

import UIKit
import CoreData
import Alpha0C4

class GameBoardVC: UIViewController, UIDynamicAnimatorDelegate {
    // variables
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet var tap: UITapGestureRecognizer!
    
    @IBOutlet var gameView: UIView!
    
    var board : [[String]]? = nil
    var boardView: BoardView? = nil
    private var discBehavior = DiscBehavior()
    var reset: Bool = false
    var playable: Bool = false
    var discViewsDictionary: [Int: DiscView] = [:]
    var discByTime: [DiscView] = []
    private var botColor: GameSession.DiscColor = .red
    private var isBotFirst: Bool = false
    private var hasBar: Bool = false
    
    // game session
    let gameSession = GameSession()
    
    private var gravity = UIGravityBehavior()
    private var collider = UICollisionBehavior()
    
    var botsTurn: Bool = false {
        didSet{
            if(botsTurn) {
                print("bots turn")
            } else {
                print("players turn")
            }
        }
    }
    // animator
    private lazy var animator: UIDynamicAnimator? = {
        guard gameView != nil else { return nil }
        let animator = UIDynamicAnimator(referenceView: gameView)
        animator.addBehavior(self.discBehavior)
        return animator
    }()
    
    private lazy var discSize = { () -> CGSize in
        return CGSize.init(width: self.radius() * 2, height: self.radius()*2 )
    }
    private lazy var cellWidth = { () -> CGFloat in
        return self.gameView.frame.width / CGFloat(self.gameSession.boardLayout.columns)
    }
    private lazy var cellHeight = { () -> CGFloat in
        return self.discSize().height
    }
    private lazy var radius = { () -> CGFloat in
        return self.cellWidth() / 2 * 0.956
    }
    // MARK: - startup dialog
    private func showGameStartDialog() {
        let alert = UIAlertController(title: "Start the Game", message: "Select who starts the game, you or the bot.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Me", style: UIAlertAction.Style.default, handler: { _ in
            self.botsTurn = false
            self.initGame()
            self.isBotFirst = false
        }))
        alert.addAction(UIAlertAction(title: "Bot", style: UIAlertAction.Style.default, handler: { (_: UIAlertAction!) in
            self.botsTurn = true
            self.initGame()
            self.isBotFirst = true
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - VC Lifecycle
    override func viewDidLayoutSubviews() {
        boardView!.frame = boardView!.bounds
        boardView!.position = gameView.center
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(!playable) {
            showGameStartDialog()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe))
        right.direction = .right
        self.view.addGestureRecognizer(right)
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe))
        left.direction = .left
        self.view.addGestureRecognizer(left)
        
        newGameSession()
    }
    // MARK: - New Game Session
    private func newGameSession() {
        animator?.delegate = self
        self.title = "Connect4"
        setupBoard()
        
        let initialMoves = [(Int, Int)]()
        self.gameSession.startGame(delegate: self, botPlays: botColor, first: isBotFirst, initialPositions: initialMoves)
        if (isBotFirst) {
            gameSession.dropDisc()
        }
    }
    // set up board and borders
    private func setupBoard() {
        boardView = BoardView(gameView, discRadius: radius())
        setupBorders(board: boardView!)
        gameView.layer.addSublayer(boardView!)
    }
    private func setupBorders(board: BoardView) {
        for wall in board.getWalls(){
            addBarrier(wall, "wall")
        }
        let bottomLine = board.getBottom()
        addBarrier(bottomLine, "bottom")
        hasBar = true
    }
    // collision barriers
    private func addBarrier(_ path: UIBezierPath, _ name: String) {
        discBehavior.addBarrier(path, named: name)
    }
    
    // MARK: - Gestures - Tap and Swipe
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        let x = sender.location(in: self.gameView).x
        let column = Int(x / self.cellWidth())
        gameSession.dropDisc(atColumn: column+1)
        dropDisc(column)
        print("dropped disc at column: ", column)
        
    }
    
    // handle token at pressed location
    private func dropDisc(_ column: Int) {
        var frame = CGRect()
        frame.origin = CGPoint.zero
        frame.size = self.discSize()
        frame.origin.x = CGFloat(column) * self.cellWidth()
        
        let discView = DiscView(frame: frame, isBot: botsTurn, num: self.discViewsDictionary.count, colum: column)
        self.discBehavior.addDisc(discView)
    }
    
    @objc private func swipe(_ sender: Any) {
        print("swipe func")
        if discByTime.count > 0 {
            resetGameState() // Reset the game when discs are present
        } else {
            showGameStartDialog()
        }
    }
    
    private func resetGameState() {
        playable = true
        reset = false
        discViewsDictionary = [:]
        discByTime = []
        gameLabel.text = "New Game"
        tap.isEnabled = true
        // Clear any existing disc views from the game view
        for discView in gameView.subviews {
            if discView is DiscView {
                discView.removeFromSuperview()
            }
        }
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        print("dynamic animator did pause func")
        if reset {
            resetGameState()
        }
    }
    
    private func initGame() {
        playable = true
        board = Array(repeating: Array(repeating: " ", count: gameSession.boardLayout.columns), count: gameSession.boardLayout.rows)
    }
    
}
 
extension GameBoardVC: GameSessionDelegate {
    func stateChanged(_ gameSession: Alpha0C4.GameSession, state: SessionState, textLog: String) {
        // Handle state transition
        switch state
        {
            // Inital state
        case .cleared:
            gameLabel.text = "New Game"
            // Player evaluating position to play
        case .busy(_):
            // Disable tap while bot is thinking
            tap.isEnabled = false
            print("busy")
            
            // Waiting for play action
        case .idle(let color):
            let isUserTurn = (color != botColor)
            botsTurn = false
            // Enable tap gesture for user
            tap.isEnabled = isUserTurn
            if !isUserTurn {
                // Bot play
                botsTurn = true
                Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await MainActor.run {
                        gameSession.dropDisc()
                    }
                }
            }
            
            // End of game, update UI with game result
        case .ended(let outcome):
            // Disable tap
            tap.isEnabled = false
            // Display game result
            var gameResult: String
            switch outcome {
            case botColor:
                gameResult = "Bot (\(botColor)) wins!"
            case !botColor:
                gameResult = "User (\(!botColor)) wins!"
            default:
                gameResult = "Draw!"
            }
            gameLabel.text! = gameResult
            
        @unknown default:
            break
        }
    }
    
    func didDropDisc(_ gameSession: Alpha0C4.GameSession, color: DiscColor, at location: (row: Int, column: Int), index: Int, textLog: String) {
        print("\(color) drops at \(location)")
        if (color == .red) {
            let column = location.column - 1
            dropDisc(column)
        }
    }
    
    func didEnd(_ gameSession: Alpha0C4.GameSession, color: DiscColor?, winningActions: [(row: Int, column: Int)]) {
        let moc = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        _ = CoreDataSession.save(botPlays: botColor, first: isBotFirst, layout: gameSession.boardLayout, positions: gameSession.playerPositions, winningPositions: gameSession.winningPositions, in: moc)

        // Display winning disc positions
        print("Winning actions: " + winningActions.map({"\($0)"}).joined(separator: " "))
    }
}
