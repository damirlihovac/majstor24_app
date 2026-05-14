import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'register_page.dart';
import 'role_selection_page.dart';
import '../application/auth_notifier.dart';
import '../../home/presentation/home_page.dart';

class AuthLandingPage extends StatefulWidget {
 const AuthLandingPage({super.key});

 @override
 State<AuthLandingPage> createState() =>
   _AuthLandingPageState();
}

class _AuthLandingPageState
extends State<AuthLandingPage>{

final identifierCtrl=
 TextEditingController();

final sifraCtrl=
 TextEditingController();

bool hidePassword=true;

@override
void dispose(){
identifierCtrl.dispose();
sifraCtrl.dispose();
super.dispose();
}

Future<void> _login() async {

if(
identifierCtrl.text.trim().isEmpty ||
sifraCtrl.text.trim().isEmpty
){
ScaffoldMessenger.of(context)
.showSnackBar(
 const SnackBar(
  content: Text(
   "Unesite email/telefon i vašu šifru",
  ),
 ),
);
return;
}

final auth=
 context.read<AuthNotifier>();

await auth.login(
identifierCtrl.text.trim(),
sifraCtrl.text.trim(),
);

if(!mounted) return;

if(
 auth.state.isAuthenticated
){

/* KLJUCNI FIX:
pushReplacement umjesto
pushAndRemoveUntil */

Navigator.pushReplacement(
 context,
 MaterialPageRoute(
   builder:(_)=>
    const HomePage(),
 ),
);

}
else if(
auth.state.error!=null
){

ScaffoldMessenger.of(context)
.showSnackBar(
 SnackBar(
 content: Text(
 auth.state.error!,
 ),
 ),
);

}
}

@override
Widget build(
BuildContext context,
){

final auth=
 context.watch<AuthNotifier>();

return Scaffold(
body: Stack(
children:[

Positioned.fill(
child: Image.asset(
"assets/images/pozadina.png",
fit: BoxFit.cover,
),
),

Positioned.fill(
child: Container(
color:
 Colors.black.withOpacity(
 .60,
),
),
),

Positioned(
top:18,
left:18,
child: SafeArea(
child: Container(
decoration:
 BoxDecoration(
 color:
  Colors.white
   .withOpacity(.18),

 borderRadius:
  BorderRadius.circular(
   14,
 ),
),

child: IconButton(
icon: const Icon(
Icons.arrow_back_ios_new,
color: Colors.white,
),

onPressed:(){

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder:(_)=>
 const RoleSelectionPage(),
),
);

},
),
),
),
),

SafeArea(
child: Center(
child: SingleChildScrollView(
padding:
const EdgeInsets.symmetric(
horizontal:30,
vertical:30,
),

child: ConstrainedBox(
constraints:
 const BoxConstraints(
 maxWidth:500,
),

child: Column(
children:[

const SizedBox(
height:30,
),

SizedBox(
height:95,
child: Image.asset(
"assets/images/majstor24.png",
),
),

const SizedBox(
height:28,
),

const Text(
"majstor24 za domaćinstva",
textAlign:
 TextAlign.center,

style: TextStyle(
color: Colors.white,
fontSize:25,
fontWeight:
 FontWeight.bold,
),
),

const SizedBox(
height:10,
),

const Text(
"asistencija u kući 24/365",
textAlign:
 TextAlign.center,

style: TextStyle(
color:
 Colors.white70,
fontSize:16,
),
),

const SizedBox(
height:50,
),

TextField(
controller:
identifierCtrl,

style:
 const TextStyle(
 color:
  Colors.white,
),

decoration:
 InputDecoration(
 hintText:
  "Email ili telefon",

 hintStyle:
  const TextStyle(
   color:
    Colors.white70,
 ),

 prefixIcon:
  const Icon(
   Icons.person_outline,
   color:
    Colors.white70,
 ),

 filled:true,

 fillColor:
  Colors.white
   .withOpacity(.14),

 border:
  OutlineInputBorder(
   borderRadius:
    BorderRadius.circular(
      16,
   ),
   borderSide:
    BorderSide.none,
 ),
),
),

const SizedBox(
height:18,
),

TextField(
controller:
sifraCtrl,

obscureText:
hidePassword,

style:
 const TextStyle(
 color:
  Colors.white,
),

decoration:
 InputDecoration(
hintText:"Šifra",

hintStyle:
 const TextStyle(
  color:
   Colors.white70,
),

prefixIcon:
 const Icon(
 Icons.lock_outline,
 color:
  Colors.white70,
),

suffixIcon:
IconButton(
onPressed:(){
setState(() {
hidePassword=
 !hidePassword;
});
},

icon: Icon(
hidePassword
? Icons.visibility
: Icons.visibility_off,

color:
 Colors.white70,
),
),

filled:true,

fillColor:
 Colors.white
 .withOpacity(.14),

border:
 OutlineInputBorder(
 borderRadius:
  BorderRadius.circular(
   16,
 ),
 borderSide:
  BorderSide.none,
),
),
),

const SizedBox(
height:30,
),

SizedBox(
width:double.infinity,
height:56,

child:
ElevatedButton(
onPressed:
auth.state.isLoading
? null
: _login,

style:
ElevatedButton.styleFrom(
backgroundColor:
 Colors.white,

foregroundColor:
 Colors.black,

shape:
 RoundedRectangleBorder(
 borderRadius:
  BorderRadius.circular(
   16,
 ),
),
),

child:
auth.state.isLoading
? const SizedBox(
height:24,
width:24,
child:
 CircularProgressIndicator(
 strokeWidth:2,
),
)

: const Text(
"Prijava",
style: TextStyle(
fontSize:16,
fontWeight:
 FontWeight.w600,
),
),
),
),

const SizedBox(
height:14,
),

SizedBox(
width:double.infinity,
height:56,

child:
OutlinedButton(
onPressed:(){

Navigator.push(
context,
MaterialPageRoute(
builder:(_)=>
 const RegisterPage(),
),
);

},

style:
OutlinedButton.styleFrom(
foregroundColor:
 Colors.white,

side:
 const BorderSide(
 color:
  Colors.white,
),

shape:
 RoundedRectangleBorder(
 borderRadius:
  BorderRadius.circular(
   16,
 ),
),
),

child:
const Text(
"Registracija",
style: TextStyle(
fontWeight:
 FontWeight.w600,
),
),
),
),

const SizedBox(
height:34,
),

const Text(
"Prijavite se ili kreirajte nalog",
style: TextStyle(
color:
 Colors.white60,
),
),

const SizedBox(
height:40,
),

],
),
),
),
),
),

],
),
);
}
}