import 'package:flutter/material.dart';

import 'company_profile_page.dart';
import 'ugovori_page.dart';
import 'naruci_asistenciju_page.dart';

class PravnaDashboard extends StatefulWidget {
  const PravnaDashboard({super.key});

  @override
  State<PravnaDashboard> createState() =>
      _PravnaDashboardState();
}

class _PravnaDashboardState
    extends State<PravnaDashboard> {

  int navIndex = 0;

  final pages = const [
    DashboardHomePage(),
    UgovoriPage(),
    NaruciAsistencijuPage(),
    CompanyProfilePage(),
  ];

  static const brandBlue =
      Color(0xff009CFF);

  static const brandDark =
      Color(0xff162033);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF5F8FC),

      body: pages[navIndex],

      bottomNavigationBar:
          NavigationBar(
        height: 72,
        selectedIndex: navIndex,

        onDestinationSelected: (i) {
          setState(() {
            navIndex = i;
          });
        },

        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon:
                Icon(Icons.dashboard),
            label: "Početna",
          ),

          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon:
                Icon(Icons.description),
            label: "Ugovori",
          ),

          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon:
                Icon(Icons.build),
            label: "Asistencija",
          ),

          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon:
                Icon(Icons.business),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}


class DashboardHomePage
extends StatelessWidget {

const DashboardHomePage({
super.key,
});

static const brandBlue =
    Color(0xff009CFF);

static const brandDark =
    Color(0xff162033);

@override
Widget build(BuildContext context) {

 return SafeArea(
   child: ListView(
     padding:
       const EdgeInsets.all(20),

children: [

/* HERO */
Container(
padding:
const EdgeInsets.all(24),

decoration: BoxDecoration(
gradient:
const LinearGradient(
colors: [
brandBlue,
Color(0xff45B8FF),
],
),
borderRadius:
BorderRadius.circular(28),
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

const Text(
"Majstor24\nza pravna lica",
style: TextStyle(
color: Colors.white,
fontSize: 30,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height:14),

Container(
padding:
const EdgeInsets.symmetric(
horizontal:14,
vertical:8,
),
decoration:
BoxDecoration(
color: Colors.white
.withOpacity(.18),
borderRadius:
BorderRadius.circular(
30),
),
child: const Text(
"Aktivni paket: BizPlus",
style: TextStyle(
color: Colors.white,
fontWeight:
FontWeight.w600,
),
),
),

const SizedBox(
height:18),

const Text(
"24/365 podrška za održavanje poslovnih prostora",
style: TextStyle(
color: Colors.white,
fontSize:15,
),
)
],
),
),

const SizedBox(
height:26),

const Text(
"Portal kompanije",
style: TextStyle(
fontSize: 24,
fontWeight:
FontWeight.bold,
color: brandDark,
),
),

const SizedBox(
height:16),

GridView.count(
shrinkWrap: true,
physics:
NeverScrollableScrollPhysics(),
crossAxisCount:2,
crossAxisSpacing:16,
mainAxisSpacing:16,
childAspectRatio:1.08,

children: [

_actionCard(
title:
"Naruči asistenciju",
icon:
Icons.handyman_outlined,
badge:"2 aktivna",
),

_actionCard(
title:
"Ugovori",
icon:
Icons.description_outlined,
badge:"1 aktivan",
),

_actionCard(
title:
"Fakture",
icon:
Icons.receipt_long_outlined,
badge:"Dospijeće 5 dana",
),

_actionCard(
title:
"Profil firme",
icon:
Icons.business_outlined,
badge:"Ažurirano",
),

],
),

const SizedBox(
height:30),

const Text(
"Pregled aktivnosti",
style: TextStyle(
fontSize:22,
fontWeight:
FontWeight.bold,
color: brandDark,
),
),

const SizedBox(
height:14),

_kpiCard(
"Otvoreni zahtjevi",
"2",
Icons.assignment_outlined,
),

_kpiCard(
"Intervencije ovaj mjesec",
"5",
Icons.build_circle_outlined,
),

_kpiCard(
"Ušteda kroz paket",
"1.240 KM",
Icons.savings_outlined,
),

const SizedBox(
height:18),

SizedBox(
height:54,
width: double.infinity,

child: ElevatedButton.icon(
style:
ElevatedButton.styleFrom(
backgroundColor:
brandBlue,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
16),
),
),

onPressed: () {},

icon:
const Icon(Icons.add),

label: const Text(
"Nova asistencija",
style: TextStyle(
fontSize:17,
),
),
),
),

],
),
 );
}

static Widget _actionCard({
required String title,
required IconData icon,
required String badge,
}) {
return Container(
padding:
const EdgeInsets.all(18),

decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(24),

boxShadow:[
BoxShadow(
blurRadius:18,
offset:
Offset(0,5),
color: Colors.black
.withOpacity(.05),
)
],
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children:[

Icon(
icon,
size:34,
color: brandBlue,
),

const Spacer(),

Text(
title,
style:
const TextStyle(
fontWeight:
FontWeight.w700,
fontSize:17,
),
),

const SizedBox(
height:8),

Text(
badge,
style: TextStyle(
color:
Colors.grey.shade600,
fontSize:13,
),
)

],
),
);
}

static Widget _kpiCard(
String title,
String value,
IconData icon,
){
return Card(
margin:
const EdgeInsets.only(
bottom:14,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
18),
),

child: ListTile(
contentPadding:
const EdgeInsets.all(16),

leading: CircleAvatar(
radius:26,
backgroundColor:
const Color(
0xffeef5ff),
child: Icon(
icon,
color: brandBlue,
),
),

title: Text(title),

subtitle: Padding(
padding:
const EdgeInsets.only(
top:6),
child: Text(
value,
style:
const TextStyle(
fontSize:20,
fontWeight:
FontWeight.bold,
),
),
),
),
);
}
}