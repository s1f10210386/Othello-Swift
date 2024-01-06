import SwiftUI

enum CellState: Int {
    case green = 0
    case black = 1
    case white = 2
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
}


struct ContentView: View {
    @State private var gameBoard = GameBoard()
    @State private var currentTurn = CellState.black
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            ForEach(0..<8, id: \.self) { row in
                HStack {
                    ForEach(0..<8, id: \.self) { column in
                        CellView(cellState: gameBoard.cells[row][column])
                            .frame(width: 40.0, height: 40)
                        
                            .onTapGesture {
                                if gameBoard.cells[row][column] == .green{
                                    gameBoard.cells[row][column] = currentTurn
                                    
                                    
                                    currentTurn = currentTurn == .black ? .white : .black
                                }
                            }
                    }
                }
            }
        }
        .padding()
        .background(Color.green)
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
