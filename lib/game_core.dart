library game_core;

class Player{
  int y;
  int direction;

  Player(){
    this.y = 0;
    this.direction = 0;
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
    ballXVel = -1;
    ballYVel = 1;
  }

  //should be run 40hz, or 25ms
  void tick(){
    p1.y += p1.direction * 5;
    p2.y += p2.direction * 5;

    ballX += ballXVel;
    ballY += ballYVel;
    
    if(ballX <= 20){
      if(p1.y < ballY && p1.y + 10 > ballY){
        ballX = 20;
        ballXVel = 1;
      } else {
        //player 1 lose!
      }
    } else if(ballX >= 460){
      if(p2.y < ballY && p2.y + 10 > ballY){
        ballX = 460;
        ballXVel = -1;
      } else {
        //player 2 lose!
      }
    }
    
    if(ballY < 0){
      ballYVel *= -1;
      ballY = 0;
    } else if(ballY > 310){
      ballYVel *= -1;
      ballY = 310;
    }
    
  }
}
