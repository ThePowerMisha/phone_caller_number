import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_caller_number2/Services/notification_services.dart';
import 'package:phone_caller_number2/next_page.dart';
import 'package:phone_caller_number2/platform_channel.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:phone_caller_number2/options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:phone_caller_number2/variables.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {

  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child: Text("My overlay"))
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:  HomePage(),
      routes: <String, WidgetBuilder>{
        '/nextPage': (BuildContext context) => const NextPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  int? state;
  late Animation<Color?> animation;
  late AnimationController controller;
  bool contact = false;


  // Only after at least the action method is set, the notification events are delivered



  // Check if contact in contact book
  void contactInformation( String phoneNumber) async  {

    List<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    for (var element in contacts) {
      for (var element2 in element.phones!) {
         if (element2.value == phoneNumber) {
           contact = true;
           showDialog();
           return;
         }
        }
      }
    contact = false;
    //contact =  false;
    showDialog();

  }

  @override
  void initState() {
    super.initState();

    AwesomeNotifications().setListeners(

        onActionReceivedMethod:         NotificationService.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationService.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationService.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationService.onDismissActionReceivedMethod

    );


    // If permission granted start listen calls
    getPermission().then((value) {
      if (value) {
        PlatformChannel().callStream().listen((event) {
          if(event != "IDLE"){
            var arr = event.split("-");
            phoneNumber = arr[0];
            contactInformation(phoneNumber);
            state = int.tryParse(arr[1]);
            //NotificationService().showNotification( title: phoneNumber.toString(), body: contact.toString());

            AwesomeNotifications().createNotification(
                content: NotificationContent(
                    id: 10,
                    channelKey: 'basic_channel',
                    title: 'Simple Notification',
                    body: 'Simple body',
                    actionType: ActionType.Default
                ),
              actionButtons: [
                NotificationActionButton(key: "Recall", label: "RECALLLLLLLL", actionType: ActionType.Default, color: Colors.purple),
                NotificationActionButton(key: "Check", label: "Idk")
              ]
            );

            setState(() {});
          }
        });
      }
    });



    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final CurvedAnimation curve =
    CurvedAnimation(parent: controller, curve: Curves.linear);
    animation =
        ColorTween(begin: Colors.black, end: Colors.blue).animate(curve);
    // Keep the animation going forever once it is started
    animation.addStatusListener((status) {
      // Reverse the animation after it has been completed
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
      setState(() {});
    });
    // Remove this line if you want to start the animation later
    controller.forward();

    SystemAlertWindow.registerOnClickListener(callBack);

  }


  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> getPermission() async {

    await SystemAlertWindow.requestPermissions;

    await Permission.contacts.request();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    if (await Permission.phone.status == PermissionStatus.granted && Permission.contacts.status == PermissionStatus.granted) {
      return true;
    } else {
      if (await Permission.phone.request() == PermissionStatus.granted) {
        if (await Permission.contacts.request() == PermissionStatus.granted){
          return true;
        }
        else {
          return false;
        }
      } else {
        return false;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Phone Number'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Text(
              'Incoming call number:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(phoneNumber, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const OptionsPage()));
                },
                child: Text("Options menu"
                )
            ),

            Visibility(
              visible: (state ?? 0) == 0 ? false : true,
              child: AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  return Container(
                    color: animation.value,
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed("/nextPage");
                      },
                      child: Text(state == 1
                          ? "caller"
                          : state == 2
                          ? "accept"
                          : ""),
                    ),
                  );
                },
              ),
            ),
            Center(
                child: TextButton(
                  child: Text("Show over other apps"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: (){showDialog();},
            ))
          ],
        ),
      ),
    );
  }


  // Show Widget
  void showDialog(){
    SystemAlertWindow.showSystemWindow(header: SystemWindowHeader(
        title: SystemWindowText(text: "Contact information"),
    ),
        body: SystemWindowBody(rows: [
          EachRow(columns: [EachColumn( text: SystemWindowText(text: "Phone: $phoneNumber"))]),
          EachRow(columns: [EachColumn( text: SystemWindowText(text: "Time: ${DateTime.now()}"))]),
          EachRow(columns: [EachColumn( text: SystemWindowText(text: "Address book: $contact"))])
        ]),
        height: 120,
        footer: SystemWindowFooter(
            buttons: [
              SystemWindowButton(text: SystemWindowText(text:"close"), tag: "close")
            ]
        ),
        notificationTitle: phoneNumber,
        //prefMode: SystemWindowPrefMode.OVERLAY
      );

  }
}



// Close System Window
void callBack(tag){
  if (tag == 'close') {
    SystemAlertWindow.closeSystemWindow();
  }
}