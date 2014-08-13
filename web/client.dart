import 'dart:html' hide Player;
import 'dart:typed_data';
import 'dart:async';

import 'package:play_pixi/pixi.dart' as PIXI;

import 'package:dartpong/game_core.dart';
import 'package:dartpong/packets.dart' as Packet;

void main(){
  var ren = PIXI.autoDetectRenderer(480, 320);
  WebSocket socket;
  Keyboard kb = new Keyboard();
  State currentState;

  document.body.append(ren.view);
  ren.view.style.display = 'block';
  ren.view.style.margin = 'auto';

  window.onKeyDown.listen((e) => kb.pressKey(e.keyCode));
  window.onKeyUp.listen((e) => kb.releaseKey(e.keyCode));

  animate(num delta){
    PIXI.requestAnimFrame(animate);
    currentState.update();
    ren.render(currentState.stage);
  }

  void enterState(State newState){
    if(currentState != null){
      currentState.destroy();
    }
    currentState = newState;
    currentState.init(socket, kb, enterState);
  }

  enterState(new ConnectingState());
  PIXI.requestAnimFrame(animate);
}

class State{
  WebSocket socket;
  PIXI.Stage stage;
  Keyboard kb;
  Function enterState;
  List<int> packet;

  void init(WebSocket socket, Keyboard kb, Function enterState){
    this.socket = socket;
    this.kb = kb;
    this.enterState = enterState;
  }
  void destroy(){}
  void update(){}
  void onMessage(data){}
  void addPacket(List<int> bytes){

  }
}

class ConnectingState extends State{

  PIXI.Text displayedText;
  bool connected;

  void init(WebSocket socket, Keyboard kb, Function enterState){
    super.init(socket, kb, enterState);

    connected = false;

    stage = new PIXI.Stage(0x660099);
    displayedText = new PIXI.Text('connecting...', new PIXI.TextStyle()..font = '15px Snippet');
    displayedText.position.x = 10;
    displayedText.position.y = 10;
    stage.addChild(displayedText);

    socket = new WebSocket('ws://${Uri.base.host}:${Uri.base.port}/ws');

    socket.onOpen.first.then((_){
      print('connected to websocket server!! from, connectingstate');
      displayedText.setText('connected. press j to enter menu');
      connected = true;

      Uint16List samplePacket = new Uint16List(3);
      socket.sendTypedData(samplePacket);
    });
  }
  void update(){
    if(kb.isPressed(KeyCode.J) && connected){
      enterState(new MenuState());
    }
  }
}

class MenuState extends State{
  PIXI.Text menuText;

  void init(WebSocket socket, Keyboard kb, Function enterState){
    super.init(socket, kb, enterState);

    stage = new PIXI.Stage(0x00CC77);

    menuText = new PIXI.Text("press q to join queue", new PIXI.TextStyle()..font = '15px Snippet');
    menuText.position.x = 10;
    menuText.position.y = 10;
    stage.addChild(menuText);
  }
  void update(){
    if(kb.isPressed(KeyCode.Q)){
      enterState(new GameState());
    }
  }
}

class QueueState extends State{
  PIXI.Text queueText;

  void init(WebSocket socket, Keyboard kb, Function enterState){
    super.init(socket, kb, enterState);

    stage = new PIXI.Stage(0x00CC77);

    queueText = new PIXI.Text("finding an opponent...", new PIXI.TextStyle()..font = '15px Snippet');
    queueText.position.x = 10;
    queueText.position.y = 10;
    stage.addChild(queueText);
  }
}

class GameState extends State{
  PIXI.Graphics graphics;
  GameInstance gameInstance;
  bool running;
  Player me, other;

  void init(WebSocket socket, Keyboard kb, Function enterState){
    super.init(socket, kb, enterState);

    me = new Player();
    other = new Player();

    stage = new PIXI.Stage(0x660022);
    graphics = new PIXI.Graphics();
    stage.addChild(graphics);

    gameInstance = new GameInstance(me, other);
    running = true;
    tickLoop();
  }

  void destroy(){
    running = false;
  }

  void update(){
    graphics.clear();
    graphics.beginFill(0x00FF00);
    graphics.drawRect(10, me.y, 10, 40);
    graphics.drawRect(460, other.y, 10, 40);
    graphics.drawRect(gameInstance.ballX, gameInstance.ballY, 10, 10);
  }

  void tickLoop(){
    if(running) new Future.delayed(const Duration(milliseconds: 25), tickLoop);
    print('hey, this is tickloop');
    if(kb.isPressed(KeyCode.UP) && kb.isPressed(KeyCode.DOWN)){
      me.direction = 0;
    } else if(kb.isPressed(KeyCode.UP)){
      me.direction = -1;
    } else if(kb.isPressed(KeyCode.DOWN)){
      me.direction = 1;
    } else{
      me.direction = 0;
    }
    gameInstance.tick();
  }

}

class Keyboard{
  List<int> pressedKeys;

  Keyboard(){
    pressedKeys = new List();
  }

  void pressKey(int keyCode){
    if(!pressedKeys.contains(keyCode)){
      pressedKeys.add(keyCode);
    }
  }
  void releaseKey(int keyCode){
    if(pressedKeys.contains(keyCode)){
      pressedKeys.remove(keyCode);
    }
  }
  bool isPressed(int keyCode){
    return pressedKeys.contains(keyCode);
  }
}
