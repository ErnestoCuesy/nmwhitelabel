  import 'package:flutter/material.dart';

  const MaterialColor primaryBlack = MaterialColor(
    _blackPrimaryValue,
    <int, Color>{
      50: Color(0xFF000000),
      100: Color(0xFF000000),
      200: Color(0xFF000000),
      300: Color(0xFF000000),
      400: Color(0xFF000000),
      500: Color(_blackPrimaryValue),
      600: Color(0xFF000000),
      700: Color(0xFF000000),
      800: Color(0xFF000000),
      900: Color(0xFF000000),
    },
  );
  const int _blackPrimaryValue = 0xFF000000;

  class BlackTheme {
    static final ThemeData theme = ThemeData.dark();
      // primarySwatch: primaryBlack,
      // brightness: Brightness.light,
      // primaryColor: Color(0xff000000),
      // primaryColorBrightness: Brightness.dark,
      // primaryColorLight: Color(0xffffcccc),
      // primaryColorDark: Color(0xff990000),
      // //accentColor: Color(0xffff0000),
      // //accentColorBrightness: Brightness.dark,
      // canvasColor: Color(0xfffafafa),
      // scaffoldBackgroundColor: Color(0xfffafafa),
      // bottomAppBarColor: Color(0xffffffff),
      // cardColor: Color(0xffffffff),
      // dividerColor: Color(0x1f000000),
      // highlightColor: Color(0x66bcbcbc),
      // splashColor: Color(0x66c8c8c8),
      // selectedRowColor: Color(0xfff5f5f5),
      // unselectedWidgetColor: Color(0x8a000000),
      // disabledColor: Color(0x61000000),
      // //buttonColor: Color(0xffe0e0e0),
      // toggleableActiveColor: Color(0xffcc0000),
      // secondaryHeaderColor: Color(0xffffe5e5),
      // //textSelectionColor: Color(0xffff9999),
      // //cursorColor: Color(0xff4285f4),
      // //textSelectionHandleColor: Color(0xffff6666),
      // backgroundColor: Color(0xffff9999),
      // dialogBackgroundColor: Color(0xffffffff),
      // indicatorColor: Color(0xffff0000),
      // hintColor: Color(0x8a000000),
      // errorColor: Color(0xffd32f2f),
      // buttonTheme: ButtonThemeData(
      //   textTheme: ButtonTextTheme.normal,
      //   minWidth: 88.0,
      //   height: 36.0,
      //   padding: EdgeInsets.only(
      //       top: 0.0, bottom: 0.0, left: 16.0, right: 16.0),
      //   shape: RoundedRectangleBorder(
      //     side: BorderSide(
      //       color: Color(0xff000000), width: 0.0, style: BorderStyle.none,),
      //     borderRadius: BorderRadius.all(Radius.circular(2.0)),
      //   )
      //   ,
      //   alignedDropdown: false,
      //   buttonColor: Color(0xffe0e0e0),
      //   disabledColor: Color(0x61000000),
      //   highlightColor: Color(0x29000000),
      //   splashColor: Color(0x1f000000),
      //   colorScheme: ColorScheme(
      //     primary: Color(0xff000000),
      //     primaryVariant: Color(0xff990000),
      //     secondary: Color(0xffff0000),
      //     secondaryVariant: Color(0xff990000),
      //     surface: Color(0xffffffff),
      //     background: Color(0xffff9999),
      //     error: Color(0xffd32f2f),
      //     onPrimary: Color(0xff000000),
      //     onSecondary: Color(0xff000000),
      //     onSurface: Color(0xff000000),
      //     onBackground: Color(0xffffffff),
      //     onError: Color(0xffffffff),
      //     brightness: Brightness.light,
      //   ),
      // ),
      // textTheme: TextTheme(
      //   headline1: TextStyle(
      //     color: Color(0x8a000000),
      //     fontSize: 96.0,
      //     fontWeight: FontWeight.w300,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline2: TextStyle(
      //     color: Color(0x8a000000),
      //     fontSize: 60.0,
      //     fontWeight: FontWeight.w300,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline3: TextStyle(
      //     color: Color(0x8a000000),
      //     fontSize: 48.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline4: TextStyle(
      //     color: Color(0x8a000000),
      //     fontSize: 34.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline5: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 24.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline6: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 20.0,
      //     fontWeight: FontWeight.w500,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   subtitle1: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   bodyText1: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 14.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   bodyText2: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   caption: TextStyle(
      //     color: Color(0x8a000000),
      //     fontSize: 12.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   button: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 14.0,
      //     fontWeight: FontWeight.w500,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   subtitle2: TextStyle(
      //     color: Color(0xff000000),
      //     fontSize: 14.0,
      //     fontWeight: FontWeight.w500,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   overline: TextStyle(
      //     color: Color(0xff000000),
      //     fontSize: 10.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      // ),
      // primaryTextTheme: TextTheme(
      //   headline1: TextStyle(
      //     color: Color(0xb3ffffff),
      //     fontSize: 96.0,
      //     fontWeight: FontWeight.w300,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline2: TextStyle(
      //     color: Color(0xb3ffffff),
      //     fontSize: 60.0,
      //     fontWeight: FontWeight.w300,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline3: TextStyle(
      //     color: Color(0xb3ffffff),
      //     fontSize: 48.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline4: TextStyle(
      //     color: Color(0xb3ffffff),
      //     fontSize: 34.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline5: TextStyle(
      //     color: Color(0xffffffff),
      //     fontSize: 24.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   headline6: TextStyle(
      //     color: Color(0xffffffff),
      //     fontSize: 20.0,
      //     fontWeight: FontWeight.w500,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   subtitle1: TextStyle(
      //     color: Color(0xffffffff),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   bodyText1: TextStyle(
      //     color: Color(0xffffffff),
      //     fontSize: 14.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   bodyText2: TextStyle(
      //     color: Color(0xffffffff),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   caption: TextStyle(
      //     color: Color(0xb3ffffff),
      //     fontSize: 12.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   button: TextStyle(
      //     color: Color(0xffffffff),
      //     fontSize: 14.0,
      //     fontWeight: FontWeight.w500,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   subtitle2: TextStyle(
      //     color: Color(0xffffffff),
      //     fontSize: 14.0,
      //     fontWeight: FontWeight.w500,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   overline: TextStyle(
      //     color: Color(0xffffffff),
      //     fontSize: 10.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      // ),
      // // accentTextTheme: TextTheme(
      // //   headline1: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 96.0,
      // //     fontWeight: FontWeight.w300,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   headline2: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 60.0,
      // //     fontWeight: FontWeight.w300,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   headline3: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 48.0,
      // //     fontWeight: FontWeight.w400,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   headline4: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 34.0,
      // //     fontWeight: FontWeight.w400,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   headline5: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 24.0,
      // //     fontWeight: FontWeight.w400,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   headline6: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 20.0,
      // //     fontWeight: FontWeight.w500,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   subtitle1: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 16.0,
      // //     fontWeight: FontWeight.w400,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   bodyText1: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 14.0,
      // //     fontWeight: FontWeight.w400,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   bodyText2: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 16.0,
      // //     fontWeight: FontWeight.w400,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   caption: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 12.0,
      // //     fontWeight: FontWeight.w400,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   button: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 14.0,
      // //     fontWeight: FontWeight.w500,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   subtitle2: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 14.0,
      // //     fontWeight: FontWeight.w500,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // //   overline: TextStyle(
      // //     color: Color(0x8a000000),
      // //     fontSize: 10.0,
      // //     fontWeight: FontWeight.w400,
      // //     fontStyle: FontStyle.normal,
      // //   ),
      // // ),
      // inputDecorationTheme: InputDecorationTheme(
      //   labelStyle: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   helperStyle: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   hintStyle: TextStyle(
      //     color: Color(0xffff9800),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   errorStyle: TextStyle(
      //     color: Color(0xffd32f2f),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   errorMaxLines: null,
      //   floatingLabelBehavior: FloatingLabelBehavior.always,
      //   isDense: false,
      //   contentPadding: EdgeInsets.only(
      //       top: 12.0, bottom: 12.0, left: 0.0, right: 0.0),
      //   isCollapsed: false,
      //   prefixStyle: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   suffixStyle: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   counterStyle: TextStyle(
      //     color: Color(0xdd000000),
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   filled: false,
      //   fillColor: Color(0x00000000),
      //   errorBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(
      //       color: Color(0xff000000), width: 1.0, style: BorderStyle.solid,),
      //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
      //   ),
      //   focusedBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(
      //       color: Color(0xff000000), width: 1.0, style: BorderStyle.solid,),
      //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
      //   ),
      //   focusedErrorBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(
      //       color: Color(0xff000000), width: 1.0, style: BorderStyle.solid,),
      //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
      //   ),
      //   disabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(
      //       color: Color(0xff000000), width: 1.0, style: BorderStyle.solid,),
      //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
      //   ),
      //   enabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(
      //       color: Color(0xff000000), width: 1.0, style: BorderStyle.solid,),
      //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
      //   ),
      //   border: UnderlineInputBorder(
      //     borderSide: BorderSide(
      //       color: Color(0xff000000), width: 1.0, style: BorderStyle.solid,),
      //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
      //   ),
      // ),
      // iconTheme: IconThemeData(
      //   color: Color(0xdd000000),
      //   opacity: 1.0,
      //   size: 24.0,
      // ),
      // primaryIconTheme: IconThemeData(
      //   color: Color(0xffffffff),
      //   opacity: 1.0,
      //   size: 24.0,
      // ),
      // // accentIconTheme: IconThemeData(
      // //   color: Color(0xffffffff),
      // //   opacity: 1.0,
      // //   size: 24.0,
      // // ),
      // sliderTheme: SliderThemeData(
      //   activeTrackColor: Color(0xff000000),
      //   inactiveTrackColor: Color(0x3d000000),
      //   disabledActiveTrackColor: Color(0x52990000),
      //   disabledInactiveTrackColor: Color(0x1f990000),
      //   activeTickMarkColor: Color(0x8affcccc),
      //   inactiveTickMarkColor: Color(0x8a000000),
      //   disabledActiveTickMarkColor: Color(0x1fffcccc),
      //   disabledInactiveTickMarkColor: Color(0x1f990000),
      //   thumbColor: Color(0xff000000),
      //   disabledThumbColor: Color(0x52990000),
      //   thumbShape: RoundSliderThumbShape(),
      //   overlayColor: Color(0x29000000),
      //   valueIndicatorColor: Color(0xff000000),
      //   valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      //   showValueIndicator: ShowValueIndicator.onlyForDiscrete,
      //   valueIndicatorTextStyle: TextStyle(
      //     color: Color(0xffffffff),
      //     fontSize: 14.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      // ),
      // tabBarTheme: TabBarTheme(
      //   indicatorSize: TabBarIndicatorSize.tab,
      //   labelColor: Color(0xffffffff),
      //   unselectedLabelColor: Color(0xb2ffffff),
      // ),
      // chipTheme: ChipThemeData(
      //   backgroundColor: Color(0x1f000000),
      //   brightness: Brightness.light,
      //   deleteIconColor: Color(0xde000000),
      //   disabledColor: Color(0x0c000000),
      //   labelPadding: EdgeInsets.only(
      //       top: 0.0, bottom: 0.0, left: 8.0, right: 8.0),
      //   labelStyle: TextStyle(
      //     color: Color(0xde000000),
      //     fontSize: 14.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 4.0, right: 4.0),
      //   secondaryLabelStyle: TextStyle(
      //     color: Color(0x3d000000),
      //     fontSize: 14.0,
      //     fontWeight: FontWeight.w400,
      //     fontStyle: FontStyle.normal,
      //   ),
      //   secondarySelectedColor: Color(0x3d000000),
      //   selectedColor: Color(0x3d000000),
      //   shape: StadiumBorder(side: BorderSide(
      //     color: Color(0xff000000), width: 0.0, style: BorderStyle.none,)),
      // ),
      // dialogTheme: DialogTheme(
      //     shape: RoundedRectangleBorder(
      //       side: BorderSide(
      //         color: Color(0xff000000), width: 0.0, style: BorderStyle.none,),
      //       borderRadius: BorderRadius.all(Radius.circular(0.0)),
      //     )

      // ),
    //);
  }