import 'package:bh_finder/Screen/about/about.content.dart';
import 'package:bh_finder/assets/images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'About App'.text.bold.make(),
        centerTitle: true,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: VxBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(child: Image.asset(AboutApp.about_us)),
                    Expanded(child: VxBox(child: aboutContent.about_us.text.bold.size(20).make(),).make())
                  ],
                ),
              ),
              5.heightBox,
              aboutContent.about_us_content_welcome.text.make(),
              aboutContent.about_us_content.text.make(),
              10.heightBox,
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(child: Image.asset(AboutApp.mission)),
                    Expanded(child: VxBox(child: aboutContent.our_mission.text.bold.size(20).make(),).make())
                  ],
                ),
              ),
              5.heightBox,
              aboutContent.our_mission_content.text.make(),
              10.heightBox,
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(child: Image.asset(AboutApp.feature)),
                    Expanded(child: VxBox(child: aboutContent.key_feature.text.bold.size(20).make(),).make())
                  ],
                ),
              ),
              5.heightBox,
              Row(
                children: [
                  aboutContent.key_f1.text.start.make(),
                ],
              ),
              Row(
                children: [
                  aboutContent.key_f2.text.start.make(),
                ],
              ),
              Row(
                children: [
                  aboutContent.key_f3.text.start.make(),
                ],
              ),
              Row(
                children: [
                  aboutContent.key_f4.text.start.make(),
                ],
              ),
              Row(
                children: [
                  aboutContent.key_f5.text.start.make(),
                ],
              ),
              20.heightBox,
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(child: Image.asset(AboutApp.property_owner)),
                    Expanded(child: VxBox(child: aboutContent.for_property_owner.text.bold.size(20).make(),).make())
                  ],
                ),
              ),
              5.heightBox,
              aboutContent.for_property_owner_content.text.make(),
              10.heightBox,
              Image.asset(AboutApp.why, height: 150,),
              aboutContent.choose_us.text.bold.make(),
              5.heightBox,
              aboutContent.choose_us_1.text.make(),
              aboutContent.choose_us_2.text.make(),
              aboutContent.choose_us_3.text.make(),
              Divider(),
              10.heightBox,
              aboutContent.developed.text.bold.make(),
              5.heightBox,
              Row(
                children: [
                  aboutContent.contact_us.text.make(),
                ],
              ),
          
            ],
          ),
        ),
      )
          .height(MediaQuery.of(context).size.height)
          .width(MediaQuery.of(context).size.width)
          .white
          .padding(EdgeInsets.all(20))
          .make(),
    );
  }
}
