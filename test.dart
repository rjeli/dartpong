class BaseClass{
  int a = 1;
  int b = 2;
}

class ChildClass extends BaseClass{
  int b = 3;
}

void class_printer(BaseClass bc){
  print('a is ${bc.a}, b is ${bc.b}');
}

void main(){
  var bc = new BaseClass();
  var cc = new ChildClass();

  class_printer(bc);
  class_printer(cc);
}
