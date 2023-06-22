import 'package:get/get.dart';

class BottombarNavController extends GetxController {
  int _selectedindex=0;

  int get selectedindex => _selectedindex ;

  void Changeindex(int index){
    _selectedindex = index;
    update();
  }

  void backtohome(){
    if(selectedindex !=0){
      _selectedindex=0;
      update();
    }
  }
}