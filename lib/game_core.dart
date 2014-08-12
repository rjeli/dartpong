library game_core;

class Player{
  int y;
  int direction;

  Player(int y, int direction){
    this.y = y;
    this.direction = direction;
  }
}

class GameInstance{
  Player p1, p2;
  int ballX, ballY, ballXVel, ballYVel;
  
  GameInstance(Player p1, Player p2){
    this.p1 = p1;
    this.p2 = p2;
    
    ballX = 240;
    ballY = 160;
    ballXVel = ballYVel = 1;
  }

  //should be run 40hz, or 25ms
  void tick(){
    p1.y += p1.direction * 5;
    p2.y += p2.direction * 5;

    ballX += ballXVel;
    ballY += ballYVel;
    
    if(ballX < 20){
      if((p1.y - ballY).abs() < 20){
        ballX = 20;
        ballXVel *= -1;
      } else {
        //player 1 lose!
      }
    } else if(ballX > 460){
      if((p2.y - ballY).abs() < 20){
        ballX = 460;
        ballXVel *= -1;
      } else {
        //player 2 lose!
      }
    }
  }
}
