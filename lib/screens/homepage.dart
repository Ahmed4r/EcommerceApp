import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  static const String routeName = 'home';
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<String, Map<String, String>> obj = {
    "handbag": {"image": "assets/handbag.jpg", "price": "\$ 28", "rate": "3.5"},
    "hoddy": {"image": "assets/hoddy.jpg", "price": "\$ 58", "rate": "2.5"},
    "headphones": {
      "image": "assets/headphones.jpg",
      "price": "\$ 88",
      "rate": "4.5",
    },
    "classic watch": {
      "image": "assets/classic watch.jpg",
      "price": "\$ 88",
      "rate": "3.1",
    },
    "t-shirt": {"image": "assets/t-shirt.jpg", "price": "\$ 88", "rate": "3.9"},
    "shoes": {"image": "assets/shoes.jpg", "price": "\$ 88", "rate": "2.7"},
    "jeans": {"image": "assets/jeans.jpg", "price": "\$ 88", "rate": "2.2"},
    "dress": {"image": "assets/dress.jpg", "price": "\$ 88", "rate": "1.6"},
    "jacket": {"image": "assets/jacket.jpg", "price": "\$ 88", "rate": "2.2"},
    "earing": {"image": "assets/earings.jpg", "price": "\$ 88", "rate": "3.5"},
  };
  int selectedIndex = -1;
  List<Map<String, dynamic>> categoryData = [
    {"type": "text", "label": "All", "icon": null},
    {"type": "icon", "label": "woman", "icon": FontAwesomeIcons.personDress},
    {"type": "icon", "label": "man", "icon": FontAwesomeIcons.person},
    {"type": "icon", "label": "child", "icon": FontAwesomeIcons.faceSmile},
    {"type": "icon", "label": "tools", "icon": FontAwesomeIcons.utensils},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEDF1F4),
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(8),

        backgroundColor: Color(0xffEDF1F4),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage("assets/profile.jpg"),
          ),
        ),
        title: Column(
          children: [
            Text(
              'Hi Welcome',
              style: GoogleFonts.cairo(color: Colors.black, fontSize: 20),
            ),
            Text(
              "Ahmed Hegazy",
              style: GoogleFonts.cairo(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {},
              icon: FaIcon(FontAwesomeIcons.bell),
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {},
              icon: FaIcon(FontAwesomeIcons.cartShopping),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Product Category",
                    style: GoogleFonts.cairo(color: Colors.black, fontSize: 20),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "See All",
                      style: GoogleFonts.cairo(
                        color: Colors.blueAccent,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_outward, color: Colors.blueAccent),
                ],
              ),
              SizedBox(height: 20),

              SizedBox(
                height: 50,

                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryData.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isSelected ? 100 : 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          color: isSelected ? Colors.blueAccent : Colors.white,
                        ),
                        child: Center(
                          child: categoryData[index]["type"] == "text"
                              ? Text(
                                  categoryData[index]["label"],
                                  style: GoogleFonts.cairo(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 20,
                                  ),
                                )
                              : Expanded(
                                  child: isSelected
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            FaIcon(
                                              categoryData[index]["icon"],
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            Text(
                                              categoryData[index]["label"],
                                              style: GoogleFonts.cairo(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        )
                                      : FaIcon(
                                          categoryData[index]["icon"],
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 10);
                  },
                  itemCount: 2,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Stack(children: [
                         
                        
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Popular Product",
                    style: GoogleFonts.cairo(color: Colors.black, fontSize: 20),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "See All",
                      style: GoogleFonts.cairo(
                        color: Colors.blueAccent,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_outward, color: Colors.blueAccent),
                ],
              ),

              SizedBox(
                height: 490,
                width: double.infinity,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // عدد الكروت في كل صف
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3 / 4, // نسبة العرض للطول حسب شكل الكرت
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return buildItem(
                      obj.keys.toList()[index],
                      obj.values.toList()[index]["image"] ?? "",
                      obj.values.toList()[index]["price"] ?? "0",
                      obj.values.toList()[index]["rate"] ?? "",
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildItem(String name, String img, String price, String rate) {
  var values = img;
  var random = Random();
  int randomNumber = random.nextInt(4); // Generates an integer between 0 and 99
  List<MaterialAccentColor> colors = [
    Colors.redAccent,
    Colors.amberAccent,
    Colors.greenAccent,
    Colors.cyanAccent,
  ];
  MaterialAccentColor MATH = colors[randomNumber];
  return Container(
    width: 150,
    height: 200,
    decoration: BoxDecoration(
      color: MATH,
      image: DecorationImage(image: AssetImage(values), fit: BoxFit.cover),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.notoSansRejang(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(20), // حواف دائرية
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ), // مقدار التغبيش
                  child: Container(
                    width: 70,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // لون شفاف أبيض
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3), // خط شفاف خفيف
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.star_border_rounded, color: Colors.white),
                        Text(
                          rate,
                          style: GoogleFonts.cairo(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // حواف دائرية
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // مقدار التغبيش
              child: Container(
                width: 140,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // لون شفاف أبيض
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3), // خط شفاف خفيف
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(price, style: GoogleFonts.cairo(color: Colors.black)),
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 15,
                      child: Icon(
                        Icons.add_shopping_cart_outlined,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
