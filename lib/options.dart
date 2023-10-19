import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_caller_number2/variables.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({Key? key}) : super(key: key);

  @override
  State<OptionsPage> createState() => _OptionsState();
}

class _OptionsState extends State<OptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Options'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text("Enable widget visible after call"),
                  CheckboxExample()
                ],
              ),
              Row(
                children: [
                  Text("Widget duration in seconds"),
                  SizedBox(
                      width: 80,
                      height: 80,
                      child: TextFormField(
                        initialValue: widgetDuration.toString(),
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value){
                          var s = value?.length ?? 0;
                          if (s != 0) {
                            widgetDuration = double.tryParse(value)!;
                          }
                          else{
                            widgetDuration = 0;
                          }
                        },
                      )
                  )
                  ]
              ),
              Text(widgetVisible.toString()),
              Text(widgetDuration.toString())
            ],
          ),
        )
    );
  }
}


//CheckBox Widget
class CheckboxExample extends StatefulWidget {
  const CheckboxExample({super.key});

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool isChecked = widgetVisible;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
          widgetVisible = value!;
        });
      },
    );
  }
}