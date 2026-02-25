import 'package:flutter/material.dart';
import 'package:frontend/shop_screen.dart';

class orderScreen extends StatelessWidget{
  const orderScreen({super.key});



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(height: 60),
                // Noted: topbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF79926),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    Text(
                      "Orders",
                      style: TextStyle(
                        fontSize: 24,
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
                      child: null,
                    ),
                  ],
                ),

                // Noted : Product Orders
                Container(
                  height: 550,
                  child: ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(20.0)
                              ),
                              child: Image.asset(
                                "assets/burgerBanner.png",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Burger",
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Color(0xFF4C4C4C),
                                            fontFamily: "Poetsen",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5), // spacing between Text and Row
                                        Row(
                                          spacing: 4,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF79926),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                color: Colors.white,
                                                icon: Icon(Icons.remove, size: 20),
                                                onPressed: () {
                                                },
                                              ),
                                            ),
                                            Text("01",style: TextStyle(fontSize: 14,color: Color(0xFF4D4D4D),fontWeight: FontWeight.bold),),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF79926),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                color: Colors.white,
                                                icon: Icon(Icons.add, size: 20),
                                                onPressed: () {
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(flex: 1,child: Column(
                                    spacing: 10,
                                    children: [
                                      Text('\$20.0',style: TextStyle(fontSize: 24,fontFamily: "Poetsen",color: Color(0xFFF79926),fontWeight: FontWeight.bold),),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF79926),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.delete, size: 20),
                                          onPressed: () {
                                          },
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(20.0)
                              ),
                              child: Image.asset(
                                "assets/burgerBanner.png",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Burger",
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Color(0xFF4C4C4C),
                                            fontFamily: "Poetsen",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5), // spacing between Text and Row
                                        Row(
                                          spacing: 4,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF79926),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                color: Colors.white,
                                                icon: Icon(Icons.remove, size: 20),
                                                onPressed: () {
                                                },
                                              ),
                                            ),
                                            Text("01",style: TextStyle(fontSize: 14,color: Color(0xFF4D4D4D),fontWeight: FontWeight.bold),),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF79926),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                color: Colors.white,
                                                icon: Icon(Icons.add, size: 20),
                                                onPressed: () {
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(flex: 1,child: Column(
                                    spacing: 10,
                                    children: [
                                      Text('\$20.0',style: TextStyle(fontSize: 24,fontFamily: "Poetsen",color: Color(0xFFF79926),fontWeight: FontWeight.bold),),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF79926),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.delete, size: 20),
                                          onPressed: () {
                                          },
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(20.0)
                              ),
                              child: Image.asset(
                                "assets/burgerBanner.png",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Burger",
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Color(0xFF4C4C4C),
                                            fontFamily: "Poetsen",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5), // spacing between Text and Row
                                        Row(
                                          spacing: 4,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF79926),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                color: Colors.white,
                                                icon: Icon(Icons.remove, size: 20),
                                                onPressed: () {
                                                },
                                              ),
                                            ),
                                            Text("01",style: TextStyle(fontSize: 14,color: Color(0xFF4D4D4D),fontWeight: FontWeight.bold),),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF79926),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                color: Colors.white,
                                                icon: Icon(Icons.add, size: 20),
                                                onPressed: () {
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(flex: 1,child: Column(
                                    spacing: 10,
                                    children: [
                                      Text('\$20.0',style: TextStyle(fontSize: 24,fontFamily: "Poetsen",color: Color(0xFFF79926),fontWeight: FontWeight.bold),),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF79926),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.delete, size: 20),
                                          onPressed: () {
                                          },
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(20.0)
                              ),
                              child: Image.asset(
                                "assets/burgerBanner.png",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Burger",
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Color(0xFF4C4C4C),
                                            fontFamily: "Poetsen",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5), // spacing between Text and Row
                                        Row(
                                          spacing: 4,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF79926),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                color: Colors.white,
                                                icon: Icon(Icons.remove, size: 20),
                                                onPressed: () {
                                                },
                                              ),
                                            ),
                                            Text("01",style: TextStyle(fontSize: 14,color: Color(0xFF4D4D4D),fontWeight: FontWeight.bold),),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF79926),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                color: Colors.white,
                                                icon: Icon(Icons.add, size: 20),
                                                onPressed: () {
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(flex: 1,child: Column(
                                    spacing: 10,
                                    children: [
                                      Text('\$20.0',style: TextStyle(fontSize: 24,fontFamily: "Poetsen",color: Color(0xFFF79926),fontWeight: FontWeight.bold),),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF79926),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.delete, size: 20),
                                          onPressed: () {
                                          },
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

        ],
      ),

      bottomNavigationBar: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Product Items",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: "Poetsen")),
                  Text("Items : 2",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6E6969))),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tax : ",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF4D4D4D),
                          fontFamily: "Poetsen")),
                  Text('%10',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Poetsen",
                          color: Color(0xFFF79926))),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Amount : ",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF4D4D4D),
                          fontFamily: "Poetsen")),
                  Text('\$20.0',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Poetsen",
                          color: Color(0xFFF79926))),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF79926),

                  ),
                  child: Text("Checkout",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "Poetsen")),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}