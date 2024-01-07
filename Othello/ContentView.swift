import SwiftUI

enum CellState: Int {
    case green = 0
    case black = 1
    case white = 2
}



struct ContentView: View {
    @State private var gameBoard = GameBoard()
    @State private var currentTurn = CellState.black
    @State private var showAlert = false // showAlertをContentViewの中で定義
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 1.0) {
            Text(currentTurn == .black ? "黒のターン" : "白のターン")
                .font(.headline)
                .padding()
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 1.0) {
                    ForEach(0..<8, id: \.self) { column in
                        CellView(cellState: gameBoard.cells[row][column])
                            .frame(width: 40.0, height: 40)
                            .onTapGesture {
                                if gameBoard.canPlacePiece(at: row, column: column, for: currentTurn) {
                                    gameBoard.cells[row][column] = currentTurn
                                    //ひっくり返す
                                    gameBoard.flipVerticalPieces(fromRow: row, fromColumn: column, for: currentTurn)
                                    gameBoard.flipHorizontalPieces(fromRow: row, fromColumn: column, for: currentTurn)
                                    gameBoard.flipDiagonalPieces(fromRow: row, fromColumn: column, for: currentTurn)
                                    //ゲーム終了かチェック
                                    if gameBoard.isFull() {
                                        let result = gameBoard.countPieces()
                                        alertMessage = "ゲーム終了！ 黒: \(result.black), 白: \(result.white)"
                                        showAlert = true
                                        gameBoard = .init()
                                    } else {
                                        //ターン交代
                                        currentTurn = currentTurn == .black ? .white : .black
                                        // 次のプレイヤーが置ける場所があるかチェック
                                        if !gameBoard.canPlayerPlacePiece(player: currentTurn) {
                                            currentTurn = currentTurn == .black ? .white : .black // ターンをパス
                                            alertMessage = "\(currentTurn == .black ? "黒" : "白")のプレイヤーは置ける場所がありません。ターンをパスします。"
                                            showAlert = true
                                        }
                                    }
                                } else if !gameBoard.canPlacePiece(at: row, column: column, for: currentTurn) {
                                    let turnMessage = currentTurn == .black ? "黒" : "白"
                                    alertMessage = "\(turnMessage)のコマを置ける場所ではありません。"
                                    showAlert = true
                                    
                                }
                            }
                    }
                }
            }
        }
        .padding()
        .background(Color.green)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("通知"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct GameBoard {
    var cells: [[CellState]] = Array(repeating: Array(repeating: .green, count: 8), count: 8)
    
    init() {
        // ゲーム開始時の配置
        cells[3][3] = .white
        cells[4][4] = .white
        cells[3][4] = .black
        cells[4][3] = .black
        
    }
    
    //ここでコマのおける位置指定できる
    func canPlacePiece(at row: Int, column: Int, for player: CellState) -> Bool {
        
        let opponent: CellState = player == .black ? .white : .black
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
        
        //これがないと既にコマがある場所にも置けちゃう
        if cells[row][column] != .green {
            return false
        }
        
        for (dx, dy) in directions {
            var r = row + dx
            var c = column + dy
            
            // 最初に相手のコマがあることを確認
            if r >= 0 && r < 8 && c >= 0 && c < 8 && cells[r][c] == opponent {
                // さらにその方向に進んでって、自分のコマがあるか探索する
                r += dx
                c += dy
                while r >= 0 && r < 8 && c >= 0 && c < 8 {
                    if cells[r][c] == .green {
                        break
                    }
                    if cells[r][c] == player {
                        
                        return true
                    }
                    r += dx
                    c += dy
                }
            }
        }
        
        return false
    }
    
    mutating func flipVerticalPieces(fromRow row: Int, fromColumn column: Int, for player: CellState) {
        let opponent: CellState = player == .black ? .white : .black
        
        // 上方向の探索とひっくり返し
        var flipPositions: [(Int, Int)] = []
        var r = row - 1
        while r >= 0 && cells[r][column] == opponent {
            flipPositions.append((r, column))
            r -= 1
        }
        if r >= 0 && cells[r][column] == player {
            for pos in flipPositions {
                cells[pos.0][pos.1] = player
            }
        }
        
        // 下方向の探索とひっくり返し
        flipPositions = []
        r = row + 1
        while r < 8 && cells[r][column] == opponent {
            flipPositions.append((r, column))
            r += 1
        }
        if r < 8 && cells[r][column] == player {
            for pos in flipPositions {
                cells[pos.0][pos.1] = player
            }
        }
    }
    
    mutating func flipHorizontalPieces(fromRow row: Int, fromColumn column: Int, for player: CellState) {
        let opponent: CellState = player == .black ? .white : .black
        
        // 左方向の探索とひっくり返し
        var flipPositions: [(Int, Int)] = []
        var c = column - 1
        while c >= 0 && cells[row][c] == opponent {
            flipPositions.append((row, c))
            c -= 1
        }
        if c >= 0 && cells[row][c] == player {
            for pos in flipPositions {
                cells[pos.0][pos.1] = player
            }
        }
        
        // 右方向の探索とひっくり返し
        flipPositions = []
        c = column + 1
        while c < 8 && cells[row][c] == opponent {
            flipPositions.append((row, c))
            c += 1
        }
        if c < 8 && cells[row][c] == player {
            for pos in flipPositions {
                cells[pos.0][pos.1] = player
            }
        }
    }
    mutating func flipDiagonalPieces(fromRow row: Int, fromColumn column: Int, for player: CellState) {
        let opponent: CellState = player == .black ? .white : .black
        let directions = [(1, 1), (1, -1), (-1, 1), (-1, -1)] // 斜め方向
        
        for (dx, dy) in directions {
            var flipPositions: [(Int, Int)] = []
            var r = row + dx
            var c = column + dy
            
            while r >= 0 && r < 8 && c >= 0 && c < 8 && cells[r][c] == opponent {
                flipPositions.append((r, c))
                r += dx
                c += dy
            }
            
            if r >= 0 && r < 8 && c >= 0 && c < 8 && cells[r][c] == player {
                for pos in flipPositions {
                    cells[pos.0][pos.1] = player
                }
            }
        }
    }
    
    //置ける場所がない場合パスする
    //全部探索して当てはまるかを調べる、Canplace関数を全ての空きコマに対して適応
    func canPlayerPlacePiece(player: CellState) -> Bool {
        var putPositions: [(Int, Int)] = []
        for row in 0..<8 {
            for column in 0..<8 {
                if canPlacePiece(at: row, column: column, for: player) {
                    putPositions.append((row,column))
                }
            }
        }
        print(putPositions)
        return !putPositions.isEmpty
    }
    //全部のコマ探索して、黒白数える。
    func countPieces() -> (black: Int, white: Int) {
        var blackCount = 0
        var whiteCount = 0
        
        for row in cells {
            for cell in row {
                if cell == .black {
                    blackCount += 1
                } else if cell == .white {
                    whiteCount += 1
                }
            }
        }
        
        return (blackCount, whiteCount)
    }
    
    //合計が64(全部埋まってる)なら終了
    func isFull() -> Bool {
        return countPieces().black + countPieces().white == 64
    }
}


struct CellView: View {
    var cellState: CellState
    
    var body: some View {
        
        
        Circle()
            .foregroundColor(cellStateColor(cellState))
            .border(Color.black, width: 1) // セルの境界線を黒に設定
        
    }
    
    func cellStateColor(_ state: CellState) -> Color {
        switch state {
        case .green:
            return .green // 空白のセルは透明に設定
        case .black:
            return .black // 黒のセル
        case .white:
            return .white // 白のセル
        }
    }
}


#Preview {
    ContentView()
}
