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
        VStack {
            Text(currentTurn == .black ? "黒のターン" : "白のターン")
                .font(.headline)
                .padding()
            ForEach(0..<8, id: \.self) { row in
                HStack {
                    ForEach(0..<8, id: \.self) { column in
                        CellView(cellState: gameBoard.cells[row][column])
                            .frame(width: 40.0, height: 40)
                            .onTapGesture {
                                // showAlertをonTapGesture内で使用
                                if gameBoard.cells[row][column] != .green {
                                    alertMessage = "ここには置けません。"
                                    showAlert = true
                                } else if gameBoard.canPlacePiece(at: row, column: column, for: currentTurn) {
                                    gameBoard.cells[row][column] = currentTurn
                                    currentTurn = currentTurn == .black ? .white : .black
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
            Alert(title: Text("警告"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
    
    func canPlacePiece(at row: Int, column: Int, for player: CellState) -> Bool {
        // すでにコマが置かれている場所には置けない
        if cells[row][column] != .green {
            return false
        }
        
        let opponent: CellState = player == .black ? .white : .black
        let directions = [(0,1),(1,0),(0,-1),(-1,0)]
        for (dx,dy) in directions{
            let newRow = row + dx
            let newColumn = column + dy
            
            if newRow >= 0 && newRow < 8 && newColumn >= 0 && newColumn < 8 && cells[newRow][newColumn] == opponent {
                return true
            }
        }
        return false
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
