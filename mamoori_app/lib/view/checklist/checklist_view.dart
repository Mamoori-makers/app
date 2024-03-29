import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'dart:math';

import '../../util/color.dart';
import '../component/mamoori_layout.dart';


class CheckListHomeView extends StatefulWidget {
  @override
  State<CheckListHomeView> createState() => _CheckListHomeViewState();
}

class _CheckListHomeViewState extends State<CheckListHomeView> with TickerProviderStateMixin {
  bool isChecked=false;
  double percentage = 0.0;
  double newPercentage = 0.0;

  late AnimationController percentageAnimationController;

  @override
  void initState() {
    super.initState();

    percentageAnimationController =  AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 2000)
    )
      ..addListener((){
        setState(() {
          percentage=lerpDouble(percentage,newPercentage,percentageAnimationController.value)!;
        });
      });

    setState(() {
      percentage = newPercentage;
      newPercentage=0.8;
      percentageAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MamooriLayout(
        appBar: false,
        title: 'CHECKLIST',
        widget: Center(
          child:Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                PercentDonut(percent: percentage, color: Colors.lightBlue),
                const SizedBox(height: 30),
                Row(
                  children: [
                    MSHCheckbox(
                      size: 35,
                      value: isChecked,
                      colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                        checkedColor: primaryColor,
                      ),
                      style: MSHCheckboxStyle.fillFade,
                      onChanged: (selected) {
                        setState(() {
                          isChecked = selected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    Text('나는 나의 장례방식에 대해 결정을 했다. ', style: TextStyle(fontSize: 16),),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//floating border
class PercentDonut extends StatelessWidget {
  const PercentDonut({Key? key, required this.percent, required this.color})
      : super(key: key);
  final percent;
  final color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      height: 310,
      child: CustomPaint(
        // CustomPaint를 그리고 이 안에 차트를 그려줍니다..
        painter: PercentDonutPaint(
          percentage: percent, // 파이 차트가 얼마나 칠해져 있는지 정하는 변수입니다.
          activeColor: color, //색
        ),
      ),
    );
  }
}

class PercentDonutPaint extends CustomPainter {
  double percentage;
  double textScaleFactor = 1.0; // 파이 차트에 들어갈 텍스트 크기를 정합니다.
  Color activeColor;
  PercentDonutPaint({required this.percentage, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint() // 화면에 그릴 때 쓸 Paint를 정의합니다.
      ..color = Color(0xfff3f3f3)
      ..strokeWidth = 15.0 // 선의 길이를 정합니다.
      ..style =
          PaintingStyle.stroke // 선의 스타일을 정합니다. stroke면 외곽선만 그리고, fill이면 다 채웁니다.
      ..strokeCap =
          StrokeCap.round; // stroke의 스타일을 정합니다. round를 고르면 stroke의 끝이 둥글게 됩니다.
    double radius = min(
        size.width / 2 - paint.strokeWidth / 2,
        size.height / 2 -
            paint.strokeWidth / 2); // 원의 반지름을 구함. 선의 굵기에 영향을 받지 않게 보정함.
    Offset center =
    Offset(size.width / 2, size.height / 2); // 원이 위젯의 가운데에 그려지게 좌표를 정함.
    canvas.drawCircle(center, radius, paint); // 원을 그림.
    double arcAngle = 2 * pi * percentage; // 호(arc)의 각도를 정함. 정해진 각도만큼만 그리도록 함.
    paint.color = primaryColor; // 호를 그릴 때는 색을 바꿔줌.
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),-pi / 2,
        arcAngle, false, paint); // 호(arc)를 그림.

    drawText(canvas, size, "${(percentage*100).round()}% "); // 텍스트를 화면에 표시함.
  }

  // 원의 중앙에 텍스트를 적음.
  void drawText(Canvas canvas, Size size, String text) {
    double fontSize = getFontSize(size, text);

    TextSpan sp = TextSpan(
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black),
        text: text); // TextSpan은 Text위젯과 거의 동일하다.
    TextPainter tp = TextPainter(text: sp, textDirection: TextDirection.ltr);

    tp.layout(); // 필수! 텍스트 페인터에 그려질 텍스트의 크기와 방향를 정함.
    double dx = size.width / 2 - tp.width / 2;
    double dy = size.height / 2 - tp.height / 2;

    Offset offset = Offset(dx, dy);
    tp.paint(canvas, offset);
  }

  // 화면 크기에 비례하도록 텍스트 폰트 크기를 정함.
  double getFontSize(Size size, String text) {
    return size.width / text.length * textScaleFactor;
  }

  @override
  bool shouldRepaint(PercentDonutPaint oldDelegate) {
    return true;
  }
}