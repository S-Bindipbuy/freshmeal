import 'package:flutter/material.dart';
import 'package:frontend/dashboard_screen.dart';
import 'package:frontend/order_screen.dart';

class shopScreen extends StatelessWidget{
  const shopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: 60),
              
              // Noted: topbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shops",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF79926),
                      fontFamily: "Poetsen",
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFF79926)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const orderScreen()));
                      },
                      icon: Icon(Icons.shopping_bag_outlined,
                          color: Color(0xFFF79926)),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 25),

              // Noted: Search
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFFFFA12E)),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Color(0xFF838383)),
                    hintText: "Search products...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              // Noted: Products
              Expanded(
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.only(left: 8,right: 8),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: List.generate(12, (index) => Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [BoxShadow(color: Color(0xFFEEEEEE), blurRadius: 4)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Image.asset("assets/burgerBanner.png",width: 100,height: 100,),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(left: 5.0),
                            child: Row(
                              children: [
                                Expanded(flex: 2,child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Burger",style: TextStyle(fontSize: 20,color: Color(0xFF4C4C4C),fontFamily: "Poetsen",fontWeight: FontWeight.bold),),
                                    Text('\$20.0', style: TextStyle(fontSize: 14,color: Color(0xFFF79926) ,fontFamily: "Poppin"))
                                  ],
                                )),
                                Expanded(flex: 1,child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF79926),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    color: Colors.white,
                                    onPressed: () {},
                                    icon: Icon(Icons.add, size: 20),
                                  ),
                                )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}