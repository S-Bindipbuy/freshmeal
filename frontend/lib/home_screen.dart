import 'package:flutter/material.dart';

class homeScreen extends StatelessWidget{
  const homeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(left: 20.0,right: 20.0),
      children: [
        SizedBox(
          height: 15,
        ),
        Container(
          height: 200,
          padding: EdgeInsets.only(left: 20.0,top: 10.0,bottom: 10.0,right: 20.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Color(0xFFFFA12E),
              borderRadius: BorderRadius.circular(20.0)
          ),
          child: Center(
            child: Row(
              children: [
                Expanded(flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Find The Best Food Burger",
                        style: TextStyle(fontSize: 24,color: Colors.white,fontFamily: "MochiyPop",fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Stay connected and track your health with this premium smart watch featuring a vibrant",
                        maxLines: 2,
                        style: TextStyle(fontSize: 12,color: Colors.white,fontFamily: "Poppin"),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 1,child: Image.asset("assets/burgerBanner.png",
                  width: 115,
                  height: 100,
                  fit: BoxFit.contain,
                ),),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Categories",style: TextStyle(fontSize: 32,fontFamily: "Poetsen",color: Color(0xFFF79926)),),
            Text("See all", style: TextStyle(fontSize: 14,fontFamily: "Poppin",color: Color(0xFF6C6C6C)),)
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                width: 130,
                height: 50,
                child: ElevatedButton(onPressed: ()=>{},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF555555),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)
                        )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        Icon(Icons.no_food_sharp,color: Colors.white,size: 24.0,),
                        Text("Burger",style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: "Poetsen"),),
                      ],
                    )
                ),
              ),
              SizedBox(width: 10,),
              SizedBox(
                width: 130,
                height: 50,
                child: ElevatedButton(onPressed: ()=>{},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF79926),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)
                        )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        Icon(Icons.local_pizza_sharp,color: Colors.white,size: 24.0,),
                        Text("Pizza",style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: "Poetsen"),),
                      ],
                    )
                ),
              ),
              SizedBox(width: 10,),
              SizedBox(
                width: 130,
                height: 50,
                child: ElevatedButton(onPressed: ()=>{},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF79926),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)
                        )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        Icon(Icons.hot_tub_sharp,color: Colors.white,size: 24.0,),
                        Text("hotdog",style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: "Poetsen"),),
                      ],
                    )
                ),
              ),
              SizedBox(width: 10,),
              SizedBox(
                width: 130,
                height: 50,
                child: ElevatedButton(onPressed: ()=>{},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF79926),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)
                        )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        Icon(Icons.local_drink_sharp,color: Colors.white,size: 24.0,),
                        Text("Drink",style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: "Poetsen"),),
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Products",style: TextStyle(fontSize: 32,fontFamily: "Poetsen",color: Color(0xFFF79926)),),
            Text("See all", style: TextStyle(fontSize: 14,fontFamily: "Poppin",color: Color(0xFF6C6C6C)),)
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          height: 400,
          padding: EdgeInsets.all(8),

          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: List.generate(4, (index) => Container(
                width: double.infinity,
                height: double.infinity,
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
      ],
    );
  }
}