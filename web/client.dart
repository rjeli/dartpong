import 'dart:html';

import 'package:play_pixi/pixi.dart' as PIXI;

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

abstract class State{
  WebSocket socket;
  PIXI.Stage stage;
  Keyboard kb;
  Function enterState;

  void init(WebSocket, Keyboard, Function);
  void destroy();
  void update();
}

class ConnectingState implements State{
  WebSocket socket;
  PIXI.Stage stage;
  Keyboard kb;
  Function enterState;

  void init(WebSocket socket, Keyboard kb, Function enterState){
    this.socket = socket;
    this.kb = kb;
    this.enterState = enterState;

    stage = new PIXI.Stage(0x660099);
    socket = new WebSocket('ws://${Uri.base.host}:${Uri.base.port}/ws');
  }
  void destroy(){

  }
  void update(){
    if(kb.isPressed(KeyCode.A)){
      print('hey, this is connectingstate, a is pressed');
    }
    if(kb.isPressed(KeyCode.B)){
      print('hey, this is connectingstbte, b is pressed');
    }
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
